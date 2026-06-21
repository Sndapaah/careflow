import 'package:flutter/material.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Assessment"),
      ),
      body: Padding(
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
              child: const Column(
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
                    "HIGH",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
              "Possible Conditions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Card(
              child: ListTile(
                leading: Icon(Icons.medical_services),
                title: Text("Respiratory Infection"),
              ),
            ),

            const Card(
              child: ListTile(
                leading: Icon(Icons.favorite),
                title: Text("Cardiac Concern"),
              ),
            ),

            const SizedBox(height: 20),

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

            const Spacer(),

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