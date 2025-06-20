import 'package:flutter/material.dart';
import 'package:greenly_app/ui/pages/profile/profile_screen.dart';
import '../components/colors.dart';
import '../shared/appbar.dart'; // CustomBottomAppBar
import '../ui/home/home.dart'; // HomePage
import '../ui/moments/moments.dart'; // MomentsPage

import '../ui/pages/greenmap/greenmap.dart'; // Assuming you have a MapsPage

class MainLayout extends StatefulWidget {
  final int initialIndex;
  const MainLayout({super.key, this.initialIndex = 0});

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: const [
            HomePage(),
            MomentsPage(),
            GreenMap(),
            ProfileScreen(), // Removed showBottomNav since it's handled by MainLayout
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
