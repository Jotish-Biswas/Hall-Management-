import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'image_picker_helper.dart'; // your platform-aware picker interface
import 'ServerLink.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProvostProfilePage extends StatefulWidget {
  final String email;
  final String hallName;

  const ProvostProfilePage({super.key, required this.email, required this.hallName});

  @override
  State<ProvostProfilePage> createState() => _ProvostProfilePageState();
}

class _ProvostProfilePageState extends State<ProvostProfilePage> {
  late Future<Map<String, dynamic>> provostData;
  String? profileImageBase64;

  @override
  void initState() {
    super.initState();
    provostData = fetchProfile();
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final encodedEmail = Uri.encodeComponent(widget.email);
    final url = Uri.parse('$baseUrl/users/provost/$encodedEmail');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        profileImageBase64 = data['profile_image'];
      });
      return data;
    } else {
      throw Exception("Failed to load provost data");
    }
  }

  Future<void> _uploadImage() async {
    final success = await getImagePicker().pickAndUploadImage(
      email: widget.email,
      baseUrl: baseUrl,
      context: context,
      userType: 'provost',
      onSuccess: () {
        setState(() {
          provostData = fetchProfile();
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
    await prefs.clear(); // Clears login info
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        title: const Text("Provost Profile"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            tooltip: "Upload Profile Picture",
            onPressed: _uploadImage,
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: provostData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No data available."));
          }

          final data = snapshot.data!;
          final name = data['full_name'] ?? "No Name";
          final email = data['email'] ?? "No Email";
          final phone = data['phone'] ?? "No Phone";
          final hallName = data['hall_name'] ?? widget.hallName;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.white,
                      backgroundImage: profileImageBase64 != null
                          ? MemoryImage(base64Decode(profileImageBase64!))
                          : null,
                      child: profileImageBase64 == null
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.blue),
                        onPressed: _uploadImage,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  hallName,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent),
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(email, style: const TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.blue),
                  title: const Text("Phone"),
                  subtitle: Text(phone),
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
                  onPressed: _showLogoutConfirmation,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
