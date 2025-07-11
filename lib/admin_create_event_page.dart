import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminCreateEventPage extends StatefulWidget {
  const AdminCreateEventPage({super.key});

  @override
  State<AdminCreateEventPage> createState() => _AdminCreateEventPageState();
}

class _AdminCreateEventPageState extends State<AdminCreateEventPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController maxVolunteersController = TextEditingController();

  Future<void> _pickDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        controller.text =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submitEvent() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final eventDate = eventDateController.text.trim();
    final expiryDate = expiryDateController.text.trim();
    final maxVolunteersStr = maxVolunteersController.text.trim();

    if (title.isEmpty ||
        description.isEmpty ||
        eventDate.isEmpty ||
        expiryDate.isEmpty ||
        maxVolunteersStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields.")),
      );
      return;
    }

    int? maxVolunteers = int.tryParse(maxVolunteersStr);
    if (maxVolunteers == null || maxVolunteers <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum volunteers must be a positive number.")),
      );
      return;
    }

    // Optionally: Validate that expiryDate <= eventDate here if needed

    final url = Uri.parse('http://127.0.0.1:8000/events');
    final payload = {
      "title": title,
      "description": description,
      "date": eventDate,
      "expiry_date": expiryDate,  // New expiry date field
      "created_by": "admin@du.edu.bd", // Replace with real admin email if dynamic
      "max_volunteers": maxVolunteers,
      "interested_students": [],
      "general_participants": [], // If backend supports this field
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event created successfully!")),
        );
        titleController.clear();
        descriptionController.clear();
        eventDateController.clear();
        expiryDateController.clear();
        maxVolunteersController.clear();
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${error['detail']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Event"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // To prevent overflow if keyboard appears
          child: Column(
            children: [
              _buildTextField("Event Title", titleController),
              _buildTextField("Description", descriptionController, maxLines: 3),
              GestureDetector(
                onTap: () => _pickDate(eventDateController),
                child: AbsorbPointer(
                  child: TextField(
                    controller: eventDateController,
                    decoration: const InputDecoration(
                      labelText: "Event Date",
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _pickDate(expiryDateController),
                child: AbsorbPointer(
                  child: TextField(
                    controller: expiryDateController,
                    decoration: const InputDecoration(
                      labelText: "Participation Expiry Date",
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField("Maximum Volunteers", maxVolunteersController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _submitEvent,
                icon: const Icon(Icons.send),
                label: const Text("Create Event"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
