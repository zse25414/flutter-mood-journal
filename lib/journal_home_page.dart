// === journal_home_page.dart 美化版 ===

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_journal_page.dart';
import 'mood_timeline_page.dart';

class JournalHomePage extends StatelessWidget {
  const JournalHomePage({super.key});

  Color getTagColor(String tag) {
    switch (tag) {
      case '工作':
        return Colors.blue.shade100;
      case '家庭':
        return Colors.green.shade100;
      case '感情':
        return Colors.pink.shade100;
      case '心情':
        return Colors.yellow.shade100;
      case '學習':
        return Colors.purple.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Center(child: Text("請重新登入"));

    final journalRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('journal')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📔 我的日記本'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.timeline),
            tooltip: '情緒時間軸',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MoodTimelinePage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '登出',
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 92, 82, 82),
      body: StreamBuilder<QuerySnapshot>(
        stream: journalRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final entries = snapshot.data!.docs;

          if (entries.isEmpty) {
            return const Center(child: Text('你還沒有任何日記，點右下角 + 開始新增吧！'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final doc = entries[index];
              final date = doc.id;
              final text = doc['text'] ?? '';
              final mood = doc.data().toString().contains('mood') ? doc['mood'] : '📝';
              final tag = doc.data().toString().contains('tag') ? doc['tag'] : '其他';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: getTagColor(tag),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  leading: Text(mood, style: const TextStyle(fontSize: 28)),
                  title: Text(date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        text.length > 50 ? text.substring(0, 50) + '...' : text,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text('分類：$tag', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditJournalPage(
                        dateId: date,
                        initialText: text,
                        initialMood: mood,
                        initialTag: tag,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 82, 82, 197),
        onPressed: () => Navigator.pushNamed(context, '/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
