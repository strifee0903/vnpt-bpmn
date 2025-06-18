import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../components/colors.dart';
import 'step2.dart';

class Step1 extends StatefulWidget {
  const Step1({super.key});

  @override
  State<Step1> createState() => _Step1State();
}

class _Step1State extends State<Step1> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  File? _selectedImage;
  String? selectedCategory; // Biến để lưu category được chọn

  final ImagePicker _picker = ImagePicker();

  // Danh sách category
  final List<String> categories = [
    'Waste Sorting',
    'Tree Planting',
    'Recycling',
    'Water Conservation',
    'Renewable Energy',
  ];

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
            Navigator.pop(context);
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
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  hint: const Text(
                    'Select a category',
                    style: TextStyle(
                      fontFamily: 'Oktah',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  items: categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontFamily: 'Oktah',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue;
                    });
                  },
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Step2()),
          );
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
