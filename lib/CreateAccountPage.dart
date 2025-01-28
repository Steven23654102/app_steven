import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({Key? key}) : super(key: key);

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  // Controller for getting user input
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Create account logic
  void _createAccount() async {
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String address = _addressController.text.trim();
    String phone = _phoneController.text.trim();

    // Check whether the input is empty
    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        address.isEmpty ||
        phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Check if the passwords match
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      // Writing to Firestore
      await FirebaseFirestore.instance.collection('User').add({
        'Username': username,
        'Email': email,
        'Password': password,
        'Address': address,
        'Phone': phone,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );

      // Clear the input box
      _usernameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _addressController.clear();
      _phoneController.clear();
    } catch (e) {
      // Catch errors and display prompts
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create account: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // user name
            const Text(
              'Username',
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                hintText: 'Enter username',
              ),
            ),
            const SizedBox(height: 16),

            // Email
            const Text(
              'Email',
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter email',
              ),
            ),
            const SizedBox(height: 16),

            // password
            const Text(
              'Password',
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Enter password',
              ),
            ),
            const SizedBox(height: 16),

            // Confirm Password
            const Text(
              'Confirm Password',
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Re-enter password',
              ),
            ),
            const SizedBox(height: 16),

            // Home address
            const Text(
              'Address',
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                hintText: 'Enter address',
              ),
            ),
            const SizedBox(height: 16),

            // phone number
            const Text(
              'Phone Number',
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Enter phone number',
              ),
            ),
            const SizedBox(height: 32),

            // Create Account Button
            Center(
              child: ElevatedButton(
                onPressed: _createAccount,
                child: const Text('Create Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}