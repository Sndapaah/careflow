import 'package:flutter/material.dart';
import '../../../models/symptom_assessment.dart';

class AnalysisScreen extends StatelessWidget {
  final SymptomAssessment assessment;

  const AnalysisScreen({
    super.key,
    required this.assessment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Assessment"),
      ),
          body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Severity",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    assessment.severity,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

Card(
  child: ListTile(
    title: const Text("Symptoms Entered"),
    subtitle: Text(assessment.symptoms),
  ),
),
            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: Icon(Icons.analytics),
                title: Text("Confidence Score"),
                subtitle: Text("89%"),
              ),
            ),

            const SizedBox(height: 20),

              const Text(
                "Recommended Specialty",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Card(
                child: ListTile(
                  leading: Icon(Icons.local_hospital),
                  title: Text("General Medicine"),
                  subtitle: Text(
                    "Best suited for your symptoms",
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "CareFlow Reasoning",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10),

              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Based on symptoms (${assessment.severity} severity), "
              "CareFlow is analyzing possible conditions and routing options."
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "Predicted Care Journey",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10),

              Card(
                child: Column(
                  children: [

                    ListTile(
                      leading: Icon(Icons.timer),
                      title: Text("Expected Wait"),
                      trailing: Text("18 mins"),
                    ),

                    ListTile(
                      leading: Icon(Icons.medical_information),
                      title: Text("Recommended Facility Type"),
                      trailing: Text("District Hospital"),
                    ),

                    ListTile(
                      leading: Icon(Icons.check_circle),
                      title: Text("Confidence"),
                      trailing: Text("89%"),
                    ),

                  ],
                ),
              ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Seek medical attention today."
                    ),
                  ),
                ],
              ),
            ),

            //const Spacer(),

            SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/recommendations',
                );
              },
              child: const Text(
                "View Recommended Hospitals",
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}