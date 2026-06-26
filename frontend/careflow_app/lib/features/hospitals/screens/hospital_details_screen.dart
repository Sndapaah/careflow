import 'package:flutter/material.dart';
import '../../../models/hospital.dart';
import 'hospital_details_screen.dart';

class HospitalDetailsScreen extends StatelessWidget {
  final Hospital hospital;

  const HospitalDetailsScreen({
    super.key,
    required this.hospital,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hospital Details"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          Text(
            hospital.name,
              style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height:20),

          Card(
            child: ListTile(
              title: Text("Available Beds"),
              subtitle: Text(hospital.availableBeds.toString()),
            ),
          ),

            Card(
            child: ListTile(
              title: const Text("Incoming Patients"),
              subtitle: Text(
                hospital.incomingPatients.toString(),
              ),
            ),
          ),

          Card(
            child: ListTile(
              title: Text("Current Patients"),
              subtitle: Text(hospital.currentPatients.toString(),),
            ),
          ),

          Card(
            child: ListTile(
              title: Text("Estimated Wait Time"),
              subtitle: Text("${hospital.waitTime} mins",
            ),
            ),
          ),
          const SizedBox(height: 20),

Text(
  "Predictive Insights",
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 10),

Card(
  child: Column(
    children: [

      ListTile(
        title: const Text("Predicted Patients"),
        trailing: Text(
          hospital.predictedPatients.toString(),
        ),
      ),

      ListTile(
        title: const Text("Predicted Wait Time"),
        trailing: Text(
          "${hospital.predictedWaitTime} mins",
        ),
      ),

      ListTile(
        title: const Text("Prediction Confidence"),
        trailing: Text(
          "${hospital.predictionConfidence}%",
        ),
      ),

    ],
  ),
),
        ],
      ),
    );
  }
}