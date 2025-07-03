import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/users'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          users = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch users");
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteUser(String email) async {
    try {
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/users/delete'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Deleted $email")),
        );
        fetchUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete $email")),
        );
      }
    } catch (e) {
      print("Delete error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User List"), backgroundColor: Colors.blueGrey),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? const Center(child: Text("No users found."))
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(user['full_name']),
              subtitle: Text("Role: ${user['role']}  •  Email: ${user['email']}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteUser(user['email']),
              ),
            ),
          );
        },
      ),
    );
  }
}
