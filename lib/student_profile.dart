import 'dart:convert';
import 'dart:html' as html; // For Flutter Web
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentProfilePage extends StatefulWidget {
  final String email;
  final VoidCallback? onBack;

  const StudentProfilePage({
    super.key,
    required this.email,
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
    final url = Uri.parse('http://127.0.0.1:8000/student/$encodedEmail');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load student profile');
    }
  }

  Future<void> _uploadImage() async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) async {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsDataUrl(file);

        await reader.onLoad.first;

        final encodedImage = reader.result.toString().split(',').last;

        final url = Uri.parse('http://127.0.0.1:8000/student/${Uri.encodeComponent(widget.email)}/upload-image');

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'image_base64': encodedImage}),
        );

        if (response.statusCode == 200) {
          setState(() {
            studentData = fetchStudentProfile(widget.email);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image')),
          );
        }
      }
    });
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
      appBar: AppBar(
        title: const Text("Student Profile"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            }
          },
        ),
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
                            onPressed: _uploadImage,
                            icon: const Icon(Icons.camera_alt, color: Colors.indigo),
                            tooltip: 'Upload Profile Picture',
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    const Divider(height: 30, thickness: 1.5),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.school, color: Colors.indigo),
                            title: Text("Department: $dept"),
                          ),
                          ListTile(
                            leading: const Icon(Icons.calendar_today, color: Colors.indigo),
                            title: Text("Session: $session"),
                          ),
                          ListTile(
                            leading: const Icon(Icons.badge, color: Colors.indigo),
                            title: Text("Roll No: $roll"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _showLogoutConfirmation(context),
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
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
}
