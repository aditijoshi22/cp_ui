import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
class StudentProfile extends StatefulWidget {
  const StudentProfile({super.key});
  @override
  State<StudentProfile> createState() => _StudentProfileState();
}
class _StudentProfileState extends State<StudentProfile> {
  final FirebaseService _service = FirebaseService();
  Map<String, dynamic>? _data;
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }
  Future<void> _loadProfile() async {
    String uid = _service.getCurrentUserId();
    var data = await _service.getUserData(uid);
    setState(() => _data = data);
  }
  @override
  Widget build(BuildContext context) {
    if (_data == null) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 16),
          Text(_data!['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(_data!['email'], style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          Card(child: Padding(padding: const EdgeInsets.all(16),
            child: Column(children: [
              _buildRow('Phone', _data!['phone']),
              _buildRow('Branch', _data!['branch']),
              _buildRow('CGPA', _data!['cgpa'].toString()),
              _buildRow('Skills', (_data!['skills'] as List).join(', ')),
            ]),
          )),
        ],
      ),
    );
  }
  Widget _buildRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), Text(value)],
      ),
    );
  }
}