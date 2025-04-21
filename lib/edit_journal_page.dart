// === edit_journal_page.dart ===

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart'; // 新增 shimmer 套件支援動畫

class EditJournalPage extends StatefulWidget {
  final String dateId;
  final String initialText;
  final String initialMood;
  final String initialTag;

  const EditJournalPage({
    super.key,
    required this.dateId,
    required this.initialText,
    required this.initialMood,
    required this.initialTag,
  });

  @override
  State<EditJournalPage> createState() => _EditJournalPageState();
}

class _EditJournalPageState extends State<EditJournalPage> {
  late TextEditingController controller;
  late String mood;
  late String tag;
  bool isSaving = false;
  String encouragement = '載入中...';

  final List<String> tags = ['工作', '家庭', '感情', '心情', '學習', '其他'];

  final String apiKey = 'AIzaSyDHqi2OLF8D6b8Ay-39mKa4NeXBwHfpbeE';

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialText);
    mood = widget.initialMood;
    tag = tags.contains(widget.initialTag) ? widget.initialTag : tags.first;
    fetchEncouragement();
  }

  Future<void> fetchEncouragement() async {
    setState(() => encouragement = '載入中...');
    try {
      final uri = Uri.parse('https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=$apiKey');
      final headers = {'Content-Type': 'application/json'};
      final moodPrompt = moodLabel(mood);
      final prompt = '請用一句簡短溫暖的中文，鼓勵今天心情「$moodPrompt」的人';

      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      });

      final res = await http.post(uri, headers: headers, body: body);
      final data = jsonDecode(res.body);
      final text = data['candidates']?[0]['content']['parts'][0]['text'];

      if (mounted && text != null && text.trim().isNotEmpty) {
        setState(() => encouragement = text.trim());
      } else {
        setState(() => encouragement = '今天也是很棒的一天，加油！');
      }
    } catch (e) {
      setState(() => encouragement = '載入失敗，請稍後再試');
    }
  }

  String moodLabel(String emoji) {
    switch (emoji) {
      case '😊':
        return '開心';
      case '😢':
        return '難過';
      case '😠':
        return '生氣';
      case '😴':
        return '疲倦';
      case '🤔':
        return '思考中';
      default:
        return '平靜';
    }
  }

  Future<void> updateJournal() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => isSaving = true);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('journal')
        .doc(widget.dateId)
        .update({
      'text': controller.text.trim(),
      'mood': mood,
      'tag': tag,
    });

    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.edit_note, color: Colors.white),
            const SizedBox(width: 8),
            Text('編輯 ${widget.dateId} 日記'),
          ],
        ),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.indigo.shade100),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.indigo),
                    const SizedBox(width: 10),
                    Expanded(
                      child: encouragement == '載入中...'
                          ? Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                width: double.infinity,
                                height: 16,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              encouragement,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: '重新產生鼓勵語',
                      onPressed: fetchEncouragement,
                    )
                  ],
                ),
              ),
              _buildSectionTitle('今日心情'),
              const SizedBox(height: 8),
              _buildDropdownMood(),
              const SizedBox(height: 20),
              _buildSectionTitle('主題分類'),
              const SizedBox(height: 8),
              _buildDropdownTag(),
              const SizedBox(height: 20),
              _buildSectionTitle('日記內容'),
              const SizedBox(height: 8),
              _buildTextField(),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) => Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
      );

  Widget _buildDropdownMood() => DropdownButtonFormField<String>(
        value: mood,
        decoration: _inputDecoration(),
        items: [
          DropdownMenuItem(value: '😊', child: Text('😊 開心')),
          DropdownMenuItem(value: '😢', child: Text('😢 難過')),
          DropdownMenuItem(value: '😠', child: Text('😠 生氣')),
          DropdownMenuItem(value: '😴', child: Text('😴 疲倦')),
          DropdownMenuItem(value: '🤔', child: Text('🤔 思考中')),
        ],
        onChanged: (val) {
          setState(() => mood = val ?? widget.initialMood);
          fetchEncouragement();
        },
      );

  Widget _buildDropdownTag() => DropdownButtonFormField<String>(
        value: tag,
        decoration: _inputDecoration(),
        items: tags.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (val) => setState(() => tag = val ?? widget.initialTag),
      );

  Widget _buildTextField() => TextField(
        controller: controller,
        maxLines: 6,
        decoration: _inputDecoration(hintText: '輸入你的心情紀錄...'),
      );

  InputDecoration _inputDecoration({String? hintText}) => InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.indigo.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
      );

  Widget _buildSaveButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.save_alt),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo.shade600,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: isSaving ? null : updateJournal,
          label: isSaving
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('儲存日記', style: TextStyle(fontSize: 16)),
        ),
      );
}