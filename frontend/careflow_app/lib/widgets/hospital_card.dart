import 'package:flutter/material.dart';
import '../models/hospital.dart';
import '../features/hospitals/screens/recommendation_explanation_screen.dart';


class HospitalCard extends StatelessWidget {
final Hospital hospital;

  const HospitalCard({
  super.key,
  required this.hospital,
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
            Row(
  children: [

  CircleAvatar(
  radius: 24,
  child: Text(
    "${hospital.confidence}%",
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    ),
  ),
),
    const SizedBox(width: 12),

    Expanded(
      child: Text(
        hospital.name,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

  ],
),
        const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
      Text(
        "${hospital.confidence}%",
          style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
Text("${hospital.distance} km"),  ],
),

const SizedBox(height: 12),

Wrap(
  spacing: 10,
  runSpacing: 10,
  children: [

    Chip(
      label: Text("Beds: ${hospital.availableBeds}"),
    ),

    Chip(
      label: Text("Patients: ${hospital.currentPatients}"),
    ),

    Chip(
      label: Text("Incoming: ${hospital.incomingPatients}"),
    ),

    Chip(
      label: Text("Wait: ${hospital.waitTime} mins"),
    ),

    Chip(
      label: Text(hospital.congestionLevel),
    ),

  ],
),

const SizedBox(height: 10),

Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  ),
  decoration: BoxDecoration(
    color: Colors.green.shade100,
    borderRadius: BorderRadius.circular(20),
  ),
  child: Text(hospital.status),
),

const SizedBox(height: 10),

Text(
  "Updated ${hospital.lastUpdated}",
  style: const TextStyle(
    fontSize: 12,
    color: Colors.grey,
  ),
),

const SizedBox(height: 10),

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
                    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) =>
        RecommendationExplanationScreen(
      hospital: hospital,
    ),
  ),
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