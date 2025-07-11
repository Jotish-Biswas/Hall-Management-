import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  final String studentEmail;

  const ChatPage({super.key, required this.studentEmail});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<dynamic> messages = [];
  final TextEditingController _controller = TextEditingController();
  final String baseUrl = "http://127.0.0.1:8000";

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchMessages();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchMessages();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchMessages() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/chat/messages"));
      if (response.statusCode == 200) {
        setState(() {
          messages = json.decode(response.body);
        });
      }
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final msg = _controller.text.trim();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/chat/send-message"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "student_email": widget.studentEmail,
          "message": msg,
        }),
      );

      if (response.statusCode == 200) {
        _controller.clear();
        fetchMessages();
      } else {
        print("Failed to send message: ${response.body}");
      }
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  // Helper to extract username from email
  String _getUsername(String email) {
    return email.split('@').first;
  }

  // Format timestamp for display
  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return timestamp.length > 16 ? timestamp.substring(11, 16) : timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Community Chat")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: false,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return ListTile(
                  title: Text(_getUsername(msg["student_email"])),
                  subtitle: Text(msg["message"]),
                  trailing: Text(_formatTimestamp(msg["timestamp"])),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: "Write message..."),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}