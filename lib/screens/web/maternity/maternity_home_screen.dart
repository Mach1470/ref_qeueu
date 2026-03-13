import 'package:flutter/material.dart';

class MaternityHomeScreen extends StatelessWidget {
  const MaternityHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maternity Dashboard'),
        backgroundColor: Colors.pink,
      ),
      body: const Center(
        child: Text('Maternity Dashboard: Pending Patients'),
      ),
    );
  }
}
