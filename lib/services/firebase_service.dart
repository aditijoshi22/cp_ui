import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String getCurrentUserId() {
    return _auth.currentUser?.uid ?? '';
  }
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return {'uid': result.user!.uid, 'email': result.user!.email};
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }
  Future<bool> register(String email, String password, String name,
      String branch, String cgpa, String phone, List<String> skills) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('users').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'branch': branch,
        'cgpa': double.parse(cgpa),
        'phone': phone,
        'skills': skills,
        'role': 'student',
        'uid': result.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }
  Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc['role'] ?? 'student';
      }
      return 'student';
    } catch (e) {
      print('Get role error: $e');
      return 'student';
    }
  }
  Future<Map<String, dynamic>> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      print('Get user data error: $e');
      return {};
    }
  }
  Future<void> logout() async {
    await _auth.signOut();
  }
  Future<void> addJob(String company, String role, String branch, double cgpa, List<String> skills) async {
    await _firestore.collection('jobs').add({
      'company': company,
      'role': role,
      'requiredBranch': branch,
      'requiredCGPA': cgpa,
      'requiredSkills': skills,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  Stream<QuerySnapshot> getJobs() {
    return _firestore.collection('jobs').orderBy('createdAt', descending: true).snapshots();
  }
  Future<bool> isEligible(String jobId, String studentBranch, double studentCgpa, List<String> studentSkills) async {
    try {
      DocumentSnapshot job = await _firestore.collection('jobs').doc(jobId).get();
      if (!job.exists) return false;

      String reqBranch = job['requiredBranch'] ?? 'All';
      double reqCgpa = (job['requiredCGPA'] ?? 0.0).toDouble();
      List<String> reqSkills = [];

      if (job['requiredSkills'] != null) {
        reqSkills = List<String>.from(job['requiredSkills']);
      }

      if (reqBranch != 'All' && reqBranch != studentBranch) return false;
      if (studentCgpa < reqCgpa) return false;

      if (reqSkills.isEmpty) return true;
      return reqSkills.any((skill) => studentSkills.contains(skill));
    } catch (e) {
      print('Eligibility error: $e');
      return false;
    }
  }

  Future<void> applyForJob(String userId, String jobId, Map<String, dynamic> student, Map<String, dynamic> job) async {
    await _firestore.collection('applications').add({
      'userId': userId,
      'jobId': jobId,
      'status': 'Applied',
      'studentName': student['name'] ?? 'Unknown',
      'studentBranch': student['branch'] ?? 'Unknown',
      'studentCgpa': student['cgpa'] ?? 0.0,
      'studentSkills': student['skills'] ?? [],
      'companyName': job['company'] ?? 'Unknown',
      'jobRole': job['role'] ?? 'Unknown',
      'appliedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getUserApplications(String userId) {
    return _firestore
        .collection('applications')
        .where('userId', isEqualTo: userId)
        .orderBy('appliedAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getAllApplications() {
    return _firestore.collection('applications').orderBy('appliedAt', descending: true).snapshots();
  }
  Future<void> updateStatus(String appId, String status) async {
    await _firestore.collection('applications').doc(appId).update({'status': status});
  }
  Future<Map<String, int>> getStats() async {
    QuerySnapshot jobs = await _firestore.collection('jobs').get();
    QuerySnapshot apps = await _firestore.collection('applications').get();
    QuerySnapshot students = await _firestore.collection('users').where('role', isEqualTo: 'student').get();
    return {
      'totalJobs': jobs.docs.length,
      'totalApps': apps.docs.length,
      'totalStudents': students.docs.length,
    };
  }
}