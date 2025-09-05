import 'dart:io';
import 'package:flutter/material.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  String selectedPhobia = "Fear of Heights";
  bool isSessionActive = false;
  Process? pythonProcess;

  void startSession() async {
    setState(() {
      isSessionActive = true;
    });

    // Start Python script
    pythonProcess = await Process.start(
      'python',
      ['D:\\ETherapy\\etver4\\emotion_detection.py'], // your Python file path
    );

    pythonProcess!.stdout.transform(SystemEncoding().decoder).listen((data) {
      print("Python stdout: $data"); // optional: debug prints
    });

    pythonProcess!.stderr.transform(SystemEncoding().decoder).listen((data) {
      print("Python stderr: $data");
    });

    // Open Flutter page with dropdown (optional, placeholder for feed)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraDropdownPage(selectedPhobia: selectedPhobia),
      ),
    );
  }

  void endSession() {
    setState(() {
      isSessionActive = false;
    });

    // Kill Python script if running
    pythonProcess?.kill();
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
                    onPressed: endSession,
                    child: const Text("End Session"),
                  )
                : ElevatedButton(
                    onPressed: startSession,
                    child: const Text("Start Session"),
                  ),
          ],
        ),
      ),
    );
  }
}

/// Page with dropdown + placeholder for camera feed
class CameraDropdownPage extends StatefulWidget {
  final String selectedPhobia;
  const CameraDropdownPage({super.key, required this.selectedPhobia});

  @override
  State<CameraDropdownPage> createState() => _CameraDropdownPageState();
}

class _CameraDropdownPageState extends State<CameraDropdownPage> {
  String selectedPhobia = "";

  @override
  void initState() {
    super.initState();
    selectedPhobia = widget.selectedPhobia;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Feed")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedPhobia,
              items: ["Fear of Heights", "Fear of Spiders", "Fear of Flying"]
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (value) => setState(() => selectedPhobia = value!),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                "Python OpenCV + DeepFace window is running externally.",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
