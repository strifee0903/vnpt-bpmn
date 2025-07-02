// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:greenly_app/services/user_service.dart';
// import 'package:greenly_app/ui/pages/campaign/addcampaign/success_dialog.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import '../../../../components/colors.dart';
// import '../../../moments/add_moment_section.dart'; // Import widget mới
// import '../campaign_manager.dart';
// import 'package:greenly_app/services/moment_service.dart';
// import 'package:greenly_app/models/moment.dart';
// import 'package:greenly_app/models/category.dart';
// import 'package:greenly_app/services/category_service.dart';

// class Step2 extends StatefulWidget {
//   final VoidCallback onNext;
//   final VoidCallback onBack;
//   final bool isLast;
//   final void Function(String message) onComplete;
//   const Step2({
//     super.key,
//     required this.onNext,
//     required this.onBack,
//     this.isLast = false,
//     required this.onComplete,
//   });

//   @override
//   State<Step2> createState() => _Step2State();
// }

// class _Step2State extends State<Step2> {
//   Moment? moment;
//   final MomentService momentService = MomentService();
//   final UserService userService = UserService();
//   final CategoryService categoryService = CategoryService();
//   final List<Category> categories = [];
//   final TextEditingController contentController = TextEditingController();
//   File? selectedImage;
//   final ImagePicker picker = ImagePicker();
//   int? _currentUserId;
//   String? _username;
//   File? _avatarFile;
//   String? _errorMessage;

//   Future<void> _fetchUserId() async {
//     try {
//       final user = await userService.getCurrentUser();
//       if (mounted) {
//         setState(() {
//           _currentUserId = user?.u_id;
//           _username = user?.u_name;
//           _avatarFile = user?.u_avt != null ? File(user!.u_avt!) : null;

//           print('✅ Current User ID: ${_currentUserId}');
//         });
//       }
//     } catch (e) {
//       print('⚠️ Failed to fetch user: $e');
//       if (mounted) {
//         setState(() {
//           _currentUserId = null;
//           _errorMessage = 'Failed to load user data. Please log in again.';
//         });
//       }
//     }
//   }

