import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CareFlow"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Good Morning, Nana",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Stay healthy today ❤️",
            ),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    const Text(
                      "Start Symptom Assessment",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Describe how you're feeling and get recommendations.",
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/symptoms',
                        );
                      },
                      child: const Text("Start"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              color: Colors.redAccent,
              child: ListTile(
                title: const Text(
                  "🚨 Emergency Assistance",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  "Get immediate recommendations",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/recommendations',
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Recent Assessments",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const ListTile(
              leading: Icon(Icons.history),
              title: Text("Fever"),
            ),

            const ListTile(
              leading: Icon(Icons.history),
              title: Text("Headache"),
            ),

            const ListTile(
              leading: Icon(Icons.history),
              title: Text("Chest Pain"),
            ),

            const SizedBox(height: 24),

            const Text(
              "Nearby Hospitals",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const ListTile(
              leading: Icon(Icons.local_hospital),
              title: Text("KNUST Hospital"),
            ),

            const ListTile(
              leading: Icon(Icons.local_hospital),
              title: Text("KATH"),
            ),

            const ListTile(
              leading: Icon(Icons.local_hospital),
              title: Text("University Hospital"),
            ),
          ],
        ),
      ),
    );
  }
}