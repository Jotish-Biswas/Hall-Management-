import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final String email;

  const ProfilePage({super.key, required this.email});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  String? error;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Use 10.0.2.2 for Android emulator; change if using real device or iOS simulator
      final url = Uri.parse("http://10.0.2.2:8000/users/profile?email=${widget.email}");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          profileData = data;
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Failed to load profile";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Error: $e";
        isLoading = false;
      });
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await uploadImage(_imageFile!);
    }
  }

  Future<void> uploadImage(File image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse("http://10.0.2.2:8000/users/profile/upload-image"),
    );
    request.fields['email'] = widget.email;
    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      await fetchProfile(); // reload profile data with new image
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: pickImage,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: profileData == null
            ? const Text("No profile data")
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : (profileData != null &&
                    profileData!['image_url'] != null
                    ? NetworkImage(profileData!['image_url'])
                    : const AssetImage("assets/default_avatar.png"))
                as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            Text("Name: ${profileData!['full_name'] ?? 'N/A'}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Email: ${profileData!['email'] ?? 'N/A'}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Role: ${profileData!['role'] ?? 'N/A'}",
                style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
