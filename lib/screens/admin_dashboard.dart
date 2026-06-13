import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import 'login_screen.dart';
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}
class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseService _service = FirebaseService();
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const DashboardStats(),
    const ManageJobsScreen(),
    const AllApplicationsScreen(),
  ];
  Future<void> _logout() async {
    await _service.logout();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Applications'),
        ],
        selectedItemColor: Colors.blue,
      ),
    );
  }
}
class DashboardStats extends StatefulWidget {
  const DashboardStats({super.key});
  @override
  State<DashboardStats> createState() => _DashboardStatsState();
}
class _DashboardStatsState extends State<DashboardStats> {
  final FirebaseService _service = FirebaseService();
  Map<String, int> _stats = {};
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _loadStats();
  }
  Future<void> _loadStats() async {
    setState(() => _loading = true);
    _stats = await _service.getStats();
    setState(() => _loading = false);
  }
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildCard('Total Jobs', _stats['totalJobs']?.toString() ?? '0', Icons.work, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildCard('Total Students', _stats['totalStudents']?.toString() ?? '0', Icons.people, Colors.green)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildCard('Applications', _stats['totalApps']?.toString() ?? '0', Icons.description, Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: _buildCard('Pending', _stats['pending']?.toString() ?? '0', Icons.pending, Colors.orange)),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
class ManageJobsScreen extends StatefulWidget {
  const ManageJobsScreen({super.key});
  @override
  State<ManageJobsScreen> createState() => _ManageJobsScreenState();
}
class _ManageJobsScreenState extends State<ManageJobsScreen> {
  final FirebaseService _service = FirebaseService();
  final _company = TextEditingController();
  final _role = TextEditingController();
  final _branch = TextEditingController();
  final _cgpa = TextEditingController();
  List<String> _skills = [];
  bool _showForm = false;
  final List<String> _allSkills = ['Flutter', 'Dart', 'Java', 'Python', 'React', 'JavaScript', 'SQL', 'Firebase', 'Android', 'iOS', 'Node.js', 'MongoDB'];
  Future<void> _addSampleJobs() async {
    try {
      List<Map<String, dynamic>> sampleJobs = [
        {'company': 'Google', 'role': 'Flutter Developer', 'requiredBranch': 'Computer Science', 'requiredCGPA': 7.5, 'requiredSkills': ['Flutter', 'Dart', 'Android']},
        {'company': 'Microsoft', 'role': 'Software Engineer', 'requiredBranch': 'Computer Science', 'requiredCGPA': 8.0, 'requiredSkills': ['Java', 'Python', 'Azure']},
        {'company': 'Amazon', 'role': 'Frontend Developer', 'requiredBranch': 'All', 'requiredCGPA': 7.0, 'requiredSkills': ['React', 'JavaScript', 'HTML', 'CSS']},
        {'company': 'Flipkart', 'role': 'Backend Developer', 'requiredBranch': 'Computer Science', 'requiredCGPA': 7.8, 'requiredSkills': ['Node.js', 'MongoDB', 'Express']},
        {'company': 'Infosys', 'role': 'System Engineer', 'requiredBranch': 'All', 'requiredCGPA': 6.5, 'requiredSkills': ['Java', 'SQL', 'Spring Boot']},
        {'company': 'TCS', 'role': 'Data Analyst', 'requiredBranch': 'All', 'requiredCGPA': 6.0, 'requiredSkills': ['Python', 'SQL', 'Excel']},
        {'company': 'Apple', 'role': 'iOS Developer', 'requiredBranch': 'Computer Science', 'requiredCGPA': 8.5, 'requiredSkills': ['Swift', 'iOS', 'Xcode']},
        {'company': 'Meta', 'role': 'UI/UX Designer', 'requiredBranch': 'All', 'requiredCGPA': 7.0, 'requiredSkills': ['Figma', 'Adobe XD', 'UI Design']},
      ];
      for (var job in sampleJobs) {
        await _service.addJob(
          job['company'],
          job['role'],
          job['requiredBranch'],
          job['requiredCGPA'].toDouble(),
          List<String>.from(job['requiredSkills']),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(' Sample Jobs Added!'), backgroundColor: Colors.green)
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)
      );
    }
  }
  Future<void> _addJob() async {
    if (_company.text.isEmpty || _role.text.isEmpty || _branch.text.isEmpty || _cgpa.text.isEmpty || _skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.red)
      );
      return;
    }
    await _service.addJob(
        _company.text,
        _role.text,
        _branch.text,
        double.parse(_cgpa.text),
        _skills
    );
    _company.clear();
    _role.clear();
    _branch.clear();
    _cgpa.clear();
    setState(() => _skills = []);

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job Added Successfully'), backgroundColor: Colors.green)
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addSampleJobs,
                  icon: const Icon(Icons.add_circle, size: 18),
                  label: const Text('Add Sample Jobs'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _showForm = !_showForm),
                  icon: Icon(_showForm ? Icons.close : Icons.add, size: 18),
                  label: Text(_showForm ? 'Close Form' : 'Add Manual'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showForm ? Colors.red : Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _showForm ? null : 0,
          child: _showForm
              ? Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade50,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(controller: _company, decoration: const InputDecoration(labelText: 'Company', border: OutlineInputBorder())),
                  const SizedBox(height: 8),
                  TextField(controller: _role, decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder())),
                  const SizedBox(height: 8),
                  TextField(controller: _branch, decoration: const InputDecoration(labelText: 'Required Branch (or "All")', border: OutlineInputBorder())),
                  const SizedBox(height: 8),
                  TextField(controller: _cgpa, decoration: const InputDecoration(labelText: 'Required CGPA', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 8),
                  const Text('Required Skills:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allSkills.map((s) => FilterChip(
                      label: Text(s, style: const TextStyle(fontSize: 12)),
                      selected: _skills.contains(s),
                      onSelected: (selected) => setState(() {
                        if (selected) _skills.add(s);
                        else _skills.remove(s);
                      }),
                    )).toList(),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _addJob, child: const Text('Add Job')),
                ],
              ),
            ),
          )
              : const SizedBox(),
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
                return const Center(child: Text('No jobs posted yet'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var job = snapshot.data!.docs[index];
                  var data = job.data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.work, color: Colors.blue),
                      title: Text(data['company'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${data['role']} | ${data['requiredBranch']} | CGPA: ${data['requiredCGPA']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await FirebaseFirestore.instance.collection('jobs').doc(job.id).delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Job deleted'), backgroundColor: Colors.green)
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
class AllApplicationsScreen extends StatelessWidget {
  const AllApplicationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final FirebaseService _service = FirebaseService();

    return Scaffold(
      body: StreamBuilder(
        stream: _service.getAllApplications(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Applications Yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var app = snapshot.data!.docs[index];
              Map<String, dynamic> data = app.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(data['studentName']?.substring(0, 1) ?? '?'),
                  ),
                  title: Text(data['studentName'] ?? 'Unknown'),
                  subtitle: Text('${data['jobRole']} at ${data['companyName']}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(data['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButton<String>(
                      value: data['status'] ?? 'Applied',
                      items: const [
                        DropdownMenuItem(value: 'Applied', child: Text('Applied')),
                        DropdownMenuItem(value: 'Shortlisted', child: Text('Shortlisted')),
                        DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                      ],
                      onChanged: (newStatus) async {
                        if (newStatus != null) {
                          await _service.updateStatus(app.id, newStatus);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Status updated to $newStatus'), backgroundColor: Colors.green)
                            );
                          }
                        }
                      },
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(' STUDENT DETAILS', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Name: ${data['studentName']}'),
                          Text('Branch: ${data['studentBranch']}'),
                          Text('CGPA: ${data['studentCgpa']}'),
                          Text('Skills: ${(data['studentSkills'] as List).join(", ")}'),
                          const Divider(),
                          const Text(' JOB DETAILS', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Company: ${data['companyName']}'),
                          Text('Role: ${data['jobRole']}'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
  Color _getStatusColor(String status) {
    if (status == 'Shortlisted') return Colors.green;
    if (status == 'Rejected') return Colors.red;
    return Colors.orange;
  }
}