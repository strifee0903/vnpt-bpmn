import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../components/colors.dart';

class AddPostSection extends StatefulWidget {
  final TextEditingController contentController;
  final File? selectedImage;
  final VoidCallback onPickImage;
  final String avatarPath;
  final String username;

  const AddPostSection({
    super.key,
    required this.contentController,
    required this.selectedImage,
    required this.onPickImage,
    required this.avatarPath,
    required this.username,
  });

  @override
  _AddPostSectionState createState() => _AddPostSectionState();
}

class _AddPostSectionState extends State<AddPostSection> {
  String? selectedMomentType; // Biến lưu loại moment
  String? selectedCategory; // Biến lưu category

  // Danh sách Moment Type
  final List<String> momentTypes = ['Diary', 'Event', 'Report'];

  // Danh sách Category
  final List<String> categories = [
    'Waste Collection',
    'Tree Planting',
    'Recycling',
    'Water Conservation',
    'Renewable Energy',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(widget.avatarPath),
              radius: 20,
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Row(
                children: [
                  Text(
                    widget.username,
                    style: const TextStyle(
                      fontFamily: 'Oktah',
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  const Icon(
                    Icons.location_pin,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 5.0),
                  const Text(
                    'Location: TBD',
                    style: TextStyle(
                      fontFamily: 'Oktah',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedMomentType,
                isExpanded: true,
                hint: const Text(
                  'Moment Type',
                  style: TextStyle(
                    fontFamily: 'Oktah',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                items: momentTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type,
                      style: const TextStyle(
                        fontFamily: 'Oktah',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                selectedItemBuilder: (BuildContext context) {
                  return momentTypes.map<Widget>((String type) {
                    return Text(
                      type,
                      style: const TextStyle(
                        fontFamily: 'Oktah',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis, // Cắt ngắn khi chọn
                    );
                  }).toList();
                },
                onChanged: (String? newValue) {
                  setState(() {
                    selectedMomentType = newValue;
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
            ),
            const SizedBox(width: 5.0),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedCategory,
                isExpanded: true,
                hint: const Text(
                  'Category',
                  style: TextStyle(
                    fontFamily: 'Oktah',
                    fontSize: 14,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                selectedItemBuilder: (BuildContext context) {
                  return categories.map<Widget>((String category) {
                    return Text(
                      category,
                      style: const TextStyle(
                        fontFamily: 'Oktah',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis, // Cắt ngắn khi chọn
                    );
                  }).toList();
                },
                onChanged: (String? newValue) {
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
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        TextField(
          controller: widget.contentController,
          maxLines: null,
          cursorColor: button,
          decoration: const InputDecoration(
            hintText: 'Write your moment...',
            border: InputBorder.none,
          ),
          style: const TextStyle(
            fontFamily: 'Oktah',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16.0),
        GestureDetector(
          onTap: widget.onPickImage,
          child: Container(
            height: 190,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: fieldborder),
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: widget.selectedImage == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 50,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Tap to add a photo',
                          style: TextStyle(
                            fontFamily: 'Oktah',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(18.0),
                    child: Image.file(
                      widget.selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
