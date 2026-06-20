import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CareFlow'),
      ),
      body: Center(
  child: ElevatedButton(
  onPressed: () {
    Navigator.pushReplacementNamed(
      context,
      '/profile-setup',
    );
  },
  child: const Text('Register'),
),
),
    );
  }
}