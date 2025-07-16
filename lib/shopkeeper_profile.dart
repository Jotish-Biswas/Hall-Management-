import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'image_picker_helper.dart';
import 'ServerLink.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopkeeperProfilePage extends StatefulWidget {
  final String email;
  final String hallname;

  const ShopkeeperProfilePage({
    super.key,
    required this.email,
    required this.hallname,
  });

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
    final url = Uri.parse('$baseUrl/shopkeeper/$encodedEmail');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load shopkeeper profile');
    }
  }

  Future<void> _uploadImage() async {
    final success = await getImagePicker().pickAndUploadImage(
      email: widget.email,
      baseUrl: baseUrl,
      context: context,
      userType: 'shopkeeper',
      onSuccess: () {
        setState(() {
          shopkeeperData = fetchShopkeeperProfile(widget.email);
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Shopkeeper Profile"),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            tooltip: "Upload Profile Picture",
            onPressed: _uploadImage,
          ),
        ],
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
          final hall = data['hall_name'] ?? widget.hallname;

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
                        ListTile(
                          leading: const Icon(Icons.location_city, color: Colors.deepOrange),
                          title: Text("Hall Name: $hall"),
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
