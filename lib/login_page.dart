import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final ageController = TextEditingController();
  String gender = '男';

  bool isLogin = true;
  bool isLoading = false;
  String? errorMessage;

  Future<void> handleAuth() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final age = ageController.text.trim();

    if (email.isEmpty || password.isEmpty || (!isLogin && age.isEmpty)) {
      setState(() {
        errorMessage = '請填寫所有欄位';
        isLoading = false;
      });
      return;
    }

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final uid = FirebaseAuth.instance.currentUser!.uid;

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email': email,
          'age': int.tryParse(age),
          'gender': gender,
          'createdAt': Timestamp.now(),
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = getFriendlyError(e);
        isLoading = false;
      });
    }
  }

  String getFriendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Email 格式不正確';
      case 'user-not-found':
        return '找不到帳號，請註冊';
      case 'wrong-password':
        return '密碼錯誤';
      case 'email-already-in-use':
        return '此 Email 已被註冊';
      case 'weak-password':
        return '密碼至少需要 6 個字元';
      default:
        return '錯誤：${e.message}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 48),
                const Icon(Icons.favorite, color: Colors.purple, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Mood Journal',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isLogin ? '歡迎回來！請登入帳號' : '註冊新帳號，一起開始記錄心情吧！',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 32),

                // Email
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // 密碼
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '密碼',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                // 額外欄位 (註冊用)
                if (!isLogin) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '年齡',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: gender,
                    items: ['男', '女', '其他'].map((g) {
                      return DropdownMenuItem(value: g, child: Text(g));
                    }).toList(),
                    onChanged: (val) => setState(() => gender = val!),
                    decoration: InputDecoration(
                      labelText: '性別',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],

                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],

                const SizedBox(height: 24),

                // 登入/註冊按鈕
                ElevatedButton.icon(
                  onPressed: isLoading ? null : handleAuth,
                  icon: const Icon(Icons.login),
                  label: Text(isLogin ? '登入' : '註冊'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                    foregroundColor: Colors.white, // ⬅️ 白色文字
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                // 切換註冊或登入
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: isLoading
                      ? null
                      : () => setState(() {
                            isLogin = !isLogin;
                            errorMessage = null;
                          }),
                  child: Text(
                    isLogin ? '沒有帳號？註冊' : '已有帳號？登入',
                    style: const TextStyle(
                      color: Colors.purple,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
