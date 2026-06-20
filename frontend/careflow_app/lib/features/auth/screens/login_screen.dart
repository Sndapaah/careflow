import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CareFlow'),
      ),
      body: Padding(
  padding: const EdgeInsets.all(24),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Icon(
        Icons.local_hospital,
        size: 80,
      ),

      const SizedBox(height: 20),

      const Text(
        'CareFlow AI',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 10),

      const Text(
        'Intelligent Healthcare Routing',
        textAlign: TextAlign.center,
      ),

      const SizedBox(height: 40),

      const TextField(
        decoration: InputDecoration(
          labelText: 'Email',
          border: OutlineInputBorder(),
        ),
      ),

      const SizedBox(height: 15),

      const TextField(
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Password',
          border: OutlineInputBorder(),
        ),
      ),

      const SizedBox(height: 20),

      ElevatedButton(
        onPressed: () {},
        child: const Text('Login'),
      ),

      TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/register');
        },
        child: const Text('Create Account'),
      ),
    ],
  ),
),
    );
  }
}
