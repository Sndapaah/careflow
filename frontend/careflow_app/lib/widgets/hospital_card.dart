import 'package:flutter/material.dart';

class HospitalCard extends StatelessWidget {
  final String hospital;
  final String confidence;
  final String distance;
  final String beds;
  final String patients;
  final String incoming;
  final String waitTime;
  final String status;

  const HospitalCard({
    super.key,
    required this.hospital,
    required this.confidence,
    required this.distance,
    required this.beds,
    required this.patients,
    required this.incoming,
    required this.waitTime,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hospital,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text("Confidence: $confidence"),
            Text("Distance: $distance"),
            Text("Available Beds: $beds"),
            Text("Current Patients: $patients"),
            Text("Incoming Patients: $incoming"),
            Text("Wait Time: $waitTime"),
            Text("Status: $status"),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/map',
                      );
                    },
                    child: const Text("View Map"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/hospital-details',
                      );
                    },
                    child: const Text("Details"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}