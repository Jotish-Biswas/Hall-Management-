import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProvostProfilePage extends StatefulWidget {
  const ProvostProfilePage({super.key});

  @override
  State<ProvostProfilePage> createState() => _ProvostProfilePageState();
}

class _ProvostProfilePageState extends State<ProvostProfilePage> {
  String name = 'Dr. Dip Bhattacharya';
  final String email = 'dipbhat03@gmail.com'; // Fixed email
  String dept = 'CSE';
  String phone = '017XXXXXXXX';
  String address = 'Provost Office, Hall Building';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileFromPrefs();
  }

  Future<void> _loadProfileFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString('provost_name') ?? name;
      phone = prefs.getString('provost_phone') ?? phone;
      address = prefs.getString('provost_address') ?? address;
      dept = prefs.getString('provost_dept') ?? dept;
      isLoading = false;
    });
  }

  Future<void> _saveProfileToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('provost_name', name);
    await prefs.setString('provost_phone', phone);
    await prefs.setString('provost_address', address);
    await prefs.setString('provost_dept', dept);
  }

  void _editProfile(BuildContext context) {
    final nameController = TextEditingController(text: name);
    final phoneController = TextEditingController(text: phone);
    final addressController = TextEditingController(text: address);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                name = nameController.text.trim();
                phone = phoneController.text.trim();
                address = addressController.text.trim();
              });

              await _saveProfileToPrefs();

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile updated locally")),
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
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
        title: const Text("Provost Profile"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editProfile(context),
          )
        ],
      ),
      backgroundColor: Colors.teal[50],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(email, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.school, color: Colors.blue),
              title: const Text("Department"),
              subtitle: Text(dept),
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
      ),
    );
  }
}
