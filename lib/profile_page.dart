import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    final url = Uri.parse('http://127.0.0.1:8000/users/provost/$encodedEmail');

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

  Future<void> uploadImage() async {
    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) async {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        await reader.onLoad.first;

        final base64Image = reader.result.toString().split(',').last;

        final url = Uri.parse(
          'http://127.0.0.1:8000/users/${Uri.encodeComponent(widget.email)}/upload-image',
        );

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
            const SnackBar(content: Text('Profile picture updated')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image upload failed')),
          );
        }
      }
    });
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
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
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
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        title: const Text("Provost Profile"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            tooltip: "Upload Profile Picture",
            onPressed: uploadImage,
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
                        onPressed: uploadImage,
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
