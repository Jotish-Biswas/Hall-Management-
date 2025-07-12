import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TeacherApprovalPage extends StatefulWidget {
  final String hallName; // Add hallName parameter
  const TeacherApprovalPage({super.key, required this.hallName});

  @override
  State<TeacherApprovalPage> createState() => _TeacherApprovalPageState();
}

class _TeacherApprovalPageState extends State<TeacherApprovalPage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> unapprovedStudents = [];
  List<Map<String, dynamic>> unapprovedShopkeepers = [];
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);
    await Future.wait([
      fetchByRole("Student"),
      fetchByRole("Shopkeeper"),
    ]);
    setState(() => isLoading = false);
  }

  Future<void> fetchByRole(String role) async {
    try {
      final response = await http.get(Uri.parse(
          'http://127.0.0.1:8000/teachers/unapproved/forteacher?role=$role&hall_name=${widget.hallName}'
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = List<Map<String, dynamic>>.from(data['users']);

        setState(() {
          if (role == "Student") unapprovedStudents = users;
          else if (role == "Shopkeeper") unapprovedShopkeepers = users;
        });
      }
    } catch (e) {
      print("Fetch error: $e");
    }
  }

  Future<void> approve(String email, String role) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/teachers/approve'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "hall_name": widget.hallName, // Pass hall name
        "role": role // Pass role for backend verification
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Approved $email"))
      );
      fetchUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Approval failed: ${response.body}"))
      );
    }
  }

  Future<void> decline(String email, String role) async {
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/teachers/decline'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "hall_name": widget.hallName, // Pass hall name
        "role": role // Pass role for backend verification
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Declined $email"))
      );
      fetchUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Decline failed: ${response.body}"))
      );
    }
  }

  Widget userCard(Map<String, dynamic> user, String role) {
    final extra = user["extra"] ?? {};
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: Text(user['full_name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email: ${user['email']}"),
            Text("Role: $role"),
            Text("Hall: ${user['hall_name'] ?? widget.hallName}"),
            const SizedBox(height: 8),
            if (role == "Student") ...[
              Text("Department: ${extra['department'] ?? 'N/A'}"),
              Text("Session: ${extra['session'] ?? 'N/A'}"),
            ] else if (role == "Shopkeeper") ...[
              Text("Shop Type: ${extra['shop_type'] ?? 'N/A'}"),
              Text("Phone: ${extra['phone'] ?? 'N/A'}"),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => approve(user['email'], role),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Approve"),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => decline(user['email'], role),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Decline"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Approve Users in ${widget.hallName}"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Students"),
            Tab(text: "Shopkeepers"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          // Show message if no students
          if (unapprovedStudents.isEmpty)
            const Center(child: Text("No pending student applications"))
          else
            ListView(children: unapprovedStudents.map((u) => userCard(u, "Student")).toList()),

          // Show message if no shopkeepers
          if (unapprovedShopkeepers.isEmpty)
            const Center(child: Text("No pending shopkeeper applications"))
          else
            ListView(children: unapprovedShopkeepers.map((u) => userCard(u, "Shopkeeper")).toList()),
        ],
      ),
    );
  }
}