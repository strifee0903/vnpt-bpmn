import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../components/colors.dart';
import 'add_moment_section.dart';

class AddMomentPage extends StatefulWidget {
  const AddMomentPage({super.key});

  @override
  _AddMomentPageState createState() => _AddMomentPageState();
}

class _AddMomentPageState extends State<AddMomentPage> {
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _post() {
    Navigator.pop(context); // Tạm thời quay lại, thay bằng logic thực tế
  }

  @override
  void dispose() {
    _contentController.dispose();
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
          'Create Announcement Post', // Giữ tiêu đề giống Step2
          style: TextStyle(
            fontFamily: 'Oktah',
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        // Bọc toàn bộ nội dung để hỗ trợ cuộn
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AddPostSection(
                contentController: _contentController,
                selectedImage: _selectedImage,
                onPickImage: _pickImage,
                avatarPath: 'assets/images/pagediary.png',
                username: 'jane smith',
              ),
              const SizedBox(height: 16.0), // Thêm khoảng cách trước nút Post
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: _post,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: button,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  child: const Text(
                    'Post',
                    style: TextStyle(
                      fontFamily: 'Oktah',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
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
