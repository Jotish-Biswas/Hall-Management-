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
  int hoveredIndex = -1;

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
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text("Submit")),
          ],
        );
      },
    );

    if (reg == null || reg.isEmpty) return;

    final url = Uri.parse(
      '$baseUrl/events/$eventId/${asVolunteer ? 'interest' : 'participate'}?hall_name=${Uri.encodeComponent(widget.hallName)}',
    );

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
        fetchEvents(); // Refresh
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
    return gList.any((p) => p['email'] == email) || vList.any((v) => v['student_email'] == email);
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
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(2, 2))],
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.arrow_back, color: Colors.lightBlue, size: 24),
            ),
          ),
        ),
        title: Text("Events - ${widget.hallName}", style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: events.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final maxVol = event['max_volunteers'] ?? 0;
          final currVol = (event['interested_students'] ?? []).length;
          final isFull =  maxVol == 0 || currVol >= maxVol;;
          final userJoined = hasParticipated(event);
          final userVolunteered = hasVolunteered(event);

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => hoveredIndex = index),
            onExit: (_) => setState(() => hoveredIndex = -1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: hoveredIndex == index ? Colors.blue.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
                border: Border.all(
                  color: hoveredIndex == index ? Colors.blue.shade300 : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event['title'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: Colors.blueAccent),
                      const SizedBox(width: 6),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black87, fontSize: 14),
                          children: [
                            const TextSpan(text: 'Date: ', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: event['date']),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.hourglass_bottom, size: 18, color: Colors.orange),
                      const SizedBox(width: 6),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black87, fontSize: 14),
                          children: [
                            const TextSpan(text: 'Expiry: ', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: event['expiry_date'] ?? "N/A"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.volunteer_activism, size: 18, color: Colors.purple),
                      const SizedBox(width: 6),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.deepPurple, fontSize: 14),
                          children: [
                            const TextSpan(text: 'Volunteers: ', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: '$currVol / $maxVol'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.home, size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          children: [
                            const TextSpan(text: 'Hall: ', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: event['hall_name']),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(event['description'] ?? "No description", style: const TextStyle(color: Colors.black87, fontSize: 15)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: userJoined ? null : () => participate(event['id'], false),
                        icon: const Icon(Icons.group),
                        label: const Text("Participate"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: userJoined ? Colors.grey : Colors.blue,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: (userVolunteered || isFull) ? null : () => participate(event['id'], true),
                        icon: const Icon(Icons.volunteer_activism),
                        label: const Text("Volunteer"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          (userVolunteered || isFull) ? Colors.grey : Colors.deepPurpleAccent.shade100,
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