//   Future<void> pickImage() async {
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() {
//         selectedImage = File(image.path);
//       });
//     }
//   }

//   void handlePost() {
//     // Logic xử lý đăng bài, có thể hiển thị snackbar hoặc lưu post
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Post submitted successfully')),
//     );
//   }

//   void showSuccessDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => const SuccessDialog(),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     // Khởi tạo moment nếu cần
//     int? id = context.read<CampaignManager>().campaignId;
//     _fetchUserId();
//     if (id != null) {
//       print('🔍 DEBUG - Campaign ID: $id');
//       // Nếu có id, lấy thông tin moment từ service
//       momentService.getMomentById(id).then((value) {
//         setState(() {
//           moment = value;
//           contentController.text = moment?.content ?? '';
//           selectedImage = (moment?.media != null && moment!.media.isNotEmpty)
//               ? File(moment!.media.first.media_url)
//               : null;
//         });
//       });
//     }
//     print(moment?.category);
//     // Lấy danh sách category
//     categoryService.getAllCategories().then((value) {
//       setState(() {
//         categories.addAll(value);
//       });
//     });
//   }

//   @override
//   void dispose() {
//     contentController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: background,
//       resizeToAvoidBottomInset:
//           true, // Cho phép điều chỉnh layout khi bàn phím xuất hiện
//       appBar: AppBar(
//         backgroundColor: button,
//         elevation: 0,
//         title: const Text(
//           'Tạo bài thông báo',
//           style: TextStyle(
//             fontFamily: 'montserrat',
//             fontWeight: FontWeight.w900,
//             color: Colors.white,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => widget.onBack(), // Gọi hàm onBack từ widget
//         ),
//       ),
//       body: SingleChildScrollView(
//         // Bọc toàn bộ nội dung để hỗ trợ cuộn
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(
//               16.0, 16.0, 16.0, 96.0), // Kết hợp padding all và bottom
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               AddPostSection(
//                 contentController: contentController,
//                 selectedImages: selectedImage != null ? [selectedImage!] : [],
//                 onPickImages: pickImage,
//                 avatarPath: moment?.user?.u_avt ?? '',
//                 username: _username ?? 'User',
//                 categories: categories,
//                 selectedCategory: moment?.category,
//                 onCategoryChanged: (value) {},
//                 selectedMomentType: moment?.type,
//                 onMomentTypeChanged: (value) {},
//                 isPublic: true,
//                 onPublicChanged: (value) {},
//               ),
//               const SizedBox(height: 16.0), // Thêm khoảng cách
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           if (widget.isLast) {
//             // Nếu là bước cuối cùng, hiển thị dialog thành công
//             showSuccessDialog();
//             return;
//           }
//           widget.onNext(); // Gọi hàm onNext từ widget cha
//         },
//         backgroundColor: button,
//         label: Padding(
//           padding: const EdgeInsets.symmetric(
//               horizontal: 13.0, vertical: 8.0), // Padding cho chữ Next
//           child: const Text(
//             'Next',
//             style: TextStyle(
//               fontFamily: 'montserrat',
//               fontSize: 16,
//               color: Colors.white,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15.0), // Góc bo tròn giống Step1
//         ),
//       ),
//       floatingActionButtonLocation:
//           FloatingActionButtonLocation.endFloat, // Đặt ở góc dưới bên phải
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:greenly_app/services/moment_service.dart';
import 'package:greenly_app/services/category_service.dart';
import 'package:greenly_app/models/moment.dart';
import 'package:greenly_app/models/category.dart';
import 'package:greenly_app/ui/pages/campaign/addcampaign/success_dialog.dart';
import 'package:greenly_app/components/colors.dart';
import 'package:greenly_app/ui/moments/add_moment_section.dart';
import '../../profile/user_manager.dart';
import '../campaign_manager.dart';
// import '../pages/profile/user_manager.dart';

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
    // Load user data if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.currentUser == null && !userProvider.isLoading) {
        userProvider.loadCurrentUser();
      }
    });

    // Initialize moment if needed
    int? id = context.read<CampaignManager>().campaignId;
    if (id != null) {
      print('🔍 DEBUG - Campaign ID: $id');
      momentService.getMomentById(id).then((value) {
        setState(() {
          moment = value;
          contentController.text = moment?.content ?? '';
          selectedImage = (moment?.media != null && moment!.media.isNotEmpty)
              ? File(moment!.media.first.media_url)
              : null;
        });
      });
    }
    // Fetch categories
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
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return const Scaffold(
            backgroundColor: background,
            body: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (userProvider.error != null) {
          return Scaffold(
            backgroundColor: background,
            body: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    userProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        }

        final currentUser = userProvider.currentUser;
        final username = currentUser?.u_name ?? 'User${currentUser?.u_id ?? 0}';
        final avatarUrl = currentUser?.u_avt != null
            ? MomentService.fullImageUrl(currentUser!.u_avt)
            : null;

        return Scaffold(
          backgroundColor: background,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: button,
            elevation: 0,
            title: const Text(
              'Tạo bài thông báo',
              style: TextStyle(
                fontFamily: 'montserrat',
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => widget.onBack(),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 96.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AddPostSection(
                    contentController: contentController,
                    selectedImages:
                        selectedImage != null ? [selectedImage!] : [],
                    onPickImages: pickImage,
                    avatarPath: avatarUrl ?? '',
                    username: username,
                    categories: categories,
                    selectedCategory: moment?.category,
                    onCategoryChanged: (value) {},
                    selectedMomentType: moment?.type,
                    onMomentTypeChanged: (value) {},
                    isPublic: true,
                    onPublicChanged: (value) {},
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              if (widget.isLast) {
                showSuccessDialog();
                return;
              }
              widget.onNext();
            },
            backgroundColor: button,
            label: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 13.0, vertical: 8.0),
              child: Text(
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
      },
    );
  }
}
