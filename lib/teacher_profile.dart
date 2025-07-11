import 'dart:convert';
import 'dart:html' as html; // for web file upload
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
  String? profileImageBase64;

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
      final data = jsonDecode(response.body);
      profileImageBase64 = data['profile_image'];  // load existing image base64 string if any
      return data;
    } else {
      throw Exception("Failed to load teacher profile");
    }
  }

  void _uploadImage() {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files == null || files.isEmpty) return;

      final reader = html.FileReader();
      reader.readAsDataUrl(files[0]);

      await reader.onLoad.first;
      final encoded = reader.result as String;
      final base64String = encoded.split(',').last;

      await uploadImageToServer(base64String);
    });
  }

  Future<void> uploadImageToServer(String base64Image) async {
    final url = Uri.parse('http://127.0.0.1:8000/teacher/${Uri.encodeComponent(widget.email)}/upload-image');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image_base64': base64Image}),
    );

    if (response.statusCode == 200) {
      setState(() {
        profileImageBase64 = base64Image;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image uploaded successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            tooltip: "Upload Profile Picture",
            onPressed: _uploadImage,
          ),
        ],
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
                if (profileImageBase64 != null)
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: MemoryImage(base64Decode(profileImageBase64!)),
                  ),
                // No avatar shown if no image uploaded

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
