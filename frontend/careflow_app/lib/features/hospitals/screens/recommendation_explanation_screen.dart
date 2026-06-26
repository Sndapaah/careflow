import 'package:flutter/material.dart';
import '../../../models/hospital.dart';
import 'hospital_details_screen.dart';

class RecommendationExplanationScreen extends StatelessWidget {
  final Hospital hospital;

  const RecommendationExplanationScreen({
    super.key,
    required this.hospital,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Why This Hospital?"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              hospital.name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    Text(
                      "${hospital.confidence}%",
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Text(
                      "Recommendation Confidence",
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Why CareFlow Recommended This Facility",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ListTile(
              leading: const Icon(Icons.location_on),
              title: Text("${hospital.distance} km away"),
            ),

            ListTile(
              leading: const Icon(Icons.bed),
              title: Text(
                "${hospital.availableBeds} available beds",
              ),
            ),

            ListTile(
              leading: const Icon(Icons.people),
              title: Text(
                "${hospital.currentPatients} current patients",
              ),
            ),

            ListTile(
              leading: const Icon(Icons.trending_up),
              title: Text(
                "${hospital.incomingPatients} incoming patients",
              ),
            ),

            ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(
                "Wait time: ${hospital.waitTime} mins",
              ),
            ),

            ListTile(
              leading: const Icon(Icons.update),
              title: Text(
                "Updated ${hospital.lastUpdated}",
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Predictive Insights",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Card(
              child: Column(
                children: [

                  ListTile(
                    title: const Text("Expected Patients"),
                    trailing: Text(
                      hospital.predictedPatients.toString(),
                    ),
                  ),

                  ListTile(
                    title: const Text("Predicted Wait"),
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

                  ListTile(
                    title: const Text("Historical Reliability"),
                    trailing: Text(
                      "${hospital.historicalReliability}%",
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Available Specialties",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              children: hospital.specialties
                  .map(
                    (specialty) => Chip(
                      label: Text(specialty),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HospitalDetailsScreen(
                    hospital: hospital,
                  ),
                ),
              );
            },
                icon: const Icon(Icons.local_hospital),
                label: const Text("View Hospital Details"),
              ),
            ),

          ],
        ),
      ),
    );
  }
}