import 'package:flutter/material.dart';
import 'package:greenly_app/components/colors.dart';
import 'package:greenly_app/ui/pages/campaign/addcampaign/success_dialog.dart';

class Blank extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool isLast; // Biến để xác định bước cuối cùng
  final void Function(String message) onComplete;

  const Blank(
      {super.key,
      required this.onNext,
      required this.onBack,
      required this.isLast,
      required this.onComplete});

  @override
  Widget build(BuildContext context) {
    void showSuccessDialog() {
      showDialog(
        context: context,
        builder: (context) => const SuccessDialog(),
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: button,
        title: const Text(
          'Blank Page',
          style: TextStyle(
            fontFamily: 'montserrat',
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            onBack(); // Gọi hàm onBack từ widget
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Text(
            'This is a blank page.',
            style: TextStyle(fontSize: 24, color: Colors.grey[700]),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (isLast) {
            showSuccessDialog();
            return;
          }
          onNext();
        },
        backgroundColor: button,
        label: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 8.0),
          child: const Text(
            'Next',
            style: TextStyle(
              fontFamily: 'montserrat',
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
