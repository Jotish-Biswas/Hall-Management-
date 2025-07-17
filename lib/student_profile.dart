import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hall_management/image_picker_helper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'ServerLink.dart';
import 'image_picker_interface.dart';

class StudentProfilePage extends StatefulWidget {
  final String email;
  final VoidCallback? onBack;
  final String hallname;

  const StudentProfilePage({
    super.key,
    required this.email,
    required this.hallname,
    this.onBack,
  });

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
    final url = Uri.parse('$baseUrl/student/$encodedEmail');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load student profile');
    }
  }

  Future<void> uploadImage() async {
    final picker = getImagePicker();
    await picker.pickAndUploadImage(
      email: widget.email,
      baseUrl: baseUrl,
      context: context,
      userType: 'student',
      onSuccess: () {
        setState(() {
          studentData = fetchStudentProfile(widget.email);
        });
      },
    );
  }

  void _showLogoutConfirmation() {
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
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar( // AppBar with gradient background
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              if (widget.onBack != null) {
                widget.onBack!();
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.arrow_back, color: Colors.lightBlue, size: 24),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text("Student Profile", style: TextStyle(color: Colors.white)),
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
          final hall = data['hall_name'] ?? widget.hallname;
          final profileImage = data['profile_image'];

          return Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.white,
                          backgroundImage: profileImage != null
                              ? MemoryImage(base64Decode(profileImage))
                              : null,
                          child: profileImage == null
                              ? const Icon(Icons.person, size: 60, color: Colors.grey)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            onPressed: uploadImage,
                            icon: const Icon(Icons.camera_alt, color: Colors.indigo),
                            tooltip: 'Upload Profile Picture',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    const Divider(height: 30, thickness: 1.5),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            profileTile(Icons.school, "Department", dept),
                            profileTile(Icons.calendar_today, "Session", session),
                            profileTile(Icons.badge, "Roll No", roll),
                            profileTile(Icons.location_city, "Hall Name", hall),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _showLogoutConfirmation,
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF203A43),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget profileTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF203A43)),
      title: Text("$label: $value", style: const TextStyle(fontSize: 16)),
    );
  }
}
