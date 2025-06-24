import 'package:flutter/material.dart';


class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'Could not launch email';
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
      // Optional: Show error to user
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Could not launch email app')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Our Team',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildTeamCard(
              context,
              name: 'Dipta',
              role: 'Team Leader',
              email: 'dipta@gmail.com',
              imageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
            ),
            const SizedBox(height: 16),
            _buildTeamCard(
              context,
              name: 'Nadim Mahmud',
              role: 'Developer',
              email: 'nadim@gmail.com',
              imageUrl: 'https://randomuser.me/api/portraits/women/1.jpg',
            ),
            const SizedBox(height: 16),
            _buildTeamCard(
              context,
              name: 'Tamal',
              role: 'Developer',
              email: 'tamal@gmail.com',
              imageUrl: 'https://randomuser.me/api/portraits/men/2.jpg',
            ),
            const SizedBox(height: 16),
            _buildTeamCard(
              context,
              name: 'Jotish',
              role: 'Developer',
              email: 'jotish@gmail.com',
              imageUrl: 'https://randomuser.me/api/portraits/men/2.jpg',
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard(
      BuildContext context, {
        required String name,
        required String role,
        required String email,
        required String imageUrl,
      }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(imageUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _launchEmail(email),
                    child: Text(
                      email,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  canLaunchUrl(Uri emailUri) {}

  launchUrl(Uri emailUri) {}
}