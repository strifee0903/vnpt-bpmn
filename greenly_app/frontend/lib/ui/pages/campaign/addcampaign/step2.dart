import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../components/colors.dart';
import '../../../moments/add_moment_section.dart'; // Import widget mới
import 'step3.dart'; // Import file Step3.dart

class Step2 extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const Step2({super.key, required this.onNext, required this.onBack});

  @override
  State<Step2> createState() => _Step2State();
}

class _Step2State extends State<Step2> {
  final TextEditingController contentController = TextEditingController();
  File? selectedImage;
  final ImagePicker picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  void handlePost() {
    // Logic xử lý đăng bài, có thể hiển thị snackbar hoặc lưu post
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post submitted successfully')),
    );
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset:
          true, // Cho phép điều chỉnh layout khi bàn phím xuất hiện
      appBar: AppBar(
        backgroundColor: button,
        elevation: 0,
        title: const Text(
          'Create Announcement Post',
          style: TextStyle(
            fontFamily: 'Oktah',
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => widget.onBack(), // Gọi hàm onBack từ widget
        ),
      ),
      body: SingleChildScrollView(
        // Bọc toàn bộ nội dung để hỗ trợ cuộn
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              16.0, 16.0, 16.0, 96.0), // Kết hợp padding all và bottom
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AddPostSection(
                contentController: contentController,
                selectedImages: selectedImage != null ? [selectedImage!] : [],
                onPickImages: pickImage,
                avatarPath: 'assets/images/pagediary.png',
                username: 'jane smith',
                categories: [],
                selectedCategory: null,
                onCategoryChanged: (value) {},
                selectedMomentType: null,
                onMomentTypeChanged: (value) {},
                isPublic: true,
                onPublicChanged: (value) {},
              ),
              const SizedBox(height: 16.0), // Thêm khoảng cách
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) => const Step3()), // Chuyển sang Step3
          // );
          widget.onNext(); // Gọi hàm onNext từ widget cha
        },
        backgroundColor: button,
        label: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 13.0, vertical: 8.0), // Padding cho chữ Next
          child: const Text(
            'Next',
            style: TextStyle(
              fontFamily: 'Oktah',
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // Góc bo tròn giống Step1
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Đặt ở góc dưới bên phải
    );
  }
}
