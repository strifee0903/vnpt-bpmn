import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'auth_card.dart';
import 'package:weather_animation/weather_animation.dart';
import 'package:lottie/lottie.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E8), // Light mint green
              Color(0xFFB8E6B8), // Soft green
              Color(0xFF81C784), // Medium green
              Color(0xFF66BB6A), // Vibrant green
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Cloud 1 with rain and surrounding elements
            Positioned(
              top: size.height * 0.01,
              left: size.width * 0.2 - 100,
              child: SizedBox(
                width: 200,
                height: 300,
                child: Stack(
                  children: [
                    // Floating leaves near Cloud 1
                    ...List.generate(
                        8,
                        (index) =>
                            _buildFloatingLeaf(size, index, isLeft: true)),

                    Align(
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 190, 209, 212)
                                  .withAlpha(10),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Lottie.asset(
                          'assets/animations/cloud.json',
                          width: 260,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -30,
                      left: -100,
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: RainWidget(
                          rainConfig: RainConfig(
                            count: 40,
                            lengthDrop: 10,
                            widthDrop: 2,
                            color: Color.fromARGB(180, 169, 221, 254),
                            isRoundedEndsDrop: true,
                            fallRangeMinDurMill: 800,
                            fallRangeMaxDurMill: 2000,
                            slideDurMill: 800,
                            slideCurve: Curves.linear,
                            fallCurve: Curves.easeIn,
                            fadeCurve: Curves.easeOut,
                          ),
                        ),
                      ),
                    ),
                    // Ground plants under Cloud 1
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildPlant(Icons.grass, Colors.green.shade400, 30),
                            _buildPlant(
                                Icons.local_florist, Colors.green.shade500, 25),
                            _buildPlant(Icons.eco, Colors.green.shade600, 35),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Cloud 2 with rain and surrounding elements
            Positioned(
              top: 0,
              right: -30,
              child: SizedBox(
                width: 150,
                height: 250,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Floating leaves near Cloud 2
                    ...List.generate(
                        8,
                        (index) =>
                            _buildFloatingLeaf(size, index, isLeft: false)),

                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 190, 209, 212)
                                  .withAlpha(10),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 150,
                          height: 120,
                          child: Lottie.asset(
                            'assets/animations/cloud.json',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -60,
                      left: -100,
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: RainWidget(
                          rainConfig: RainConfig(
                            count: 40,
                            lengthDrop: 10,
                            widthDrop: 2,
                            color: Color.fromARGB(180, 169, 221, 254),
                            isRoundedEndsDrop: true,
                            fallRangeMinDurMill: 800,
                            fallRangeMaxDurMill: 2000,
                            slideDurMill: 800,
                            slideCurve: Curves.linear,
                            fallCurve: Curves.easeIn,
                            fadeCurve: Curves.easeOut,
                          ),
                        ),
                      ),
                    ),
                    // Ground plants under Cloud 2
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildPlant(
                                Icons.nature, Colors.green.shade400, 28),
                            _buildPlant(Icons.grass, Colors.green.shade500, 32),
                            _buildPlant(
                                Icons.local_florist, Colors.green, 28),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Auth card section (clean, without plants)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    width: size.width,
                    height: size.height * 0.7,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: const AuthCard(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingLeaf(Size size, int index, {required bool isLeft}) {
    final random = Random(index);
    final top =
        size.height * (0.1 + random.nextDouble() * 0.3); // 10%-40% of height
    final left = isLeft
        ? size.width * (0.1 + random.nextDouble() * 0.3) // Left cloud area
        : size.width * (0.6 + random.nextDouble() * 0.3); // Right cloud area

    final leafIcons = [
      Icons.eco,
      Icons.local_florist,
      Icons.nature,
      Icons.grass,
    ];

    return Positioned(
      top: top,
      left: left,
      child: TweenAnimationBuilder(
        duration: Duration(seconds: 3 + (index % 3)),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          return Transform.translate(
            offset: Offset(
              sin(value * 2 * pi) * 20,
              cos(value * 2 * pi) * 10,
            ),
            child: Transform.rotate(
              angle: value * 2 * pi,
              child: Icon(
                leafIcons[index % leafIcons.length],
                color: Colors.green.shade300.withOpacity(0.6),
                size: 20 + (index % 3) * 5,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlant(IconData icon, Color color, double size) {
    return TweenAnimationBuilder(
      duration: const Duration(seconds: 2),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: 0.8 + (sin(value * 2 * pi) * 0.1),
          child: Icon(
            icon,
            color: color.withOpacity(0.8),
            size: size,
          ),
        );
      },
    );
  }
}
