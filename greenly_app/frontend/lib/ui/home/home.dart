import 'package:flutter/material.dart';
import 'package:greenly_app/ui/moments/add_moment.dart';
import '../../components/colors.dart';
import '../../shared/main_layout.dart'; // Import MainLayout
import '../pages/chat/chat_room.dart'; // Import RoomChatPage

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
      home: const MainLayout(), // Sử dụng MainLayout làm trang chính
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const routeName = '/home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background, // Đặt màu nền là background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Greenly App Section with Overlay Box and Add Post
              Padding(
                padding: const EdgeInsets.all(15),
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
                                    'Chia sẻ khoảnh khắc nào',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Ghi lại từng khoảnh khắc',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Manrope',
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
                                heroTag: 'moment',
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context,
                                      AddMomentPage
                                          .routeName); // Điều hướng trực tiếp đến Moments
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
                padding: const EdgeInsets.only(right: 111.0),
                child: const Text(
                  'Khám Phá Các Tùy Chọn',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Manrope',
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
                      'Nhật ký Xanh',
                      'assets/images/mydiary.png',
                      const Color(0xFFFFFFFF),
                      const Color(0xFFFFFFFF),
                    ),
                    _buildOptionCard(
                      'Thư viện Xanh',
                      'assets/images/greenlibrary.jpg',
                      const Color(0xFFFFFFFF),
                      const Color(0xFFFFFFFF),
                    ),
                    _buildOptionCard(
                      'Chiến dịch Xanh',
                      'assets/images/campaign.jpg',
                      const Color(0xFFFFFFFF),
                      const Color(0xFFFFFFFF),
                    ),
                    _buildOptionCard(
                      'Nhóm Chat',
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
    );
  }

  Widget _buildOptionCard(
      String title, String imagePath, Color backgroundColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.all(0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        color: backgroundColor,
        child: InkWell(
          onTap: () {
            if (title == 'Nhật ký Xanh') {
              Navigator.pushNamed(context, '/myDiary');
            } else if (title == 'Thư viện Xanh') {
              Navigator.pushNamed(context, '/greenLibrary');
            } else if (title == 'Chiến dịch Xanh') {
              Navigator.pushNamed(context, '/campaign');
            } else if (title == 'Nhóm Chat') {
              Navigator.pushNamed(context, '/groupChat');
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
                    fontFamily: 'Manrope',
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
