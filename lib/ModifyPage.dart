import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModifyPage extends StatefulWidget {
  final String userEmail;

  const ModifyPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<ModifyPage> createState() => _ModifyPageState();
}

class _ModifyPageState extends State<ModifyPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  DocumentReference? _userDocRef;
  bool _isLoading = false; // Whether to display loading indicator

  // Loading User Data
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('Email', isEqualTo: widget.userEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var userData = snapshot.docs.first.data() as Map<String, dynamic>;
        _userDocRef = snapshot.docs.first.reference;

        setState(() {
          _usernameController.text = userData['Username'] ?? '';
          _phoneController.text = userData['Phone'] ?? '';
          _addressController.text = userData['Address'] ?? '';
          _passwordController.text = userData['Password'] ?? '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update user data
  Future<void> _updateUserData() async {
    if (_userDocRef == null) return;

    // Validating Input
    if (_usernameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    // Display loading animation
    setState(() {
      _isLoading = true;
    });

    try {
      await _userDocRef!.update({
        'Username': _usernameController.text.trim(),
        'Phone': _phoneController.text.trim(),
        'Address': _addressController.text.trim(),
        'Password': _passwordController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User information changes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Display loading indicator
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildReadOnlyField('Email', widget.userEmail, Icons.email),
          const SizedBox(height: 16),
          _buildEditableField(
            label: 'Password',
            controller: _passwordController,
            icon: Icons.lock,
            isObscured: true,
          ),
          const SizedBox(height: 16),
          _buildEditableField(
            label: 'Username',
            controller: _usernameController,
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          _buildEditableField(
            label: 'Phone',
            controller: _phoneController,
            icon: Icons.phone,
          ),
          const SizedBox(height: 16),
          _buildEditableField(
            label: 'Address',
            controller: _addressController,
            icon: Icons.home,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _updateUserData,
            child: const Text('update'),
          ),
        ],
      ),
    );
  }

  // Constructing read-only fields
  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextField(
          controller: TextEditingController(text: value),
          readOnly: true,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  // 构建可编辑字段
  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isObscured = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextField(
          controller: controller,
          obscureText: isObscured,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}