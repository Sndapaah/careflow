import 'package:flutter/material.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recommended Hospitals"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              title: Text("KNUST Hospital"),
              subtitle: Text(
                "Confidence: 92%\n"
                "Distance: 2.3km\n"
                "Beds Available: 14\n"
                "Wait Time: 18 mins",
              ),
            ),
          ),

          Card(
            child: ListTile(
              title: Text("Komfo Anokye"),
              subtitle: Text(
                "Confidence: 88%\n"
                "Distance: 5.6km\n"
                "Beds Available: 7\n"
                "Wait Time: 40 mins",
              ),
            ),
          ),
        ],
      ),
    );
  }
}