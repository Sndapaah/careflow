import 'package:flutter/material.dart';
import '../../../services/mock_data.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // MAP AREA
          Container(
            color: Colors.grey.shade300,
            width: double.infinity,
            height: double.infinity,
            child: const Center(
              child: Text(
                "MAP PLACEHOLDER",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // TOP BAR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [

                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(30),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search),
                          SizedBox(width: 10),
                          Text(
                            "Recommended Facilities",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

Positioned(
  top: 110,
  right: 16,
  child: Card(
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [

          Text(
            "Best Route",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 5),

          Text("18 mins"),

          Text("2.3 km"),
        ],
      ),
    ),
  ),
),

          // BOTTOM PANEL
          DraggableScrollableSheet(
            initialChildSize: 0.28,
            minChildSize: 0.20,
            maxChildSize: 0.80,
            builder: (context, scrollController) {

              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),

                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: hospitals.length,
                  itemBuilder: (context, index) {

                    final hospital = hospitals[index];

                    return Card(
                      margin:
                          const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding:
                            const EdgeInsets.all(12),
                        child: Column(
                          children: [

                            Row(
                              children: [

                                Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.local_hospital,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [

                                      Text(
                                        hospital.name,
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),

                                      Text(
                                        "${hospital.distance} km away",
                                      ),

                                      Text(
                                        "Wait: ${hospital.waitTime} mins",
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [

                                Chip(
                                  label: Text(
                                    "Beds ${hospital.availableBeds}",
                                  ),
                                ),

                                const SizedBox(width: 6),

                                Chip(
                                  label: Text(
                                    "Patients ${hospital.currentPatients}",
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                child: const Text(
                                  "View Route",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}