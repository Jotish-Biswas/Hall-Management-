import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApprovalRequestsPage extends StatefulWidget {
  const ApprovalRequestsPage({super.key});

  @override
  State<ApprovalRequestsPage> createState() => _ApprovalRequestsPageState();
}

class _ApprovalRequestsPageState extends State<ApprovalRequestsPage> {
  List<Map<String, dynamic>> unapprovedTeachers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUnapprovedTeachers();
  }

  Future<void> fetchUnapprovedTeachers() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/teachers/unapproved'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          unapprovedTeachers = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch teachers");
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> approveTeacher(String email) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/teachers/approve'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Approved $email")));
        fetchUnapprovedTeachers(); // Refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to approve $email")));
      }
    } catch (e) {
      print("Approval error: $e");
    }
  }

  Future<void> declineTeacher(String email) async {
    try {
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/teachers/decline'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Declined $email")));
        fetchUnapprovedTeachers(); // Refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to decline $email")));
      }
    } catch (e) {
      print("Decline error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Approval Requests"), backgroundColor: Colors.blueGrey),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : unapprovedTeachers.isEmpty
          ? const Center(child: Text("No unapproved teachers found."))
          : ListView.builder(
        itemCount: unapprovedTeachers.length,
        itemBuilder: (context, index) {
          final teacher = unapprovedTeachers[index];
          final extra = teacher['extra'] ?? {};
          final regNo = extra['teacher_reg_no'] ?? "N/A";

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(teacher['full_name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Email: ${teacher['email']}"),
                  Text("Reg No: $regNo"),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => approveTeacher(teacher['email']),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Approve"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => declineTeacher(teacher['email']),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Decline"),
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
