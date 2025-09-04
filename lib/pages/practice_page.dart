import 'package:flutter/material.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  String selectedPhobia = "Fear of Heights"; // later fetch from DB
  bool isSessionActive = false;
  DateTime? startTime;

  void startSession() {
    setState(() {
      isSessionActive = true;
      startTime = DateTime.now();
    });
    // Save to DB: session start
  }

  void endSession() {
    setState(() {
      isSessionActive = false;
    });
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime!).inMinutes;
    // Save to DB: session end, duration, physiological data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Practice Session")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedPhobia,
              items: ["Fear of Heights", "Fear of Spiders", "Fear of Flying"]
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (value) => setState(() => selectedPhobia = value!),
            ),
            const SizedBox(height: 20),
            isSessionActive
                ? ElevatedButton(
                    onPressed: endSession, child: const Text("End Session"))
                : ElevatedButton(
                    onPressed: startSession, child: const Text("Start Session")),
          ],
        ),
      ),
    );
  }
}
