import 'package:flutter/material.dart';

class MaternityLoginScreen extends StatelessWidget {
  const MaternityLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maternity Login'),
        backgroundColor: Colors.pink,
      ),
      body: const Center(
        child: Text('Maternity Staff Login Portal'),
      ),
    );
  }
}
