import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  final String userEmail;

  const ContactPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactItem(
              icon: Icons.phone,
              label: 'Phone number',
              value: '12345678',  // phone number 1
            ),
            _buildContactItem(
              icon: Icons.phone,
              label: 'Phone number 2',
              value: '12345679',  // phone number 2
            ),
            _buildContactItem(
              icon: Icons.phone,
              label: 'Email',
              value: '12345678@gmail.com',  // Email
            ),
            const SizedBox(height: 20),
            _buildContactItem(
              icon: Icons.home,
              label: 'Address',
              value: '12 Concorde Road, Kowloon City, Hong Kong',  // address
            ),
          ],
        ),
      ),
    );
  }

  // Build the contact item
  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}
