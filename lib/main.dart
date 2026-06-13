import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/login_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAUH_QnJkB51lu0u1aQ7ydG7yvYrMvbx88",
        authDomain: "placement-app-cea0f.firebaseapp.com",
        projectId: "placement-app-cea0f",
        storageBucket: "placement-app-cea0f.firebasestorage.app",
        messagingSenderId: "1016516128954",
        appId: "1:1016516128954:web:6eced446441c566180d283",
        measurementId: "G-Y3FVSC5M23",
      ),
  );
  await createAdminUser();
  runApp(const MyApp());
}
Future<void> createAdminUser() async {
  try {
    QuerySnapshot adminCheck = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .limit(1)
        .get();
    if (adminCheck.docs.isNotEmpty) {
      print(' Admin user already exists!');
      return;
    }
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: 'admin@placement.com',
      password: 'admin@123',
    );
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
      'name': 'Admin User',
      'email': 'admin@placement.com',
      'role': 'admin',
      'branch': 'All',
      'cgpa': 10.0,
      'phone': '9999999999',
      'skills': ['Management', 'Administration'],
      'profileCompleted': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    print('Admin user created successfully!');
    print('Email: admin@placement.com');
    print(' Password: admin@123');

  } catch (e) {
    print('Error creating admin: $e');
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Placement Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}