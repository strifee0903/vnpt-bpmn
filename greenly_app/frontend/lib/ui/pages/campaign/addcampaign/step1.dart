import 'package:flutter/material.dart';
import 'package:greenly_app/ui/pages/campaign/addcampaign/success_dialog.dart';
import 'package:greenly_app/ui/pages/campaign/campaign_manager.dart';
import 'package:provider/provider.dart';
import '../../../../components/colors.dart';
import 'package:greenly_app/services/campaign_service.dart';
import 'package:greenly_app/services/category_service.dart';
import 'package:greenly_app/models/campaign.dart';
import 'package:greenly_app/models/category.dart';

class Step1 extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool isLast; // Biến để xác định bước cuối cùng
  final void Function(String message) onComplete;

  const Step1({
    super.key,
    required this.onNext,
    required this.onBack,
    this.isLast = false,
    required this.onComplete,
  }); // Thêm tham số isLast với giá trị mặc định là false

  @override
  State<Step1> createState() => _Step1State();
}

class _Step1State extends State<Step1> {
  final CampaignService campaignService = CampaignService();
  final CategoryService categoryService = CategoryService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  Category? selectedCategory; // Biến để lưu category được chọn

  // Danh sách category
  final List<Category> categories = [
    // 'Waste Sorting',
    // 'Tree Planting',
    // 'Recycling',
    // 'Water Conservation',
    // 'Renewable Energy',
  ];

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => const SuccessDialog(),
    );
  }

  Future<int> createCampaign() async {
    if (selectedStartDate == null || selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn ngày bắt đầu và kết thúc')),
      );
      return 0;
    }

    final campaign = Campaign(
      id: 0, // server sẽ tạo
      title: nameController.text.trim(),
      description: descriptionController.text.trim(),
      location: locationController.text.trim(),
      startDate: selectedStartDate!.toIso8601String(),
      endDate: selectedEndDate!.toIso8601String(),
      categoryId: selectedCategory?.category_id ?? 49,
    );

    try {
      final created = await campaignService.createCampaign(campaign);

      if (created != null) {
        widget.onComplete('Tạo chiến dịch thành công: $created');
      } else {
        widget.onComplete('Tạo chiến dịch thất bại');
      }
      return created ?? 0; // Trả về ID của chiến dịch đã tạo
    } catch (e) {
      print('⚠️ Exception: $e');
      widget.onComplete('Có lỗi xảy ra khi tạo chiến dịch: $e');
      return 0; // Trả về 0 nếu có lỗi
    }
  }

  @override
  void initState() {
    super.initState();
    // Lấy danh sách category từ CampaignService
    categoryService.getAllCategories().then((value) {
      setState(() {
        categories.addAll(value);
      });
    }).catchError((error) {
      print('⚠️ Lỗi lấy danh sách category: $error');
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    locationController.dispose();
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
          'Campaign Details',
          style: TextStyle(
            fontFamily: 'Oktah',
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                16.0, 16.0, 16.0, 96.0), // Kết hợp padding all và bottom
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Campaign Name',
                  style: TextStyle(
                    fontFamily: 'Oktah',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: nameController,
                  cursorColor: button,
                  style: const TextStyle(
                    fontFamily: 'Oktah',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
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
                const Text(
                  'Category',
                  style: TextStyle(
                    fontFamily: 'Oktah',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8.0),
                DropdownButtonFormField<Category>(
                  value: selectedCategory,
                  isExpanded: true,
                  hint: const Text(
                    'Select a Category',
                    style: TextStyle(
                      fontFamily: 'Oktah',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  items: categories.map((Category category) {
                    return DropdownMenuItem<Category>(
                      value: category,
                      child: Text(
                        category.category_name,
                        style: const TextStyle(
                          fontFamily: 'Oktah',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  selectedItemBuilder: (BuildContext context) {
                    return categories.map<Widget>((Category category) {
                      return Text(
                        category.category_name,
                        style: const TextStyle(
                          fontFamily: 'Oktah',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      );
                    }).toList();
                  },
                  onChanged: (Category? newValue) {
                    setState(() {
                      selectedCategory = newValue;
                    });
                  },
                  icon: const Icon(Icons.arrow_drop_down, size: 18),
                  iconSize: 18,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 10.0),
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
                const Text(
                  'Description',
                  style: TextStyle(
                    fontFamily: 'Oktah',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  cursorColor: button,
                  style: const TextStyle(
                    fontFamily: 'Oktah',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
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
                const Text(
                  'Execution Date',
                  style: TextStyle(
                    fontFamily: 'Oktah',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedStartDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null && picked != selectedStartDate) {
                            setState(() {
                              selectedStartDate = picked;
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            cursorColor: button,
                            style: const TextStyle(
                              fontFamily: 'Oktah',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: fieldborder),
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: fieldborder),
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: button),
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              suffixIcon: const Icon(Icons.calendar_today),
                              hintText: selectedStartDate == null
                                  ? 'Start Date'
                                  : '${selectedStartDate!.day}/${selectedStartDate!.month}/${selectedStartDate!.year}',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    const Text(
                      'to',
                      style: TextStyle(
                        fontFamily: 'Oktah',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedEndDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null && picked != selectedEndDate) {
                            setState(() {
                              selectedEndDate = picked;
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            cursorColor: button,
                            style: const TextStyle(
                              fontFamily: 'Oktah',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: fieldborder),
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: fieldborder),
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: button),
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              suffixIcon: const Icon(Icons.calendar_today),
                              hintText: selectedEndDate == null
                                  ? 'End Date'
                                  : '${selectedEndDate!.day}/${selectedEndDate!.month}/${selectedEndDate!.year}',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Location',
                  style: TextStyle(
                    fontFamily: 'Oktah',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: locationController,
                  cursorColor: button,
                  style: const TextStyle(
                    fontFamily: 'Oktah',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
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
                    errorText: locationController.text.isNotEmpty &&
                            !RegExp(r'^[^,]+,[^,]+,[^,]+$')
                                .hasMatch(locationController.text)
                        ? 'Please use format: street, district, city'
                        : null,
                  ),
                  autovalidateMode: AutovalidateMode
                      .onUserInteraction, // Kiểm tra khi người dùng nhập
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return null; // Cho phép rỗng nếu không bắt buộc
                    if (!RegExp(r'^[^,]+,[^,]+,[^,]+$').hasMatch(value)) {
                      return 'Please use format: street, district, city';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          context.read<CampaignManager>().setCampaignId(await createCampaign());

          if (widget.isLast) {
            // Nếu là bước cuối cùng, hiển thị dialog thành công
            showSuccessDialog();
            return;
          }
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const Step2()),
          // );
          widget.onNext(); // Gọi hàm onNext từ widget
        },
        backgroundColor: button,
        label: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 13.0, vertical: 8.0), // Tăng vertical lên 12.0
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
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Đặt ở góc dưới bên phải
    );
  }
}
