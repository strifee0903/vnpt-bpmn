import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../components/colors.dart';
import 'success_dialog.dart'; // Import file success_dialog.dart

class Step3 extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool isLast;
  final void Function(String message) onComplete;
  const Step3(
      {super.key,
      required this.onNext,
      required this.onBack,
      this.isLast = false,
      required this.onComplete});

  @override
  State<Step3> createState() => _Step3State();
}

class _Step3State extends State<Step3> {
  final TextEditingController emailController = TextEditingController();
  final String campaignLink = 'https://example.com/campaign123'; // Link mẫu

  void copyLinkToClipboard() {
    Clipboard.setData(ClipboardData(text: campaignLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard!')),
    );
  }

  void sendInvite() {
    if (emailController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invitation sent to ${emailController.text}')),
      );
      emailController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email address')),
      );
    }
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => const SuccessDialog(),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: button,
        elevation: 0,
        title: const Text(
          'Campaign Participant',
          style: TextStyle(
            fontFamily: 'montserrat',
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => widget.onBack() // Gọi hàm onBack từ widget
          ,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 96.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Share via Link',
                  style: TextStyle(
                    fontFamily: 'montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: fieldborder),
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        child: Text(
                          campaignLink,
                          style: const TextStyle(
                            fontFamily: 'montserrat',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    ElevatedButton(
                      onPressed: copyLinkToClipboard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: button,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Copy',
                        style: TextStyle(
                          fontFamily: 'montserrat',
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Invite via Email',
                  style: TextStyle(
                    fontFamily: 'montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: emailController,
                  cursorColor: button,
                  style: const TextStyle(
                    fontFamily: 'montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter email address',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: fieldborder),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: fieldborder),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: button),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.centerLeft, // Dời sang lề trái
                  child: ElevatedButton(
                    onPressed: sendInvite,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: button,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'Send Invite',
                      style: TextStyle(
                        fontFamily: 'montserrat',
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (widget.isLast) {
            // Nếu là bước cuối cùng, hiển thị dialog thành công
            showSuccessDialog();
            return;
          }
          // Hiển thị dialog thành công
          widget.onNext();
        }, // Gọi dialog khi nhấn Next
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

// File campaign.dart (giả định nội dung cơ bản)
class Campaign extends StatelessWidget {
  const Campaign({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaigns'),
      ),
      body: const Center(
        child: Text('Welcome to Campaigns Page!'),
      ),
    );
  }
}
