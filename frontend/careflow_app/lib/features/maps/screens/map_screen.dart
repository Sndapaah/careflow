import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Facility Map"),
      ),
      body: const Center(
        child: Text(
          "Google Maps Integration Coming Soon",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}