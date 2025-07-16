import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ServerLink.dart';

class StudentEventPage extends StatefulWidget {
  final String studentName;
  final String studentEmail;
  final String hallName;

  const StudentEventPage({
    super.key,
    required this.studentName,
    required this.studentEmail,
    required this.hallName,
  });

  @override
  State<StudentEventPage> createState() => _StudentEventPageState();
}

class _StudentEventPageState extends State<StudentEventPage> {
  List<dynamic> events = [];

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final url = Uri.parse('$baseUrl/events?hall_name=${Uri.encodeComponent(widget.hallName)}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          events = jsonDecode(response.body);
        });
      } else {
        showError("Failed to load events: ${response.statusCode}");
      }
    } catch (e) {
      showError("Error fetching events: $e");
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> participate(String eventId, bool asVolunteer) async {
    final name = widget.studentName;
    final email = widget.studentEmail;

    final reg = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Enter Registration Number'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Registration Number"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );

    if (reg == null || reg.isEmpty) return;

    final baseUrll = '$baseUrl/events/$eventId';
    final queryParam = '?hall_name=${Uri.encodeComponent(widget.hallName)}';

    final url = Uri.parse(asVolunteer
        ? '$baseUrll/interest$queryParam'
        : '$baseUrll/participate$queryParam'); // FIXED ENDPOINT

    final body = jsonEncode(asVolunteer
        ? {
      "student_name": name,
      "student_email": email,
      "registration": reg,
    }
        : {
      "name": name,
      "email": email,
      "registration": reg,
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Participation successful!")),
        );
        fetchEvents(); // Refresh event list
      } else {
        try {
          final data = jsonDecode(response.body);
          final errorDetail = data['detail'] ?? "Failed to participate";
          showError(errorDetail);
        } catch (e) {
          showError("Failed to participate: ${response.body}");
        }
      }
    } catch (e) {
      showError("Connection error: $e");
    }
  }

  bool hasParticipated(event) {
    final email = widget.studentEmail;
    final gList = event['general_participants'] ?? [];
    final vList = event['interested_students'] ?? [];

    return gList.any((p) => p['email'] == email) ||
        vList.any((v) => v['student_email'] == email);
  }

  bool hasVolunteered(event) {
    final email = widget.studentEmail;
    final vList = event['interested_students'] ?? [];
    return vList.any((v) => v['student_email'] == email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Events - ${widget.hallName}"),
        backgroundColor: Colors.blue,
      ),
      body: events.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final maxVol = event['max_volunteers'] ?? 0;
          final currVol = (event['interested_students'] ?? []).length;
          final isFull = currVol >= maxVol;
          final userJoined = hasParticipated(event);
          final userVolunteered = hasVolunteered(event);

          return Card(
            margin: const EdgeInsets.all(10),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event['title'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("Date: ${event['date']}"),
                  Text("Expire: ${event['expiry_date'] ?? "N/A"}"),
                  Text(
                    "Volunteers: $currVol / $maxVol",
                    style: const TextStyle(color: Colors.deepPurple),
                  ),
                  Text(
                    "Hall: ${event['hall_name']}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(event['description'] ?? "No description",
                      style: const TextStyle(color: Colors.black87)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: userJoined
                            ? null
                            : () => participate(event['id'], false),
                        icon: const Icon(Icons.group),
                        label: const Text("Participate"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: userJoined ? Colors.grey : Colors.white,
                        ),
                      ),
                      isFull
                          ? const Text(
                        "No Volunteer Needed",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      )
                          : ElevatedButton.icon(
                        onPressed: userJoined
                            ? null
                            : () => participate(event['id'], true),
                        icon: const Icon(Icons.volunteer_activism),
                        label: const Text("Volunteer"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: userJoined
                              ? Colors.grey
                              : Colors.deepPurple[50],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
