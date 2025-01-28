import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'WriteNotePage.dart';
import 'package:intl/intl.dart';

class NotePage extends StatelessWidget {
  final String userId;

  const NotePage({Key? key, required this.userId}) : super(key: key);

  Future<void> _deleteNote(String noteId) async {
    try {
      final notesRef = FirebaseFirestore.instance
          .collection('User')
          .doc(userId)
          .collection('notes');

      await notesRef.doc(noteId).delete();
    } catch (e) {
      print('Failed to delete note: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('User')
            .doc(userId)
            .collection('notes')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notes yet. Add a note!'));
          }

          final notes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              final content = note['content'] ?? '';
              final date = note['date'] != null
                  ? (note['date'] as Timestamp).toDate()
                  : DateTime.now();
              final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(content, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('Last updated: $formattedDate'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await _deleteNote(note.id);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WriteNotePage(
                          userId: userId,
                          noteId: note.id,
                          initialContent: content,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WriteNotePage(userId: userId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}