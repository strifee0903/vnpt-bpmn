import 'package:flutter/material.dart';
import 'package:greenly_app/ui/home/home.dart'; // Import HomePage
import 'ui/pages/mydiary/mydiary.dart';
import 'ui/pages/greenlibrary/greenlibrary.dart'; // Import GreenLibrary
import 'ui/moments/moments.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/myDiary': (context) => const MyDiary(),
        '/greenLibrary': (context) => const GreenLibrary(),
        '/moments': (context) => const MomentsPage(),
      },
    );
  }
}
