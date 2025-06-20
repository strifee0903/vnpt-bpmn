import 'package:flutter/material.dart';
import '../campaign.dart'; // Import file campaign.dart

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Success',
        style: TextStyle(
          fontFamily: 'Oktah',
          fontWeight: FontWeight.w900,
        ),
      ),
      content: const Text(
        'Campaign created successfully!',
        style: TextStyle(
          fontFamily: 'Oktah',
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // đóng dialog
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const Campaign()),
              (route) => route.isFirst, // hoặc tùy bé logic
            );
          },
          child: const Text(
            'Go to Campaigns',
            style: TextStyle(
              fontFamily: 'Oktah',
              fontWeight: FontWeight.w700,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}
