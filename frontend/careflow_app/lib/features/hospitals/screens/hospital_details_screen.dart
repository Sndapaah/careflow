import 'package:flutter/material.dart';

class HospitalDetailsScreen extends StatelessWidget {
  const HospitalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hospital Details"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [

          Text(
            "KNUST Hospital",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height:20),

          Card(
            child: ListTile(
              title: Text("Available Beds"),
              subtitle: Text("14"),
            ),
          ),

          Card(
            child: ListTile(
              title: Text("Doctors Available"),
              subtitle: Text("9"),
            ),
          ),

          Card(
            child: ListTile(
              title: Text("Current Patients"),
              subtitle: Text("82"),
            ),
          ),

          Card(
            child: ListTile(
              title: Text("Estimated Wait Time"),
              subtitle: Text("18 mins"),
            ),
          ),
        ],
      ),
    );
  }
}