import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String emotion = "Loading...";
  double confidence = 0.0;

  @override
  void initState() {
    super.initState();
    fetchEmotion();
  }

  Future<void> fetchEmotion() async {
    try {
      final response = await http.get(Uri.parse("http://localhost:5000/emotion"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          emotion = data["emotion"];
          confidence = (data["confidence"] as num).toDouble();
        });
      } else {
        setState(() {
          emotion = "Error fetching";
        });
      }
    } catch (e) {
      setState(() {
        emotion = "Connection failed";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                trailing: Text(avgStress.toStringAsFixed(1)),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                title: const Text("Current Emotion"),
                subtitle: Text("Confidence: ${confidence.toStringAsFixed(2)}"),
                trailing: Text(emotion),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Therapist Suggestion: Keep practicing with mild exposure."),
          ],
        ),
      ),
    );
  }
}
