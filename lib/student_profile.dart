import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentProfilePage extends StatefulWidget {
  final String email;

  const StudentProfilePage({super.key, required this.email});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  late Future<Map<String, dynamic>> studentData;

  @override
  void initState() {
    super.initState();
    studentData = fetchStudentProfile(widget.email);
  }

  Future<Map<String, dynamic>> fetchStudentProfile(String email) async {
    final encodedEmail = Uri.encodeComponent(email);
    final url = Uri.parse('http://127.0.0.1:8000/student/$encodedEmail');

    final response = await http.get(url);
    print("Looking for student with email: $email");
    print("Found student: ${response.body}");
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load student profile');
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Profile"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: studentData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No profile data found."));
          }

          final data = snapshot.data!;
          final name = data['name'] ?? 'No Name';
          final email = data['email'] ?? 'No Email';
          final dept = data['department'] ?? 'N/A';
          final session = data['session'] ?? 'N/A';
          final roll = data['roll'] ?? 'N/A';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  email,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.school, color: Colors.blue),
                  title: Text("Department: $dept"),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.blue),
                  title: Text("Session: $session"),
                ),
                ListTile(
                  leading: const Icon(Icons.badge, color: Colors.blue),
                  title: Text("Roll No: $roll"),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () => _showLogoutConfirmation(context),
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
