import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../shared/appbar.dart'; // Import the custom AppBar
import '../../components/colors.dart'; // Import colors.dart

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GreenlyApp',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Track the selected tab

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index; // Update the selected index
    });
    // Add navigation logic here if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background, // Đặt màu nền toàn bộ Scaffold là background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with Farm Name and Weather Info
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text(
                      'Can Tho',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Oktah',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.more_vert),
                  ],
                ),
              ),
              // Greenly App Section with Overlay Box and Add Post
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none, // Allow overlay to extend
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/we.png',
                          height: 210,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 15,
                      left: 15,
                      right: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Share Your Moment',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Oktah',
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Capture your favorite memories',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Oktah',
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: FloatingActionButton(
                                onPressed: () {
                                  _onTabTapped(2);
                                },
                                backgroundColor: button,
                                elevation: 0,
                                mini: false,
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(right: 135.0),
                child: const Text(
                  'Explore Your Options',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Oktah',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Grid of Options (2x2 layout)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.19,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildOptionCard(
                      'My Diary',
                      'assets/images/mydiary.png',
                      const Color(0xFFFFFFFF),
                      const Color(0xFFFFFFFF),
                    ),
                    _buildOptionCard(
                      'Green Library',
                      'assets/images/greenlibrary.jpg',
                      const Color(0xFFFFFFFF),
                      const Color(0xFFFFFFFF),
                    ),
                    _buildOptionCard(
                      'Campaign',
                      'assets/images/campaign.jpg',
                      const Color(0xFFFFFFFF),
                      const Color(0xFFFFFFFF),
                    ),
                    _buildOptionCard(
                      'Contribution',
                      'assets/images/contribution.png',
                      const Color(0xFFFFFFFF),
                      const Color(0xFFFFFFFF),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Custom Bottom AppBar
      bottomNavigationBar: CustomBottomAppBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildOptionCard(
      String title, String imagePath, Color backgroundColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.all(0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: backgroundColor,
        child: InkWell(
          onTap: () {
            if (title == 'My Diary') {
              Navigator.pushNamed(context, '/myDiary');
            } else if (title == 'Green Library') {
              Navigator.pushNamed(context, '/greenLibrary');
            }
          },
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.15),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              Positioned(
                bottom: 11,
                left: 11,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Oktah',
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
