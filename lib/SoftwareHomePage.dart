import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'RelatedInformationPage.dart';
import 'NotePage.dart';
import 'UserPage.dart';
import 'CameraScanPage.dart';
import 'chatPage.dart';
import 'MapPage.dart';

class SoftwareHomePage extends StatefulWidget {
  final String username;
  final String email;

  const SoftwareHomePage({Key? key, required this.username, required this.email}) : super(key: key);

  @override
  State<SoftwareHomePage> createState() => _SoftwareHomePageState();
}

class _SoftwareHomePageState extends State<SoftwareHomePage> {
  int _currentIndex = 0;
  String? _userId;

  Future<void> _fetchUserId() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('Email', isEqualTo: widget.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _userId = querySnapshot.docs.first.id;
        });
      } else {
        print('No user found for email: ${widget.email}');
      }
    } catch (e) {
      print('Failed to fetch user ID: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> _pages = [
      RelatedInformationPage(),
      CameraScanPage(),
      NotePage(userId: _userId!),
      MapPage(), // Adding a MapPage
      ChatPage(), // Add this line to include the chat page
      UserPage(username: widget.username, email: widget.email),

    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Related Information',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Note',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem( // Added chat option
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
      ),
    );
  }
}