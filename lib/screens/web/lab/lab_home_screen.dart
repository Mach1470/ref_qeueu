import 'package:flutter/material.dart';

class LabHomeScreen extends StatelessWidget {
  const LabHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lab Dashboard"),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: Text(
          "Lab Home Screen",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
