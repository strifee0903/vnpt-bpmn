import 'dart:io';
import 'package:flutter/material.dart';
import 'package:greenly_app/ui/pages/campaign/addcampaign/success_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../components/colors.dart';
import '../../../moments/add_moment_section.dart'; // Import widget mới
import '../campaign_manager.dart';
import 'package:greenly_app/services/moment_service.dart';
import 'package:greenly_app/models/moment.dart';
import 'package:greenly_app/models/category.dart';
import 'package:greenly_app/services/category_service.dart';

class Step2 extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool isLast;
  final void Function(String message) onComplete;
  const Step2({
    super.key,
    required this.onNext,
    required this.onBack,
    this.isLast = false,
    required this.onComplete,
  });

  @override
  State<Step2> createState() => _Step2State();
}

class _Step2State extends State<Step2> {
  Moment? moment;
  final MomentService momentService = MomentService();
  final CategoryService categoryService = CategoryService();
  final List<Category> categories = [];
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

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => const SuccessDialog(),
    );
  }

  @override
  void initState() {
    super.initState();
    // Khởi tạo moment nếu cần
    int? id = context.read<CampaignManager>().campaignId;

    if (id != null) {
      print('🔍 DEBUG - Campaign ID: $id');
      // Nếu có id, lấy thông tin moment từ service
      momentService.getMomentById(id).then((value) {
        setState(() {
          moment = value;
          contentController.text = moment?.content ?? '';
          selectedImage = (moment?.media != null && moment!.media!.isNotEmpty)
              ? File(moment!.media.first.media_url)
              : null;
        });
      });
    }
    print(moment?.category);
    // Lấy danh sách category
    categoryService.getAllCategories().then((value) {
      setState(() {
        categories.addAll(value);
      });
    });
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
                categories: categories,
                selectedCategory: moment?.category,
                onCategoryChanged: (value) {},
                selectedMomentType: moment?.type,
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
          if (widget.isLast) {
            // Nếu là bước cuối cùng, hiển thị dialog thành công
            showSuccessDialog();
            return;
          }
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
