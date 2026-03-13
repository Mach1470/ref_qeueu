import 'package:flutter/material.dart';

class MaternityDashboardScreen extends StatelessWidget {
  const MaternityDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maternity Dashboard')),
      body: const Center(child: Text('Maternity Dashboard Area')),
    );
  }
}
