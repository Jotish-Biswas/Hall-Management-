import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SeatApplication extends StatefulWidget {
  final String studentEmail;

  const SeatApplication({
    super.key,
    required this.studentEmail,
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
      appBar: AppBar(title: const Text("Hall form")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason of application',
                border: OutlineInputBorder(),
                hintText: 'Seat needed',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : applyForSeat,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit"),
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
    const url = 'http://127.0.0.1:8000/api/seat/apply-for-seat'; // Added prefix

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "student_email": widget.studentEmail,
          "reason": reasonController.text.isNotEmpty
              ? reasonController.text
              : "Seat needed",
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? "Apply succesfull")),
        );
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['detail'] ?? "error: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("server not found: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}