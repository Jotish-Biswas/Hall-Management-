import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApprovalPage extends StatefulWidget {
  final String teacherEmail;

  const ApprovalPage({super.key, required this.teacherEmail});

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  List<Map<String, dynamic>> applications = [];
  bool isLoading = true;
  final String baseUrl = "http://127.0.0.1:8000/api/seat"; // Added prefix

  @override
  void initState() {
    super.initState();
    fetchApplications();
  }

  Future<void> fetchApplications() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/get-all-applications"));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          applications = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load applications: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("❌ Error fetching applications: $e");
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Future<void> updateApplicationStatus(String id, String status) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/update-application-status/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "status": status,
          "processed_by": widget.teacherEmail,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          applications.removeWhere((app) => app["_id"] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Application $status")),
        );
      } else {
        print("❌ Failed to update status: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update: ${response.body}")),
        );
      }
    } catch (e) {
      print("❌ Exception while updating status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Widget buildApplicationCard(Map<String, dynamic> app) {
    final student = app["student_info"] ?? {};

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📧 ${app["student_email"]}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("👤 Name: ${student["full_name"] ?? "N/A"}"),
            Text("🎓 Roll: ${student["roll_no"] ?? "N/A"}"),
            Text("📚 Department: ${student["department"] ?? "N/A"}"),
            Text("🗓 Session: ${student["session"] ?? "N/A"}"),
            Text("📝 Registration No: ${student["registration_no"] ?? "N/A"}"),
            Text("🎂 DOB: ${student["dob"] ?? "N/A"}"),
            const SizedBox(height: 8),
            Text("📝 Reason: ${app["reason"] ?? ""}"),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => updateApplicationStatus(app["_id"], "approved"),
                  icon: const Icon(Icons.check),
                  label: const Text("Approve"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => updateApplicationStatus(app["_id"], "declined"),
                  icon: const Icon(Icons.close),
                  label: const Text("Decline"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seat Approval Requests"),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : applications.isEmpty
          ? const Center(child: Text("🎉 No pending applications"))
          : ListView.builder(
        itemCount: applications.length,
        itemBuilder: (context, index) => buildApplicationCard(applications[index]),
      ),
    );
  }
}