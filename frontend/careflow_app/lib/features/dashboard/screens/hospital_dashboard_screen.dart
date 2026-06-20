import 'package:flutter/material.dart';


class HospitalDashboardScreen extends StatelessWidget {
  const HospitalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CareFlow'),
      ),
      body: const Center(
        child: Text('Hospital Dashboard Screen'),
      ),
    );
  }
}