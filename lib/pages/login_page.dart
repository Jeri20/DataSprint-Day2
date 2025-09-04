import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/user.dart';
import 'signup_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  String message = "";

  void login() async {
    User? user = await DBHelper.getUser(_username.text, _password.text);
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(username: user.username)),
      );
    } else {
      setState(() => message = "Invalid username or password!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _username, decoration: const InputDecoration(labelText: "Username")),
            TextField(controller: _password, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: const Text("Login")),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignUpPage()),
              ),
              child: const Text("Don't have an account? Sign up"),
            ),
            if (message.isNotEmpty) Text(message, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
