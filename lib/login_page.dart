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
        // 註冊
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
      appBar: AppBar(title: Text(isLogin ? '登入' : '註冊')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 48),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '密碼', border: OutlineInputBorder()),
            ),
            if (!isLogin) ...[
              const SizedBox(height: 16),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '年齡', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: gender,
                items: ['男', '女', '其他'].map((g) {
                  return DropdownMenuItem(value: g, child: Text(g));
                }).toList(),
                onChanged: (val) => setState(() => gender = val!),
                decoration: const InputDecoration(labelText: '性別', border: OutlineInputBorder()),
              ),
            ],
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : handleAuth,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(isLogin ? '登入' : '註冊'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () => setState(() {
                        isLogin = !isLogin;
                        errorMessage = null;
                      }),
              child: Text(isLogin ? '沒有帳號？註冊' : '已有帳號？登入'),
            )
          ],
        ),
      ),
    );
  }
}
