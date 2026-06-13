import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
class AppliedJobsScreen extends StatefulWidget {
  const AppliedJobsScreen({super.key});
  @override
  State<AppliedJobsScreen> createState() => _AppliedJobsScreenState();
}
class _AppliedJobsScreenState extends State<AppliedJobsScreen> {
  final FirebaseService _service = FirebaseService();
  Color _getStatusColor(String status) {
    if (status == 'Shortlisted') return Colors.green;
    if (status == 'Rejected') return Colors.red;
    return Colors.orange;
  }
  @override
  Widget build(BuildContext context) {
    String uid = _service.getCurrentUserId();
    return Scaffold(
      body: StreamBuilder(
        stream: _service.getUserApplications(uid),
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
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No Applications Found', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Apply for jobs to see them here', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var app = snapshot.data!.docs[index];
              Map<String, dynamic> data = app.data() as Map<String, dynamic>;
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.description, color: Colors.blue, size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['companyName'] ?? 'Company',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text(data['jobRole'] ?? 'Role', style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(data['status']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(data['status'] ?? 'Applied',
                                style: TextStyle(color: _getStatusColor(data['status']), fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Applied with:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Branch: ${data['studentBranch'] ?? 'N/A'}'),
                                Text('CGPA: ${data['studentCgpa'] ?? 'N/A'}'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Skills:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text((data['studentSkills'] as List?)?.join(', ') ?? 'None'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}