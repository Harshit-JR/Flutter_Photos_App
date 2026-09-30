import 'package:flutter/material.dart';

import 'home_page.dart';
import 'search_page.dart';
import 'saved_page.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
  children: [
    IgnorePointer(
      ignoring: currentIndex != 0,
      child: AnimatedOpacity(
        opacity: currentIndex == 0 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        child: const HomePage(),
      ),
    ),

    IgnorePointer(
      ignoring: currentIndex != 1,
      child: AnimatedOpacity(
        opacity: currentIndex == 1 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        child: const SearchPage(),
      ),
    ),

    IgnorePointer(
      ignoring: currentIndex != 2,
      child: AnimatedOpacity(
        opacity: currentIndex == 2 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        child: const SavedPage(),
      ),
    ),

    IgnorePointer(
      ignoring: currentIndex != 3,
      child: AnimatedOpacity(
        opacity: currentIndex == 3 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        child: const ProfilePage(),
      ),
    ),
  ],
),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}