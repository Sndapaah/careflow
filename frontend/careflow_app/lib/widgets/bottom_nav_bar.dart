import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,

      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(
              context,
              '/home',
            );
            break;

          case 1:
            Navigator.pushReplacementNamed(
              context,
              '/recommendations',
            );
            break;

          case 2:
            Navigator.pushReplacementNamed(
              context,
              '/profile',
            );
            break;
        }
      },

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.local_hospital),
          label: "Hospitals",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}