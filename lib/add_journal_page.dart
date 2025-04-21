import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AddJournalPage extends StatefulWidget {
  const AddJournalPage({super.key});

  @override
  State<AddJournalPage> createState() => _AddJournalPageState();
}

class _AddJournalPageState extends State<AddJournalPage> {
  final controller = TextEditingController();
  String mood = '😊';
  bool isSaving = false;

  Future<void> saveJournal() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || controller.text.trim().isEmpty) return;

    setState(() => isSaving = true);

    final dateId = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('journal')
        .doc(dateId)
        .set({
      'text': controller.text.trim(),
      'mood': mood,
      'createdAt': Timestamp.now(),
    });

    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新增日記')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: mood,
              decoration: const InputDecoration(labelText: '今天的心情'),
              items: ['😊 開心', '😢 難過', '😠 生氣', '😴 疲倦', '🤔 思考中'].map((e) {
                final emoji = e.substring(0, 2);
                return DropdownMenuItem(value: emoji, child: Text(e));
              }).toList(),
              onChanged: (val) => setState(() => mood = val ?? '😊'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: '今天想說點什麼？',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isSaving ? null : saveJournal,
              child: isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('儲存'),
            )
          ],
        ),
      ),
    );
  }
}