import 'package:flutter/material.dart';
import '../../../components/colors.dart'; // Import colors.dart
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyDiary extends StatelessWidget {
  const MyDiary({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample list of diary entries with time and custom icon
    final List<Map<String, dynamic>> diaryEntries = [
      {
        'title': 'Planting Trees',
        'description': 'Planted 10 new trees in the garden.',
        'time': '09:30 AM, May 29, 2025',
        'icon': FontAwesomeIcons.tree, // Custom icon for this entry
      },
      {
        'title': 'Watering Plants',
        'description': 'Watered all plants this morning.',
        'time': '08:15 AM, May 29, 2025',
        'icon': FontAwesomeIcons.filter, // Custom icon for this entry
      },
    ];

    // List of color pairs for each diary entry (background and text color)
    final List<Map<String, Color>> entryColors = [
      {
        'background': const Color.fromARGB(255, 255, 255, 255), // Light green
        'text': const Color.fromARGB(255, 0, 0, 0), // Dark green
      },
      {
        'background': const Color.fromARGB(255, 255, 253, 253), // Lighter green
        'text': const Color.fromARGB(255, 0, 0, 0), // Medium green
      },
    ];

    return Scaffold(
      backgroundColor: background,
      // Đặt màu nền toàn trang là background
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0, // White background
        // Black text color
        title: const Text(
          'My Diary',
          style: TextStyle(
            fontFamily: 'Oktah',
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end, // Align to the right
            children: [
              // + Icon
              Container(
                margin: const EdgeInsets.only(
                    right: 20.0, top: 5.0), // Minimal bottom margin
                decoration: BoxDecoration(
                  color: button,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50), // Subtle black shadow
                      blurRadius: 3, // Reduced blur for compactness
                      offset: const Offset(0, 1), // Minimal offset
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.add,
                    size: 24, // Further reduced size
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                  onPressed: () {
                    // Add diary logic here
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              // Speech Bubble
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add Diary Section (Image only)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/images/pagediary.png',
                    height: 210,
                    fit: BoxFit.cover,
                  ),
                ),
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
                      color: colors[
                          'background'], // Sử dụng màu nền từ entryColors
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 1, 15, 1)
                              .withAlpha((0.1 * 255).toInt()),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry['title']!,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Oktah',
                                    fontWeight: FontWeight.w700,
                                    color: colors['text'], // Unique text color
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  entry['description']!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Oktah',
                                    fontWeight: FontWeight.w500,
                                    color: colors['text']!.withOpacity(
                                        0.7), // Slightly lighter for description
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  entry['time']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Oktah',
                                    fontWeight: FontWeight.w500,
                                    color: colors['text']!.withOpacity(
                                        0.5), // Even lighter for time
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                                entry['icon']), // Custom icon for each entry
                            color: colors['text']!.withOpacity(0.7),
                            onPressed: () {
                              // Action logic here
                            },
                            iconSize: 24,
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
