import 'package:flutter/material.dart';
import '../../../components/colors.dart'; // Import colors.dart

class MyDiary extends StatelessWidget {
  const MyDiary({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample list of diary entries with time
    final List<Map<String, String>> diaryEntries = [
      {
        'title': 'Planting Trees',
        'description': 'Planted 10 new trees in the garden.',
        'time': '09:30 AM, May 29, 2025'
      },
      {
        'title': 'Watering Plants',
        'description': 'Watered all plants this morning.',
        'time': '08:15 AM, May 29, 2025'
      },
    ];

    // List of color pairs for each diary entry (background and text color)
    final List<Map<String, Color>> entryColors = [
      {
        'background': const Color(0xFFE8F5E9), // Light green
        'text': const Color(0xFF1B5E20), // Dark green
      },
      {
        'background': const Color(0xFFF1F8E9), // Lighter green
        'text': const Color(0xFF33691E), // Medium green
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MyDiary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add Diary Section (Moved to Top)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
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
                          horizontal: 12.0, vertical: 17.0),
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
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Capture and share your favorite memories',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
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
                                // Add diary logic here
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
            const SizedBox(height: 16),
            // Diary Entries
            Expanded(
              child: ListView.builder(
                itemCount: diaryEntries.length,
                itemBuilder: (context, index) {
                  final entry = diaryEntries[index];
                  final colors = entryColors[
                      index % entryColors.length]; // Cycle through colors
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: colors['background'], // Unique background color
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry['title']!,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colors['text'], // Unique text color
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry['description']!,
                            style: TextStyle(
                              fontSize: 16,
                              color: colors['text']!.withOpacity(
                                  0.7), // Slightly lighter for description
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry['time']!,
                            style: TextStyle(
                              fontSize: 14,
                              color: colors['text']!
                                  .withOpacity(0.5), // Even lighter for time
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
