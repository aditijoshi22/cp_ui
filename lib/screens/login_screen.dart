import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import 'student_dashboard.dart';
import 'admin_dashboard.dart';
import 'register_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final FirebaseService _service = FirebaseService();
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      var user = await _service.login(_email.text.trim(), _password.text.trim());
      if (user != null && mounted) {
        String role = await _service.getUserRole(user['uid']);
        print('User role: $role');
        if (mounted) {
          if (role == 'admin') {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboard())
            );
          } else {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const StudentDashboard())
            );
          }
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email or password'), backgroundColor: Colors.red)
        );
      }
    } catch (e) {
      print('Login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)
        );
      }
    }
    setState(() => _loading = false);
  }
  Future<void> _createAdminUser() async {
    setState(() => _loading = true);
    try {
      print('Attempting to create admin user...');
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: 'admin@placement.com',
          password: 'admin@123',
        );
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin user already exists! Try logging in.'), backgroundColor: Colors.orange)
        );
        _email.text = 'admin@placement.com';
        _password.text = 'admin@123';
        setState(() => _loading = false);
        return;
      } catch (e) {
        print('Admin does not exist, creating...');
      }
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: 'admin@placement.com',
        password: 'admin@123',
      );
      print('Auth user created: ${userCredential.user!.uid}');
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
      print('Firestore document created');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin created! Use admin@placement.com / admin@123 to login'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          )
      );
      _email.text = 'admin@placement.com';
      _password.text = 'admin@123';
    } on FirebaseException catch (e) {
      print('Firebase Error: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(' Permission denied! Please set Firestore rules to test mode first.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            )
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin email already exists! Try logging in.'),
              backgroundColor: Colors.orange,
            )
        );
        _email.text = 'admin@placement.com';
        _password.text = 'admin@123';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.message}'), backgroundColor: Colors.red)
        );
      }
    } catch (e) {
      print('General Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)
      );
    }
    setState(() => _loading = false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.blue],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.school, size: 60, color: Colors.blue),
                      const SizedBox(height: 16),
                      const Text(
                        'Placement Management',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Student Placement Cell',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 40),
                      TextFormField(
                        controller: _email,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          prefixIcon: const Icon(Icons.email, color: Colors.blue),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blue, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blue, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('LOGIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const RegisterScreen())
                              );
                            },
                            child: const Text('Register Now', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),

                      const Divider(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: OutlinedButton.icon(
                          onPressed: _loading ? null : _createAdminUser,
                          icon: const Icon(Icons.admin_panel_settings, size: 18),
                          label: const Text('CREATE ADMIN ACCOUNT (First Time Setup)'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Admin credentials: admin@placement.com / admin@123',
                        style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
}