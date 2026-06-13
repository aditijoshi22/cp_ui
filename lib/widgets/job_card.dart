import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JobCard extends StatelessWidget {
  final dynamic job;

  const JobCard(this.job, {super.key});

  Future<void> applyJob() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('applications').add({
      "userId": uid,
      "jobId": job.id,
      "title": job['title'],
      "company": job['company'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: Text(job['title']),
        subtitle: Text(job['company']),
        trailing: ElevatedButton(
          onPressed: () async {
            await applyJob();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Applied Successfully")),
            );
          },
          child: const Text("Apply"),
        ),
      ),
    );
  }
}