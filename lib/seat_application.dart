import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ServerLink.dart';

class SeatApplication extends StatefulWidget {
  final String studentEmail;
  final String hallname; // Received from previous screen

  const SeatApplication({
    super.key,
    required this.studentEmail,
    required this.hallname
  });

  @override
  _SeatApplicationState createState() => _SeatApplicationState();
}

class _SeatApplicationState extends State<SeatApplication> {
  final TextEditingController reasonController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hall Seat Application")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Applying for seat in: ${widget.hallname}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for application',
                border: OutlineInputBorder(),
                hintText: 'Explain why you need a seat...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : applyForSeat,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit Application"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> applyForSeat() async {
    const url = '$baseUrl/api/seat/apply-for-seat';

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "student_email": widget.studentEmail,
          "hall_name": widget.hallname, // Pass hallname to backend
          "reason": reasonController.text.isNotEmpty
              ? reasonController.text
              : "I need accommodation",
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody['message'])),
        );
        // Close application screen after successful submission
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody['detail'] ?? "Application failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection error: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}