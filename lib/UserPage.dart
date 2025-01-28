import 'package:flutter/material.dart';
import 'ModifyPage.dart';
import 'ContactPage.dart';
import 'LoginPage.dart';

class UserPage extends StatelessWidget {
  final String username;
  final String email;

  const UserPage({Key? key, required this.username, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Page'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User Avatar
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/user_avatar.png'),
            ),
            const SizedBox(height: 16),

            // user name
            Text(
              'Hello, $username',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // User Email
            Text(
              email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            const Divider(),

            // User information change button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModifyPage(userEmail: email),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('User information changes'),
            ),

            const SizedBox(height: 10),

            // Contact button
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactPage(userEmail: email),
                  ),
                );
              },
              icon: const Icon(Icons.contact_phone),
              label: const Text('Technical Support and Contact'),
            ),

            const SizedBox(height: 30),

            // Logout Button
            ElevatedButton(
              onPressed: () async {
                final shouldLogout = await _showLogoutConfirmation(context);
                if (shouldLogout) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false, // Clear the navigation stack
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                'Sign out',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Display the logout confirmation popup
  Future<bool> _showLogoutConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Exit'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // confirm
            child: const Text('confirm'),
          ),
        ],
      ),
    ) ??
        false; // If the user closes the popup, it returns false by default.
  }
}