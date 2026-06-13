import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'jobs_screen.dart';
import 'applied_jobs_screen.dart';
import 'student_profile.dart';
import 'login_screen.dart';
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}
class _StudentDashboardState extends State<StudentDashboard> {
  final FirebaseService _service = FirebaseService();
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const JobsScreen(),
    const AppliedJobsScreen(),
    const StudentProfile(),
  ];
  Future<void> _logout() async {
    await _service.logout();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Dashboard'), backgroundColor: Colors.blue,
          actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _logout)]),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Applied'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Colors.blue,
      ),
    );
  }
}