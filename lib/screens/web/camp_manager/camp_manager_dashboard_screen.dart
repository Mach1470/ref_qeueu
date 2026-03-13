import 'package:flutter/material.dart';

class CampManagerDashboardScreen extends StatelessWidget {
  const CampManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camp Manager Portal')),
      body: const Center(child: Text('Camp Manager Administration Dashboard')),
    );
  }
}
