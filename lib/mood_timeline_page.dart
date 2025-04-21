import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MoodTimelinePage extends StatelessWidget {
  const MoodTimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final today = DateTime.now();
    final year = today.year;
    final month = today.month;

    return Scaffold(
      appBar: AppBar(title: const Text('🌈 本月心情牆')),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('journal')
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.docs;
          final moodMap = <int, String>{};
          for (final doc in data) {
            final docDate = DateTime.tryParse(doc.id);
            if (docDate != null && docDate.year == year && docDate.month == month) {
              moodMap[docDate.day] = doc['mood'] ?? '📝';
            }
          }

          final daysInMonth = DateUtils.getDaysInMonth(year, month);
          final days = List.generate(daysInMonth, (i) => i + 1);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: days.map((day) {
                final mood = moodMap[day] ?? '📝';
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$day日', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(mood, style: const TextStyle(fontSize: 26)),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
