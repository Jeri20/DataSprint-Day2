import 'package:flutter/material.dart';
import 'practice_page.dart';
import 'dashboard_page.dart';

class HomePage extends StatelessWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome, $username")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PracticePage()),
              ),
              child: const Text("Start Practice"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              ),
              child: const Text("Go to Dashboard"),
            ),
          ],
        ),
      ),
    );
  }
}
