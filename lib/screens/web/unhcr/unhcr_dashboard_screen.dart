import 'package:flutter/material.dart';

class UNHCRDashboardScreen extends StatelessWidget {
  const UNHCRDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UNHCR Portal')),
      body: const Center(child: Text('UNHCR Management Dashboard')),
    );
  }
}
