import 'dart:convert';
import 'dart:html' as html; // Only for Flutter Web
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShopkeeperProfilePage extends StatefulWidget {
  final String email;

  const ShopkeeperProfilePage({super.key, required this.email});

  @override
  State<ShopkeeperProfilePage> createState() => _ShopkeeperProfilePageState();
}

class _ShopkeeperProfilePageState extends State<ShopkeeperProfilePage> {
  late Future<Map<String, dynamic>> shopkeeperData;

  @override
  void initState() {
    super.initState();
    shopkeeperData = fetchShopkeeperProfile(widget.email);
  }

  Future<Map<String, dynamic>> fetchShopkeeperProfile(String email) async {
    final encodedEmail = Uri.encodeComponent(email);
    final url = Uri.parse('http://127.0.0.1:8000/shopkeeper/$encodedEmail');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load shopkeeper profile');
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

        final url = Uri.parse(
            'http://127.0.0.1:8000/shopkeeper/${Uri.encodeComponent(widget.email)}/upload-image');

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'image_base64': encodedImage}),
        );

        if (response.statusCode == 200) {
          setState(() {
            shopkeeperData = fetchShopkeeperProfile(widget.email);
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
        title: const Text("Shopkeeper Profile"),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: shopkeeperData,
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
          final phone = data['phone'] ?? 'No Phone';
          final shopName = data['shop_name'] ?? 'No Shop Name';
          final profileImage = data['profile_image'];

          return Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
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
                          icon: const Icon(Icons.camera_alt, color: Colors.deepOrange),
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
                          leading: const Icon(Icons.phone, color: Colors.deepOrange),
                          title: Text("Phone: $phone"),
                        ),
                        ListTile(
                          leading: const Icon(Icons.store, color: Colors.deepOrange),
                          title: Text("Shop Name: $shopName"),
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
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
