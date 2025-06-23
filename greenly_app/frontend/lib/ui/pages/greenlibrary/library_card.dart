import 'package:flutter/material.dart';

class LibraryCard extends StatelessWidget {
  final String image;
  final String title;
  final Color textColor;
  final String processId;
  final Function(String) onTap; // Callback để xử lý khi nhấn

  const LibraryCard({
    super.key,
    required this.image,
    required this.title,
    required this.textColor,
    required this.processId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(processId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        height: 140,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 20,
              right: 35,
              width: (MediaQuery.of(context).size.width - 32) * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Oktah',
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(9.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      'View Details',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Oktah',
                        fontWeight: FontWeight.w700,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
