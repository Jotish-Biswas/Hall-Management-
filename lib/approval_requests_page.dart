import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ServerLink.dart';

class ApprovalRequestsPage extends StatefulWidget {
  final String hallname;
  const ApprovalRequestsPage({super.key, required this.hallname});

  @override
  State<ApprovalRequestsPage> createState() => _ApprovalRequestsPageState();
}

class _ApprovalRequestsPageState extends State<ApprovalRequestsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> teachers = [];
  List<Map<String, dynamic>> shopkeepers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchAllUnapproved();
  }

  Future<void> fetchAllUnapproved() async {
    setState(() => isLoading = true);

    try {
      // Correct endpoint with hall_name query parameter
      final uri = Uri.parse(
        '$baseUrl/admin/unapproved?hall_name=${Uri.encodeComponent(widget.hallname)}',
      );

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> userList = data['users'];

        setState(() {
          students = userList
              .where((u) => u['role'] == 'Student')
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
          teachers = userList
              .where((u) => u['role'] == 'Teacher')
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
          shopkeepers = userList
              .where((u) => u['role'] == 'Shopkeeper')
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
        });
      } else {
        print("Fetch failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching users: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> approveUser(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/approve'),  // Admin endpoint
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Approved $email")));
        fetchAllUnapproved();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to approve $email")));
      }
    } catch (e) {
      print("Approval error: $e");
    }
  }

  Future<void> declineUser(String email) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/decline'),  // Admin endpoint
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Declined $email")));
        fetchAllUnapproved();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to decline $email")));
      }
    } catch (e) {
      print("Decline error: $e");
    }
  }

  Widget buildUserList(List<Map<String, dynamic>> users, String role) {
    if (users.isEmpty) return Center(child: Text("No unapproved $role found."));

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final extra = user['extra'] ?? {};

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
                ] else if (role == "Teacher") ...[
                  Text("Reg No: ${extra['teacher_reg_no'] ?? 'N/A'}"),
                  Text("Department: ${extra['department'] ?? 'N/A'}"),
                ] else if (role == "Shopkeeper") ...[
                  Text("Shop Type: ${extra['shop_type'] ?? 'N/A'}"),
                  Text("Phone: ${extra['phone'] ?? 'N/A'}"),
                ]
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => approveUser(user['email']),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Approve"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => declineUser(user['email']),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Decline"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Approval Requests"),
        backgroundColor: Colors.lightGreenAccent,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Students"),
            Tab(text: "Teachers"),
            Tab(text: "Shopkeepers"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          buildUserList(students, "Student"),
          buildUserList(teachers, "Teacher"),
          buildUserList(shopkeepers, "Shopkeeper"),
        ],
      ),
    );
  }
}
