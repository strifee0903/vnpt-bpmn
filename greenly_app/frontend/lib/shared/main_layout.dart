import 'package:flutter/material.dart';
import 'package:greenly_app/ui/pages/profile/profile_screen.dart';
import 'package:provider/provider.dart';
import '../ui/auth/auth_manager.dart';
import '../components/colors.dart';
import '../shared/appbar.dart'; // CustomBottomAppBar
import '../ui/home/home.dart'; // HomePage
import '../ui/moments/moments.dart'; // MomentsPage

import '../ui/pages/greenmap/greenmap.dart'; // Assuming you have a MapsPage

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0; // Default to Home

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<AuthManager>(context);
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: const [
            HomePage(),
            MomentsPage(),
            GreenMap(), // Assuming MapsPage is defined in your project
            ProfileScreen(), // Assuming UserScreen is defined in your project
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
