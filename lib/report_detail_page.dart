import 'package:flutter/material.dart';
import 'report_page.dart'; // if Notice model is there

class ReportDetailPage extends StatelessWidget {
  final Report report;
  const ReportDetailPage({super.key, required this.report});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Details"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),
            Text(
              "Posted by : ${report.email}",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              "Posted on: ${report.timestamp.toLocal().toString().split(' ')[0]}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Divider(height: 20),
            Text(
              report.message,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
