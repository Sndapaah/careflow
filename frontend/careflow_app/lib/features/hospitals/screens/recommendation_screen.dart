import 'package:flutter/material.dart';
import '../../../services/mock_data.dart';
import '../../../widgets/hospital_card.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Recommended Hospitals",
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
            itemCount: hospitals.length,
            itemBuilder: (context, index) {
            final facility = hospitals[index];

            return HospitalCard(
              hospital: facility,
            );
          },
      ),
    );
  }
}