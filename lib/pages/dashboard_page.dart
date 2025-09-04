import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // later: fetch user stats from DB
    int totalSessions = 5;
    int milestones = 2;
    double avgStress = 35.2;

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text("Total Sessions"),
                trailing: Text("$totalSessions"),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("Milestones Achieved"),
                trailing: Text("$milestones"),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("Average Stress Index"),
                trailing: Text("${avgStress.toStringAsFixed(1)}"),
              ),
            ),
            const SizedBox(height: 20),
            Text("Therapist Suggestion: Keep practicing with mild exposure."),
          ],
        ),
      ),
    );
  }
}
