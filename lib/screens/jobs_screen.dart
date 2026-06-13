import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});
  @override
  State<JobsScreen> createState() => _JobsScreenState();
}
class _JobsScreenState extends State<JobsScreen> {
  final FirebaseService _service = FirebaseService();
  Map<String, dynamic>? _student;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _loadStudent();
  }
  Future<void> _loadStudent() async {
    String uid = _service.getCurrentUserId();
    if (uid.isNotEmpty) {
      var data = await _service.getUserData(uid);
      setState(() {
        _student = data;
        _loading = false;
      });
    }
  }
  Future<bool> _checkEligibility(Map<String, dynamic> job) async {
    if (_student == null) return false;
    String studentBranch = _student!['branch'] ?? '';
    double studentCgpa = (_student!['cgpa'] ?? 0.0).toDouble();
    List<String> studentSkills = _student!['skills'] != null
        ? List<String>.from(_student!['skills'])
        : [];
    String reqBranch = job['requiredBranch'] ?? 'All';
    double reqCgpa = (job['requiredCGPA'] ?? 0.0).toDouble();
    List<String> reqSkills = job['requiredSkills'] != null
        ? List<String>.from(job['requiredSkills'])
        : [];
    if (reqBranch != 'All' && reqBranch != studentBranch) return false;
    if (studentCgpa < reqCgpa) return false;
    if (reqSkills.isEmpty) return true;
    return reqSkills.any((skill) => studentSkills.contains(skill));
  }
  Future<void> _apply(String jobId, Map<String, dynamic> job) async {
    bool eligible = await _checkEligibility(job);
    if (!eligible) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(' You are not eligible for this job'), backgroundColor: Colors.red)
      );
      return;
    }
    await _service.applyForJob(_service.getCurrentUserId(), jobId, _student!, job);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application Submitted!'), backgroundColor: Colors.green)
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_student == null) {
      return const Center(child: Text('No profile data found'));
    }
    List<String> studentSkills = _student!['skills'] != null
        ? List<String>.from(_student!['skills'])
        : [];
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('YOUR PROFILE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.school, color: Colors.blue),
                                const SizedBox(height: 4),
                                Text(_student!['branch'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
                                const Text('Branch', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.star, color: Colors.orange),
                                const SizedBox(height: 4),
                                Text(_student!['cgpa']?.toString() ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
                                const Text('CGPA', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(' YOUR SKILLS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: studentSkills.isEmpty
                                ? [Chip(label: const Text('No skills added'), backgroundColor: Colors.grey.shade300)]
                                : studentSkills.map((skill) => Chip(
                              label: Text(skill),
                              backgroundColor: Colors.green.shade100,
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _service.getJobs(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No Jobs Available', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 8),
                        Text('Please check back later', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var job = snapshot.data!.docs[index];
                    Map<String, dynamic> data = job.data() as Map<String, dynamic>;
                    String company = data['company'] ?? 'Unknown';
                    String role = data['role'] ?? 'Unknown';
                    String reqBranch = data['requiredBranch'] ?? 'All';
                    double reqCgpa = (data['requiredCGPA'] ?? 0.0).toDouble();
                    List<String> reqSkills = data['requiredSkills'] != null
                        ? List<String>.from(data['requiredSkills'])
                        : [];
                    return FutureBuilder(
                      future: _checkEligibility(data),
                      builder: (context, eligibleSnap) {
                        bool eligible = eligibleSnap.data ?? false;
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: InkWell(
                            onTap: () => _apply(job.id, data),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.business, color: Colors.blue, size: 35),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(company,
                                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                            Text(role, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: eligible ? Colors.green : Colors.red,
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        child: Text(
                                          eligible ? 'ELIGIBLE' : 'NOT ELIGIBLE',
                                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(' JOB REQUIREMENTS',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue)),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            const Icon(Icons.school, size: 18, color: Colors.blue),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Required Branch: $reqBranch',
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, size: 18, color: Colors.orange),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Minimum CGPA: $reqCgpa',
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        const Text('Required Skills:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: reqSkills.isEmpty
                                              ? [Chip(label: const Text('No specific skills'), backgroundColor: Colors.grey.shade200)]
                                              : reqSkills.map((skill) => Chip(
                                            label: Text(skill, style: const TextStyle(fontSize: 12)),
                                            backgroundColor: Colors.blue.shade50,
                                          )).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: eligible ? () => _apply(job.id, data) : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: eligible ? Colors.blue : Colors.grey,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: Text(
                                        eligible ? 'APPLY NOW' : 'NOT ELIGIBLE',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}