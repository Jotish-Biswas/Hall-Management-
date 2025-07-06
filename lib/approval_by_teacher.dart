import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TeacherApprovalPage extends StatefulWidget {
  const TeacherApprovalPage({super.key});

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
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/teachers/unapproved/forteacher?role=$role'));
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

  Future<void> approve(String email) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/teachers/approve'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode == 200) {
      print(response.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Approved $email")));
      fetchUsers();
    } else {
      print(response.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Approval failed for $email")));
    }
  }

  Future<void> decline(String email) async {
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/teachers/decline'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Declined $email")));
      fetchUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Decline failed for $email")));
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
              onPressed: () => approve(user['email']),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Approve"),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => decline(user['email']),
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
        title: const Text("Approve Students & Shopkeepers"),
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
          ListView(children: unapprovedStudents.map((u) => userCard(u, "Student")).toList()),
          ListView(children: unapprovedShopkeepers.map((u) => userCard(u, "Shopkeeper")).toList()),
        ],
      ),
    );
  }
}
