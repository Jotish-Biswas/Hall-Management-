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

class _ApprovalRequestsPageState extends State<ApprovalRequestsPage> 
    with SingleTickerProviderStateMixin {
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
        Uri.parse('$baseUrl/admin/approve'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Approved $email"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        fetchAllUnapproved();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to approve $email"),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    } catch (e) {
      print("Approval error: $e");
    }
  }

  Future<void> declineUser(String email) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/decline'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Declined $email"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        fetchAllUnapproved();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to decline $email"),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    } catch (e) {
      print("Decline error: $e");
    }
  }

  Widget buildUserList(List<Map<String, dynamic>> users, String role) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          "No unapproved $role found",
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final extra = user['extra'] ?? {};

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['full_name'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Email: ${user['email']}",
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                
                if (role == "Student") ...[
                  _buildDetailRow("Department", extra['department'] ?? 'N/A'),
                  _buildDetailRow("Session", extra['session'] ?? 'N/A'),
                ] else if (role == "Teacher") ...[
                  _buildDetailRow("Reg No", extra['teacher_reg_no'] ?? 'N/A'),
                  _buildDetailRow("Department", extra['department'] ?? 'N/A'),
                ] else if (role == "Shopkeeper") ...[
                  _buildDetailRow("Shop Type", extra['shop_type'] ?? 'N/A'),
                  _buildDetailRow("Phone", extra['phone'] ?? 'N/A'),
                ],
                
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(
                      "Approve",
                      Colors.green,
                      Icons.check,
                      () => approveUser(user['email']),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      "Decline",
                      Colors.red,
                      Icons.close,
                      () => declineUser(user['email']),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[800])),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      icon: Icon(icon, size: 18),
      label: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Approval Requests",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: "Students"),
            Tab(text: "Teachers"),
            Tab(text: "Shopkeepers"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
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