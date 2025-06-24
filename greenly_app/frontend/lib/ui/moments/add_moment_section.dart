import 'package:flutter/material.dart';
import 'dart:io';
import '../../components/colors.dart';
import '../../models/category.dart';

class AddPostSection extends StatelessWidget {
  final TextEditingController contentController;
  final List<File> selectedImages;
  final VoidCallback onPickImages;
  final Function(int)? onRemoveImage; // Add callback for removing images
  final String avatarPath;
  final String username;
  final List<Category> categories;
  final Category? selectedCategory;
  final ValueChanged<Category?> onCategoryChanged;
  final String? selectedMomentType;
  final ValueChanged<String?> onMomentTypeChanged;
  final bool isPublic;
  final ValueChanged<bool> onPublicChanged;
  final String? address;

  const AddPostSection({
    super.key,
    required this.contentController,
    required this.selectedImages,
    required this.onPickImages,
    this.onRemoveImage, 
    required this.avatarPath,
    required this.username,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.selectedMomentType,
    required this.onMomentTypeChanged,
    required this.isPublic,
    required this.onPublicChanged,
    this.address,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> momentTypes = ['diary', 'event', 'report'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              child: ClipOval(
                child: Image.network(
                  avatarPath,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.person,
                        color: Colors.white, size: 20);
                  },
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username.isNotEmpty ? username : 'Anonymous',
                    style: const TextStyle(
                      fontFamily: 'Oktah',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_pin,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address ?? 'Fetching location...',
                          style: const TextStyle(
                            fontFamily: 'Oktah',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),

        // Moment Type + Category Dropdowns
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
                      fontWeight: FontWeight.w500),
                ),
                items: momentTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type,
                      style: const TextStyle(
                          fontFamily: 'Oktah',
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
                onChanged: onMomentTypeChanged,
                decoration: _dropdownDecoration,
              ),
            ),
            const SizedBox(width: 5.0),
            Expanded(
              child: DropdownButtonFormField<Category>(
                value: selectedCategory,
                isExpanded: true,
                hint: const Text(
                  'Category',
                  style: TextStyle(
                      fontFamily: 'Oktah',
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Text(
                      category.category_name,
                      style: const TextStyle(
                          fontFamily: 'Oktah',
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
                onChanged: onCategoryChanged,
                decoration: _dropdownDecoration,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16.0),

        // Public/Private Switch
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isPublic ? 'Public' : 'Private',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Oktah',
              ),
            ),
            Switch(
              value: isPublic,
              onChanged: onPublicChanged,
              activeColor: Colors.green,
            ),
          ],
        ),

        const SizedBox(height: 16.0),

        // Content Input
        TextField(
          controller: contentController,
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

        // Image Picker with Delete functionality
        GestureDetector(
          onTap: onPickImages,
          child: Container(
            height: 190,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: fieldborder),
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: selectedImages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate,
                            size: 50, color: Colors.grey),
                        SizedBox(height: 8.0),
                        Text(
                          'Tap to add photos',
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
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Display selected images with delete buttons
                        ...selectedImages.asMap().entries.map((entry) {
                          int index = entry.key;
                          File image = entry.value;

                          return Container(
                            margin: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(18.0),
                                  child: Image.file(
                                    image,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                // Delete button positioned at top-right corner
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: GestureDetector(
                                    onTap: () => onRemoveImage?.call(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.8),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        // Add more photos button
                        if (selectedImages.isNotEmpty)
                          GestureDetector(
                            onTap: onPickImages,
                            child: Container(
                              width: 150,
                              height: 150,
                              margin: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(18.0),
                                border: Border.all(
                                  color: Colors.grey.shade400,
                                  style: BorderStyle.solid,
                                  width: 2,
                                ),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Add more',
                                    style: TextStyle(
                                      fontFamily: 'Oktah',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  InputDecoration get _dropdownDecoration => InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
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
      );
}