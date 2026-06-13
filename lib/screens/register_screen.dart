import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseService _service = FirebaseService();
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _phone = TextEditingController();
  final _cgpa = TextEditingController();
  String _branch = 'Computer Science';
  List<String> _skills = [];
  bool _loading = false;
  final List<String> _branches = ['Computer Science', 'Information Technology', 'Electronics', 'Mechanical', 'Civil'];
  final List<String> _allSkills = ['Flutter', 'Dart', 'Java', 'Python', 'React', 'JavaScript', 'SQL', 'Firebase'];
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_password.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords mismatch')));
      return;
    }
    if (_skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least one skill')));
      return;
    }
    setState(() => _loading = true);
    bool success = await _service.register(
      _email.text.trim(), _password.text.trim(), _name.text.trim(),
      _branch, _cgpa.text.trim(), _phone.text.trim(), _skills,
    );
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration Success')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration Failed')));
    }
    setState(() => _loading = false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register'), backgroundColor: Colors.blue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Full Name'),
                      validator: (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone'),
                      validator: (v) => v!.length != 10 ? '10 digits' : null),
                  const SizedBox(height: 12),
                  DropdownButtonFormField(value: _branch, items: _branches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                      onChanged: (v) => setState(() => _branch = v!), decoration: const InputDecoration(labelText: 'Branch')),
                  const SizedBox(height: 12),
                  TextFormField(controller: _cgpa, decoration: const InputDecoration(labelText: 'CGPA'), keyboardType: TextInputType.number,
                      validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null),
                  const SizedBox(height: 12),
                  const Text('Skills:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(spacing: 8, children: _allSkills.map((s) => FilterChip(label: Text(s), selected: _skills.contains(s),
                      onSelected: (selected) => setState(() => selected ? _skills.add(s) : _skills.remove(s)))).toList()),
                  const SizedBox(height: 12),
                  TextFormField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Password'),
                      validator: (v) => v!.length < 6 ? 'Min 6 chars' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: _confirm, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm Password')),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: _register, child: _loading ? const CircularProgressIndicator() : const Text('Register')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}