import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TeacherProfilePage extends StatefulWidget {
  final String email;

  const TeacherProfilePage({super.key, required this.email});

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  late Future<Map<String, dynamic>> teacherData;

  @override
  void initState() {
    super.initState();
    teacherData = fetchTeacherProfile(widget.email);
  }

  Future<Map<String, dynamic>> fetchTeacherProfile(String email) async {
    final encodedEmail = Uri.encodeComponent(email);
    final url = Uri.parse('http://127.0.0.1:8000/teacher/$encodedEmail');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load teacher profile");
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
        title: const Text("Teacher Profile"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.teal[50],
      body: FutureBuilder<Map<String, dynamic>>(
        future: teacherData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No profile data found."));
          }

          final data = snapshot.data!;
          final name = data['full_name'] ?? 'No Name';
          final email = data['email'] ?? 'No Email';
          final regNo = data['teacher_reg_no'] ?? 'N/A';
          final dept = data['department'] ?? 'N/A';
          final phone = data['phone'] ?? 'N/A';
          final address = data['address'] ?? 'N/A';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // প্রোফাইল ছবি রাখতে চাইলে এখানে যুক্ত করো
                // const CircleAvatar(
                //   radius: 60,
                //   backgroundImage: AssetImage('assets/teacher_profile_pic.png'),
                // ),
                // const SizedBox(height: 20),

                Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(email, style: const TextStyle(fontSize: 16, color: Colors.black)),
                const SizedBox(height: 20),
                const Divider(),

                ListTile(
                  leading: const Icon(Icons.school, color: Colors.blue),
                  title: const Text("Department"),
                  subtitle: Text(dept),
                ),
                ListTile(
                  leading: const Icon(Icons.badge, color: Colors.blue),
                  title: const Text("Registration No"),
                  subtitle: Text(regNo),
                ),
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.blue),
                  title: const Text("Phone"),
                  subtitle: Text(phone),
                ),
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.blue),
                  title: const Text("Address"),
                  subtitle: Text(address),
                ),

                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () => _showLogoutConfirmation(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
