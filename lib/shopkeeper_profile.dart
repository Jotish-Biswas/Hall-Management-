import 'dart:convert';
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
  print("Fetching shopkeeper profile for email: $email");
  final encodedEmail = Uri.encodeComponent(email);
  final url = Uri.parse('http://127.0.0.1:8000/shopkeeper/$encodedEmail');
  print("Constructed URL: $url");

  final response = await http.get(url);
  print("Response status code: ${response.statusCode}");
  print("Response body: ${response.body}");

  if (response.statusCode == 200) {
    try {
      final data = jsonDecode(response.body);
      print("Parsed JSON data: $data");
      return data;
    } catch (e) {
      print("JSON parsing error: $e");
      throw Exception('Failed to parse profile data');
    }
  } else if (response.statusCode == 404) {
    print("Shopkeeper not found for email: $email");
    throw Exception('Shopkeeper not found');
  } else {
    print("Server error with status: ${response.statusCode}");
    throw Exception('Server error: ${response.statusCode}');
  }
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
        title: const Text("Shopkeeper Profile"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.blue[50],
      body: FutureBuilder<Map<String, dynamic>>(
        future: shopkeeperData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No profile data found.'));
          }

          final data = snapshot.data!;
          final name = data['name'] ?? 'No Name';
          final email = data['email'] ?? 'No Email';
          final phone = data['phone'] ?? 'No Phone';
          final shopName = data['shop_name'] ?? 'No Shop Name';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Uncomment below to add profile image
                // const CircleAvatar(
                //   radius: 60,
                //   backgroundImage: AssetImage('assets/shopkeeper_profile_pic.png'),
                // ),
                // const SizedBox(height: 20),

                Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(email, style: const TextStyle(fontSize: 16, color: Colors.black)),
                const SizedBox(height: 20),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.blue),
                  title: const Text("Phone"),
                  subtitle: Text(phone),
                ),
                ListTile(
                  leading: const Icon(Icons.store, color: Colors.blue),
                  title: const Text("Shop Name"),
                  subtitle: Text(shopName),
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
