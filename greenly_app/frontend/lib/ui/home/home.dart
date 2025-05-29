import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../shared/appbar.dart'; // Import the custom AppBar
import '../../components/colors.dart'; // Import colors.dart

void main() {
  runApp(const MyApp());
}

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
      body: Container(
        color: background, // Use background color from colors.dart
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header with Farm Name and Weather Info
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text(
                        'Can Tho',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      const Icon(Icons.more_vert),
                    ],
                  ),
                ),
                // Greenly App Section with Overlay Box and Add Post
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none, // Allow overlay to extend
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.asset(
                            'assets/images/we.jpg',
                            height: 210,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 15, // Position near the bottom of the image
                        left: 15, // Reduced from 20 to fit within frame
                        right: 15, // Reduced from 20 to fit within frame
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 17.0), // Reduced padding
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
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
                                        fontSize: 17, // Reduced from 16
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Capture and share your favorite memories',
                                      style: TextStyle(
                                        fontSize: 12, // Reduced from 14
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Transform.scale(
                                scale:
                                    0.8, // Adjust scale factor (e.g., 1.5 for even larger)
                                child: FloatingActionButton(
                                  onPressed: () {
                                    _onTabTapped(2);
                                  },
                                  backgroundColor:
                                      const Color.fromARGB(255, 49, 107, 51),
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

                const SizedBox(height: 15),

                Padding(
                  padding: const EdgeInsets.only(right: 135.0),
                  child: const Text(
                    'Explore Your Options', // Changed title
                    textAlign: TextAlign.left, // Align to left
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                // Grid of Options (2x2 layout)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio:
                        1.19, // Adjust to fit 2x2 without overflow
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildOptionCard(
                        'My Diary',
                        'assets/images/mydiary.png',
                        const Color(0xFFFFFFFF), // Default card color
                        const Color(0xFFFFFFFF), // Dark green for contrast
                      ),
                      _buildOptionCard(
                        'Green Library',
                        'assets/images/greenlibrary.jpg',
                        const Color(0xFFFFFFFF), // Default card color
                        const Color(0xFFFFFFFF), // White for contrast
                      ),
                      _buildOptionCard(
                        'Campaign',
                        'assets/images/campaign.jpg',
                        const Color(0xFFFFFFFF), // Default card color
                        const Color(0xFFFFFFFF), // White for contrast
                      ),
                      _buildOptionCard(
                        'Contribution',
                        'assets/images/contribution.png',
                        const Color(0xFFFFFFFF), // Default card color
                        const Color(0xFFFFFFFF), // Dark green for contrast
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
      margin: const EdgeInsets.all(0), // Removed right margin for grid
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: backgroundColor, // Use default card color
        child: InkWell(
          onTap: () {
            if (title == 'My Diary') {
              Navigator.pushNamed(context, '/myDiary');
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
                      Colors.black.withOpacity(0.8), // Darkest at the bottom
                      Colors.black.withOpacity(0.3), // Fades to lighter
                      Colors.transparent, // Transparent at the top
                    ],
                    stops: const [0.0, 0.5, 1.0], // Control gradient transition
                  ),
                ),
              ),
              Positioned(
                bottom: 11,
                left: 11,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
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
