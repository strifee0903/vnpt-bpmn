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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Container(
          height: 66,
          color: button,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                  context, FontAwesomeIcons.house, 0, 'Home', 17.0, 0.0, 5.0),
              _buildNavItem(
                  context, FontAwesomeIcons.book, 1, 'Post', 17.0, 0.0, 5.0),
              _buildNavItem(context, FontAwesomeIcons.locationDot, 2, 'Maps',
                  17.0, 0.0, 4.0),
              _buildNavItem(context, FontAwesomeIcons.userLarge, 3, 'Profile',
                  16.0, 0.0, 4.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context,
      IconData icon,
      int index,
      String label,
      double iconPaddingLeft,
      double labelPaddingLeft,
      double labelPaddingTop) {
    bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        onTap(index); // Gọi callback để cập nhật currentIndex ở HomePage
        // Điều hướng đến các trang tương ứng
        switch (index) {
          case 0:
            // Trang Home: Pop đến trang gốc (nếu cần) hoặc không làm gì
            Navigator.popUntil(context, (route) => route.isFirst);
            break;
          case 1:
            Navigator.pushNamed(context, '/moments'); // Chuyển đến MomentsPage
            break;
          case 2:
            Navigator.pushNamed(
                context, '/maps'); // Chuyển đến Maps (cần tạo nếu chưa có)
            break;
          case 3:
            Navigator.pushNamed(context,
                '/profile'); // Chuyển đến Profile (cần tạo nếu chưa có)
            break;
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: isSelected ? 120.0 : 50.0,
        height: 40.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: isSelected ? 120.0 : 50.0,
              height: 40.0,
              decoration: BoxDecoration(
                borderRadius: isSelected
                    ? BorderRadius.circular(17.0)
                    : BorderRadius.zero,
                color: isSelected
                    ? const Color.fromARGB(255, 255, 255, 255)
                    : Colors.transparent,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: iconPaddingLeft),
                    child: Transform.translate(
                      offset: icon == FontAwesomeIcons.house
                          ? const Offset(-1, 0)
                          : Offset.zero,
                      child: Icon(
                        icon,
                        color: isSelected
                            ? const Color.fromARGB(255, 63, 78, 45)
                            : const Color.fromARGB(255, 255, 255, 255),
                        size: 19,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Flexible(
                      fit: FlexFit.loose,
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: labelPaddingLeft, top: labelPaddingTop),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 63, 78, 45),
                              fontSize: 16,
                              fontFamily: 'Oktah',
                              fontWeight: FontWeight.w900,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
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
