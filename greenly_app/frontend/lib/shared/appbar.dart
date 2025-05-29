import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../components/colors.dart'; // Import colors.dart

class CustomBottomAppBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomAppBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color.fromARGB(255, 255, 255, 255))),
      child: Stack(
        clipBehavior: Clip.none, // Allow overflow for elevation
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 4), // Dời xuống dưới 8px, có thể điều chỉnh giá trị này
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(FontAwesomeIcons.house, 0, 'Home'),
                _buildNavItem(FontAwesomeIcons.book, 1, 'Post'),
                const SizedBox(
                    width: 48), // Placeholder for the elevated button
                _buildNavItem(FontAwesomeIcons.locationDot, 3, 'Maps'),
                _buildNavItem(FontAwesomeIcons.userLarge, 4, 'Profile'),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 30, // Elevate halfway above the app bar
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromARGB(255, 253, 253, 253),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildNavItem(FontAwesomeIcons.plus, 2, 'Add Post'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    return IconButton(
      icon: Icon(
        icon,
        color: currentIndex == index ? button : Colors.grey,
        size: 21, // Giảm kích thước icon
      ),
      tooltip: label,
      onPressed: () => onTap(index),
    );
  }
}
