// === edit_journal_page.dart ===

// 本專案由 Flutter + Firebase 製作而成，支援日記新增、分類、心情 Emoji、鼓勵語 AI、自動儲存 Firestore
// 📌 詳見 README 說明：https://github.com/YOUR_USERNAME/flutter-mood-journal

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart'; // 新增 shimmer 套件支援動畫

// ...（以下內容不變）
// │   ├── main.dart                // 入口點
// │   ├── login_page.dart          // Firebase 登入畫面
// │   ├── journal_home_page.dart   // 日記首頁（卡片列表）
// │   ├── add_journal_page.dart    // 新增日記表單
// │   ├── edit_journal_page.dart   // 編輯日記頁 + AI 鼓勵語生成
// │   └── mood_timeline_page.dart  // 心情時間軸可視化圖表
// ├── android/ + ios/             // 原生設定與 firebase 連線
// ├── pubspec.yaml               // 套件管理（firebase, shimmer, http）