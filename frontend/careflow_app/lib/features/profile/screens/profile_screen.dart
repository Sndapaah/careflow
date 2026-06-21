import 'package:flutter/material.dart';
import '../../../widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
      ),

      bottomNavigationBar:
          const BottomNavBar(currentIndex: 2),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [

          CircleAvatar(
            radius: 50,
            child: Icon(Icons.person,size:50),
          ),

          SizedBox(height:20),

          Card(
            child: ListTile(
              title: Text("Name"),
              subtitle: Text("Nana Sarpong"),
            ),
          ),

          Card(
            child: ListTile(
              title: Text("Blood Group"),
              subtitle: Text("O+"),
            ),
          ),

          Card(
            child: ListTile(
              title: Text("Emergency Contact"),
              subtitle: Text("+233 XX XXX XXXX"),
            ),
          ),

          Card(
            child: ListTile(
              title: Text("Medical Conditions"),
              subtitle: Text("None"),
            ),
          ),
        ],
      ),
    );
  }
}