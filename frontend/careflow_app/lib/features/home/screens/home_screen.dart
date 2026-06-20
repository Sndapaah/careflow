import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CareFlow AI"),
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
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello Nana 👋",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "How are you feeling today?",
            ),
          ],
        ),
      ),

      const SizedBox(height: 25),

      TextField(
        readOnly: true,
        onTap: () {
          Navigator.pushNamed(context, '/symptoms');
        },
        decoration: InputDecoration(
          hintText: "Describe Symptoms",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),

      const SizedBox(height: 25),

      const Text(
  "Quick Actions",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 12),

Wrap(
  spacing: 10,
  runSpacing: 10,
  children: [
    ActionChip(
      avatar: Icon(Icons.warning),
      label: Text("Emergency"),
      onPressed: null,
    ),
    ActionChip(
      avatar: Icon(Icons.local_hospital),
      label: Text("Find Hospital"),
      onPressed: null,
    ),
    ActionChip(
      avatar: Icon(Icons.calendar_today),
      label: Text("Appointments"),
      onPressed: null,
    ),
    ActionChip(
      avatar: Icon(Icons.history),
      label: Text("History"),
      onPressed: null,
    ),
  ],
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
  children: [
    Chip(label: Text("Fever")),
    Chip(label: Text("Cough")),
    Chip(label: Text("Headache")),
    Chip(label: Text("Chest Pain")),
    Chip(label: Text("Fatigue")),
  ],
),

const SizedBox(height: 25),

const Text(
  "Nearby Facilities",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 10),

Card(
  child: ListTile(
    leading: Icon(Icons.local_hospital),
    title: Text("KNUST Hospital"),
    subtitle: Text("2.3 km away"),
  ),
),

Card(
  child: ListTile(
    leading: Icon(Icons.local_hospital),
    title: Text("University Hospital"),
    subtitle: Text("3.8 km away"),
  ),
),

Card(
  child: ListTile(
    leading: Icon(Icons.local_hospital),
    title: Text("Komfo Anokye"),
    subtitle: Text("5.6 km away"),
  ),
),

            Wrap(
              spacing: 10,
              children: [
                ActionChip(
                  label: const Text("Emergency"),
                  onPressed: () {},
                ),
                ActionChip(
                  label: const Text("Find Hospital"),
                  onPressed: () {},
                ),
                ActionChip(
                  label: const Text("Appointments"),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}