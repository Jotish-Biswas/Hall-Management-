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
              role: 'Developer',
              email: 'dipta@gmail.com',
              imageUrl: 'https://scontent.fdac31-2.fna.fbcdn.net/v/t39.30808-6/504060671_689736527552414_1882365572320882137_n.jpg?_nc_cat=107&ccb=1-7&_nc_sid=6ee11a&_nc_eui2=AeHWz9YOFvhMFQwmA_N96E0o1-xKYgPe6wXX7EpiA97rBXISi0LXlyu9C7QnRFJjsPCrAuMUOuHJeUKQhcxJwJ_v&_nc_ohc=7yheXnjJsYEQ7kNvwF0_7rN&_nc_oc=AdkRNgUPfeeqCenOodWwJD0u4GDwcWwTTbv8oMy5kbqAumKSHYfdkEHvdsHajDJ8Rlw&_nc_zt=23&_nc_ht=scontent.fdac31-2.fna&_nc_gid=nuu8t_NVqgbOfku-gyerfg&oh=00_AfRfXqZO0rAddqPiNu4fscod0hNPb-CPYrjkvpN4NaYl3w&oe=687C3E29',
            ),
            const SizedBox(height: 16),
            _buildTeamCard(
              context,
              name: 'Nadim Mahmud',
              role: 'Developer',
              email: 'nadim@gmail.com',
              imageUrl: 'https://scontent.fdac31-1.fna.fbcdn.net/v/t39.30808-6/503361527_1226212258975107_5929252310696936115_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=6ee11a&_nc_eui2=AeGTZBtOV-A0hQPikniBmNhFxDJbif9Vol_EMluJ_1WiX6PCdAyqNmo6V7BhOLxsvdYoGr5-uN1OPZ2zuzbsBCHD&_nc_ohc=rMEoH9VMVxEQ7kNvwHQB443&_nc_oc=AdnKLxGlz_FSHpaK3AKoxu_TmomFAWEB9pY9TGvTeVX83-818g3qOraa0nvtpIG8UHc&_nc_zt=23&_nc_ht=scontent.fdac31-1.fna&_nc_gid=dFyEf0ysHX6z7I65ZVqZiQ&oh=00_AfReBmEw5XzvtUXeQMynrafI5ASu-kWHoa5oyDauNoypeA&oe=687C240D',
            ),
            const SizedBox(height: 16),
            _buildTeamCard(
              context,
              name: 'Tamal',
              role: 'Developer',
              email: 'tamal@gmail.com',
              imageUrl: 'https://scontent.fdac31-1.fna.fbcdn.net/v/t39.30808-6/475984362_1164573048566231_5267686621254393992_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=cc71e4&_nc_eui2=AeFmWtcou5Fj2IAcFKOw995_TfEU6J3WOvpN8RTondY6-rdFprZbexKjvrh_a8_GuJ3AlaQlsZq97Y1uSqg10KIB&_nc_ohc=YbnoxRB7QOUQ7kNvwE-HPKX&_nc_oc=AdkxxmiBjeAhF0sonU_abjoHDyJX4NkrW2wD9FmRg6Wxfx6iMfwM_YQRUVL7cXkidfg&_nc_zt=23&_nc_ht=scontent.fdac31-1.fna&_nc_gid=VBZcXEP8L3uN4Qu9esVigg&oh=00_AfQt9E9TzE7O9PDS9D3d9ZZ_D6A6CwS0ZnsHBi4beJTMFw&oe=687C3844',
            ),
            const SizedBox(height: 16),
            _buildTeamCard(
              context,
              name: 'Jotish',
              role: 'Developer',
              email: 'jotish@gmail.com',
              imageUrl: 'https://scontent.fdac31-2.fna.fbcdn.net/v/t39.30808-6/482225901_642037672097256_3730515934046412776_n.jpg?_nc_cat=104&ccb=1-7&_nc_sid=6ee11a&_nc_eui2=AeGKvODjjI6Jm6zWJaWujcvaYp3E8q7qXZJincTyrupdkttA_jL1RRmDByqUHmb9HR-Qt8TL9Et1vKZLzy-NBG_L&_nc_ohc=RJ6JFHOBVtsQ7kNvwHMsKjr&_nc_oc=Admnz1UozAn2ZLhWNCCohUHY8_1axHmgcPl4Gpvd_omwKraRvkP54x-QKT8WZlOgs4I&_nc_zt=23&_nc_ht=scontent.fdac31-2.fna&_nc_gid=jepeOO8HED4rL8Be4DG96Q&oh=00_AfSq00Q6RumJBKCGM6aak6Zg3jLPlwEB-3dQX_1Jpwvt6g&oe=687C20C3',
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