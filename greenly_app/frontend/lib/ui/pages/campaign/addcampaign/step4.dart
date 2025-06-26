import 'package:flutter/material.dart';

class Blank extends StatelessWidget {
  const Blank({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blank Page'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text(
          'This is a blank page.',
          style: TextStyle(fontSize: 24, color: Colors.grey[700]),
        ),
      ),
    );
  }
}
