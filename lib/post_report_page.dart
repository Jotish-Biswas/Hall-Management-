import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PostReportPage extends StatefulWidget {
  final String email;
  const PostReportPage({super.key, required this.email});

  @override
  State<PostReportPage> createState() => _PostReportPageState();
}

class _PostReportPageState extends State<PostReportPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  bool isPosting = false;

  Future<void> postReport() async {
    final title = titleController.text.trim();
    final message = messageController.text.trim();


    if (title.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in both fields.")),
      );
      return;
    }

    setState(() => isPosting = true);

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/reports/post"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email":widget.email, "title": title, "message": message}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Report posted successfully")),
        );
        titleController.clear();
        messageController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.body}")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred.")),
      );
    }

    setState(() => isPosting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Report "),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Report Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Report Message",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isPosting ? null : postReport,
              icon: const Icon(Icons.send),
              label: const Text("Post Notice"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
