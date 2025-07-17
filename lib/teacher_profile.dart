import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ServerLink.dart';
import 'image_picker_helper.dart'; // custom helper
import 'package:shared_preferences/shared_preferences.dart';

class TeacherProfilePage extends StatefulWidget {
  final String email;
  final String hallname;

  const TeacherProfilePage({super.key, required this.email, required this.hallname});

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  late Future<Map<String, dynamic>> teacherData;
  String? profileImageBase64;

  @override
  void initState() {
    super.initState();
    teacherData = fetchTeacherProfile(widget.email);
  }

  Future<Map<String, dynamic>> fetchTeacherProfile(String email) async {
    final encodedEmail = Uri.encodeComponent(email);
    final url = Uri.parse('$baseUrl/teacher/$encodedEmail');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      profileImageBase64 = data['profile_image'];
      return data;
    } else {
      throw Exception("Failed to load teacher profile");
    }
  }

  Future<void> _uploadImage() async {
    final success = await getImagePicker().pickAndUploadImage(
      email: widget.email,
      baseUrl: baseUrl,
      context: context,
      userType: 'teacher',
      onSuccess: () {
        setState(() {
          teacherData = fetchTeacherProfile(widget.email);
        });
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              logout(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  void logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 154, 151, 151),
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
        title: const Text("Teacher Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            tooltip: "Upload Profile Picture",
            onPressed: _uploadImage,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE8F0F2),
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
          final hall = data['hall_name'] ?? widget.hallname;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (profileImageBase64 != null)
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: MemoryImage(base64Decode(profileImageBase64!)),
                  ),
                const SizedBox(height: 10),
                Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(email, style: const TextStyle(fontSize: 16, color: Colors.black54)),
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
                ListTile(
                  leading: const Icon(Icons.location_city, color: Colors.blue),
                  title: const Text("Hall Name"),
                  subtitle: Text(hall),
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
