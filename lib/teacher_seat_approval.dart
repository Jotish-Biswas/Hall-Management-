import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ServerLink.dart';

class ApprovalPage extends StatefulWidget {
  final String teacherEmail;
  final String hallname;

  const ApprovalPage({
    super.key,
    required this.teacherEmail,
    required this.hallname
  });

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  List<Map<String, dynamic>> applications = [];
  bool isLoading = true;
  final String baseUrll = "$baseUrl/api/seat";

  @override
  void initState() {
    super.initState();
    fetchApplications();
  }

  Future<void> fetchApplications() async {
    try {
      // Add hallname as query parameter
      final uri = Uri.parse("$baseUrll/get-all-applications")
          .replace(queryParameters: {"hall_name": widget.hallname});

      final response = await http.get(uri);

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Future<void> updateApplicationStatus(String id, String status) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrll/update-application-status/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "status": status,
          "processed_by": widget.teacherEmail,
          "hall_name": widget.hallname, // Added hall_name
        }),
      );

      if (response.statusCode == 200) {
        // Remove the application from the list
        setState(() {
          applications.removeWhere((app) => app["_id"] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Application $status")),
        );
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ ${error['detail']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Widget buildApplicationCard(Map<String, dynamic> app) {
    final student = app["student_info"] ?? {};
    final hallName = app["hall_name"] ?? "Unknown Hall";

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display hall name
            Row(
              children: [
                const Icon(Icons.house, size: 16, color: Colors.blue),
                const SizedBox(width: 5),
                Text(
                  hallName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text("📧 ${app["student_email"]}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("👤 Name: ${student["full_name"] ?? "N/A"}"),
            Text("🎓 Roll: ${student["roll_no"] ?? "N/A"}"),
            Text("📚 Department: ${student["department"] ?? "N/A"}"),
            Text("🗓 Session: ${student["session"] ?? "N/A"}"),
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
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => updateApplicationStatus(app["_id"], "declined"),
                  icon: const Icon(Icons.close),
                  label: const Text("Decline"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white
                  ),
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
        title: Text("Seat Approvals - ${widget.hallname}"),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : applications.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text("No pending applications", style: TextStyle(fontSize: 18)),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchApplications,
        child: ListView.builder(
          itemCount: applications.length,
          itemBuilder: (context, index) => buildApplicationCard(applications[index]),
        ),
      ),
    );
  }
}