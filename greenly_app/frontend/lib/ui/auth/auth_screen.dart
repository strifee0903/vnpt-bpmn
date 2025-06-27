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
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFBBDEFB),
              Color(0xFF90CAF9),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Cloud 1 with rain
            Positioned(
              top: size.height * 0.1,
              left: -50,
              child: SizedBox(
                width: 200,
                height: 300,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: 0,
                      child: SizedBox(
                        width: 200,
                        height: 150,
                        child: Lottie.asset(
                          'assets/animations/cloud.json',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 130,
                      child: SizedBox(
                        width: 200,
                        height: 170,
                        child: RainWidget(
                          rainConfig: RainConfig(
                            count: 40,
                            lengthDrop: 10,
                            widthDrop: 2,
                            color: Color.fromARGB(180, 255, 255, 255),
                            isRoundedEndsDrop: true,
                            fallRangeMinDurMill: 800,
                            fallRangeMaxDurMill: 2000,
                            slideX: 20,
                            slideY: 100,
                            slideDurMill: 800,
                            slideCurve: Curves.linear,
                            fallCurve: Curves.easeIn,
                            fadeCurve: Curves.easeOut,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Cloud 2 with rain
            Positioned(
              top: size.height * 0.05,
              right: -30,
              child: SizedBox(
                width: 150,
                height: 250,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: 0,
                      child: SizedBox(
                        width: 150,
                        height: 120,
                        child: Lottie.asset(
                          'assets/animations/cloud.json',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 105,
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: RainWidget(
                          rainConfig: RainConfig(
                            count: 30,
                            lengthDrop: 8,
                            widthDrop: 2,
                            color: Color.fromARGB(180, 255, 255, 255),
                            isRoundedEndsDrop: true,
                            fallRangeMinDurMill: 700,
                            fallRangeMaxDurMill: 1800,
                            slideX: 15,
                            slideY: 80,
                            slideDurMill: 700,
                            slideCurve: Curves.linear,
                            fallCurve: Curves.easeIn,
                            fadeCurve: Curves.easeOut,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // App logo (optional, bạn có thể bật lại nếu muốn)
            // Positioned(
            //   top: 50,
            //   left: 0,
            //   right: 0,
            //   child: Center(
            //     child: Container(
            //       width: 80,
            //       height: 80,
            //       decoration: BoxDecoration(
            //         shape: BoxShape.circle,
            //         color: Colors.white.withOpacity(0.2),
            //         boxShadow: [
            //           BoxShadow(
            //             color: Colors.white.withOpacity(0.3),
            //             blurRadius: 10,
            //             spreadRadius: 2,
            //           ),
            //         ],
            //       ),
            //       child: Stack(
            //         alignment: Alignment.center,
            //         children: [
            //           Icon(
            //             Icons.water_drop,
            //             color: Colors.white.withOpacity(0.9),
            //             size: 50,
            //           ),
            //           Positioned(
            //             bottom: 10,
            //             child: Text(
            //               'Greenly',
            //               style: TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 12,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),

            // Auth card section
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    width: size.width,
                    height: size.height * 0.65,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
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
}
