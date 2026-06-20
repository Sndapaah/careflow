import 'package:flutter/material.dart';

class SymptomFormScreen extends StatelessWidget {
  const SymptomFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Symptoms"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Select Symptoms",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            CheckboxListTile(
              value: false,
              onChanged: (_) {},
              title: const Text("Fever"),
            ),

            CheckboxListTile(
              value: false,
              onChanged: (_) {},
              title: const Text("Cough"),
            ),

            CheckboxListTile(
              value: false,
              onChanged: (_) {},
              title: const Text("Chest Pain"),
            ),

            CheckboxListTile(
              value: false,
              onChanged: (_) {},
              title: const Text("Headache"),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/analysis',
                  );
                },
                child: const Text("Analyze Symptoms"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}