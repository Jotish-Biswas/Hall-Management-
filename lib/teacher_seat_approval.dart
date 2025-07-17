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
  final List<Color> gradientColors = [
    const Color(0xFF0F2027),
    const Color(0xFF203A43),
    const Color(0xFF2C5364),
  ];

  @override
  void initState() {
    super.initState();
    fetchApplications();
  }

  Future<void> fetchApplications() async {
    try {
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
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
          "hall_name": widget.hallname,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          applications.removeWhere((app) => app["_id"] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ Application $status"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ ${error['detail']}"),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }

  Widget buildApplicationCard(Map<String, dynamic> app) {
    final student = app["student_info"] ?? {};
    final hallName = app["hall_name"] ?? "Unknown Hall";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hall Name Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.house, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 6),
                  Text(
                    hallName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Student Info Section
            _buildInfoRow(Icons.email, "Email", app["student_email"]),
            _buildInfoRow(Icons.person, "Name", student["full_name"] ?? "N/A"),
            _buildInfoRow(Icons.confirmation_number, "Roll", student["roll_no"] ?? "N/A"),
            _buildInfoRow(Icons.school, "Department", student["department"] ?? "N/A"),
            _buildInfoRow(Icons.calendar_today, "Session", student["session"] ?? "N/A"),
            
            const SizedBox(height: 16),
            
            // Reason Section
            Text(
              "Application Reason:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              app["reason"] ?? "",
              style: TextStyle(color: Colors.grey[800]),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  "Approve",
                  Colors.green,
                  Icons.check,
                  () => updateApplicationStatus(app["_id"], "approved"),
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  "Decline",
                  Colors.redAccent,
                  Icons.close,
                  () => updateApplicationStatus(app["_id"], "declined"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      icon: Icon(icon, size: 18),
      label: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: Colors.blueAccent, size: 26),
            ),
          ),
        ),
        title: Text(
          "Seat Approvals - ${widget.hallname}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          : applications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: Colors.green[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No Pending Applications",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "All applications have been processed",
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchApplications,
                  color: Colors.blue,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                    itemCount: applications.length,
                    itemBuilder: (context, index) => buildApplicationCard(applications[index]),
                  ),
                ),
    );
  }
}