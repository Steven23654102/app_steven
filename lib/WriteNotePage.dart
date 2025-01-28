import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

class WriteNotePage extends StatefulWidget {
  final String userId;
  final String? noteId;
  final String? initialContent;

  const WriteNotePage({
    Key? key,
    required this.userId,
    this.noteId,
    this.initialContent,
  }) : super(key: key);

  @override
  State<WriteNotePage> createState() => _WriteNotePageState();
}

class _WriteNotePageState extends State<WriteNotePage> {
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialContent);
  }

  Future<void> _saveNote() async {
    final content = _noteController.text.trim();
    if (content.isEmpty) return;

    try {
      final notesRef = FirebaseFirestore.instance
          .collection('User')
          .doc(widget.userId)
          .collection('notes');

      if (widget.noteId == null) {
        print('Adding new note...');
        await notesRef.add({
          'content': content,
          'date': DateTime.now(),
        });
      } else {
        print('Updating existing note...');
        await notesRef.doc(widget.noteId).update({
          'content': content,
          'date': DateTime.now(),
        });
      }
      print('Note saved successfully.');
    } catch (e) {
      print('Failed to save note: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save note: $e')),
      );
    }
  }

  Future<void> _shareNote() async {
    if (widget.noteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please save the note before sharing.')),
      );
      return;
    }

    try {
      final noteDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(widget.userId)
          .collection('notes')
          .doc(widget.noteId)
          .get();

      if (noteDoc.exists) {
        final content = noteDoc['content'] ?? 'No content';
        await Share.share(content); // Share content using share_plus
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note not found.')),
        );
      }
    } catch (e) {
      print('Failed to share note: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share note: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write Note'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            try {
              await _saveNote();
            } catch (e) {
              print('Failed to save note: $e');
            }
            if (mounted) {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share), // Share Button
            onPressed: _shareNote,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              await _saveNote();
              if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _noteController,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            hintText: 'Write your note here...',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}