import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/user.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  String message = "";

  void signup() async {
    // 1. Validate input
    if (_username.text.isEmpty || _password.text.isEmpty) {
      setState(() => message = "Please enter username and password!");
      return;
    }

    try {
      // 2. Try inserting into DB
      await DBHelper.insertUser(
        User(
          username: _username.text.trim(),
          password: _password.text.trim(),
        ),
      );

      // 3. If success, go back to login
      Navigator.pop(context);
    } catch (e) {
      // 4. If UNIQUE constraint fails
      setState(() => message = "Username already exists!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _username,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _password,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: signup, child: const Text("Sign Up")),
            if (message.isNotEmpty)
              Text(
                message,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
