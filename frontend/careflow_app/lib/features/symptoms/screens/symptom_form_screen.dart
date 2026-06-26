import 'package:flutter/material.dart';
import '../../../models/symptom_assessment.dart';
import '../../analysis/screens/analysis_screen.dart';

class SymptomFormScreen extends StatefulWidget {
  const SymptomFormScreen({super.key});

  @override
  State<SymptomFormScreen> createState() =>
      _SymptomFormScreenState();
}

class _SymptomFormScreenState
    extends State<SymptomFormScreen> {

  String severity = "Moderate";
  final TextEditingController symptomController =
    TextEditingController();

final TextEditingController notesController =
    TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Symptom Assessment"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            const Text(
              "Describe how you're feeling",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
                controller: symptomController,
                decoration: InputDecoration(
                  hintText:
                    "e.g. Chest pain and dizziness",
                prefixIcon:
                    const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Common Symptoms",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                Chip(label: Text("Fever")),
                Chip(label: Text("Cough")),
                Chip(label: Text("Chest Pain")),
                Chip(label: Text("Headache")),
                Chip(label: Text("Fatigue")),
                Chip(label: Text("Nausea")),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              "Severity",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            RadioListTile(
              title: const Text("Mild"),
              value: "Mild",
              groupValue: severity,
              onChanged: (value) {
                setState(() {
                  severity = value!;
                });
              },
            ),

            RadioListTile(
              title: const Text("Moderate"),
              value: "Moderate",
              groupValue: severity,
              onChanged: (value) {
                setState(() {
                  severity = value!;
                });
              },
            ),

            RadioListTile(
              title: const Text("Severe"),
              value: "Severe",
              groupValue: severity,
              onChanged: (value) {
                setState(() {
                  severity = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            TextField(
                controller: notesController,
                maxLines: 4,
                decoration: InputDecoration(
                hintText:
                    "Additional notes...",
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                final assessment = SymptomAssessment(
                  symptoms: symptomController.text,
                  severity: severity,
                  notes: notesController.text,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AnalysisScreen(
                      assessment: assessment,
                    ),
                  ),
                );
              },
                child: const Text(
                  "Analyze Symptoms",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}