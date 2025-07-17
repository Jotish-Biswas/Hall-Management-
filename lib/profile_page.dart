import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'ServerLink.dart';
import 'image_picker_helper.dart';

class ProvostProfilePage extends StatefulWidget {
  final String email;
  final String hallName;

  const ProvostProfilePage({
    super.key,
    required this.email,
    required this.hallName,
  });

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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
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
      backgroundColor: Colors.grey[100],
      appBar:  AppBar(
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
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
      ),
    ),
  ),
  title: const Text("Provost Profile", style: TextStyle(color: Colors.white)),
  centerTitle: true,
  actions: [
    IconButton(
      icon: const Icon(Icons.camera_alt, color: Colors.white),
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
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: profileImageBase64 != null
                              ? MemoryImage(base64Decode(profileImageBase64!))
                              : null,
                          child: profileImageBase64 == null
                              ? const Icon(Icons.person, size: 70, color: Colors.grey)
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: _uploadImage,
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      hallName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      email,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueGrey.shade100),
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.blueGrey.shade50,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.teal),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Phone",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              Text(phone,
                                  style: const TextStyle(fontSize: 16, color: Colors.black87)),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _showLogoutConfirmation,
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
