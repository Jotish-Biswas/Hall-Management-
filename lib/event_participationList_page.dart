import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ServerLink.dart';

class AdminEventParticipationPage extends StatefulWidget {
  final String hallName;

  const AdminEventParticipationPage({super.key, required this.hallName});

  @override
  State<AdminEventParticipationPage> createState() => _AdminEventParticipationPageState();
}

class _AdminEventParticipationPageState extends State<AdminEventParticipationPage> {
  List<dynamic> events = [];
  Map<String, dynamic> participationData = {};
  String selectedEventId = '';

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final url = Uri.parse('$baseUrl/events?hall_name=${widget.hallName}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          events = jsonDecode(response.body);
          // Clear participation data when events are refreshed
          participationData = {};
          selectedEventId = '';
        });
      } else {
        showError("Failed to load events: ${response.statusCode}");
      }
    } catch (e) {
      showError("Error loading events: $e");
    }
  }

  Future<void> fetchParticipants(String eventId) async {
    final url = Uri.parse('$baseUrl/events/$eventId?hall_name=${widget.hallName}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          selectedEventId = eventId;
          participationData = data;
        });
      } else {
        showError("Failed to load participants: ${response.statusCode}");
      }
    } catch (e) {
      showError("Error loading participants: $e");
    }
  }

  Future<void> _deleteEvent(String eventId) async {
    final url = Uri.parse('$baseUrl/events/$eventId?hall_name=${widget.hallName}');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        showMessage("Event deleted successfully");
        await fetchEvents();
        setState(() {
          participationData = {};
          selectedEventId = '';
        });
      } else {
        final data = jsonDecode(response.body);
        showMessage(data['detail'] ?? 'Failed to delete event');
      }
    } catch (e) {
      showMessage("Error: $e");
    }
  }

  void _confirmDelete(String eventId, String eventTitle) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete '$eventTitle'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteEvent(eventId);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildParticipationList() {
    final volunteers = participationData['interested_students'] ?? [];
    final general = participationData['general_participants'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          "Volunteers (${volunteers.length}):",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ...volunteers.map<Widget>((v) => ListTile(
          leading: const Icon(Icons.volunteer_activism, color: Colors.deepPurple),
          title: Text(v['student_name'] ?? 'Unknown'),
          subtitle: Text("Reg: ${v['registration']} | Email: ${v['student_email']}"),
        )),
        const SizedBox(height: 10),
        Text(
          "General Participants (${general.length}):",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ...general.map<Widget>((p) => ListTile(
          leading: const Icon(Icons.group, color: Colors.teal),
          title: Text(p['name'] ?? 'Unknown'),
          subtitle: Text("Reg: ${p['registration']} | Email: ${p['email']}"),
        )),
      ],
    );
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
                color: const Color.fromARGB(255, 154, 151, 151),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.arrow_back, color: Colors.lightBlue, size: 24),
            ),
          ),
        ),
        title: Text("Event Participation - ${widget.hallName}", style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: events.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Events for ${widget.hallName}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ),
          ...events.map((event) {
            final isSelected = selectedEventId == event['id'];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(event['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Date: ${event['date']}"),
                    Text("Expire: ${event['expiry_date']}"),
                    Text("Hall: ${event['hall_name']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () => fetchParticipants(event['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? Colors.deepPurple : Colors.lightBlue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Participants"),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(event['id'], event['title']),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (participationData.isNotEmpty) const Divider(thickness: 1.5),
          if (participationData.isNotEmpty) _buildParticipationList(),
        ],
      ),
    );
  }
}
