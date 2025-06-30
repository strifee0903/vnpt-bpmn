import 'package:flutter/material.dart';
import 'package:greenly_app/components/colors.dart';
import 'package:greenly_app/ui/pages/campaign/addcampaign/success_dialog.dart';
import 'package:greenly_app/ui/pages/campaign/campaign_manager.dart';
import 'package:greenly_app/ui/pages/chat/chat_main.dart';
import 'package:provider/provider.dart';

class Chat extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool isLast; // Biến để xác định bước cuối cùng
  final void Function(String message) onComplete;

  const Chat(
      {super.key,
      required this.onNext,
      required this.onBack,
      required this.isLast,
      required this.onComplete});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  int? campaignId;
  @override
  void initState() {
    super.initState();
    campaignId = context.read<CampaignManager>().campaignId;
  }

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
            widget.onBack(); // Gọi hàm onBack từ widget
          },
        ),
      ),
      body: SafeArea(
          child: ChatMain(
        selectedCampaignId: campaignId,
      )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (widget.isLast) {
            showSuccessDialog();
            return;
          }
          widget.onNext();
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
