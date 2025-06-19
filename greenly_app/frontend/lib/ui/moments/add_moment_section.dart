import 'package:flutter/material.dart';
import 'dart:io';
import '../../components/colors.dart';
import '../../models/category.dart';
import '../../services/moment_service.dart';
String fullImageUrl(String? relativePath) {
  final imageBaseUrl = MomentService.imageBaseUrl;

  print('🖼️ DEBUG - Image base URL: $imageBaseUrl');
  print('🖼️ DEBUG - Relative path: $relativePath');

  if (relativePath == null || relativePath.isEmpty) {
    final defaultUrl = '$imageBaseUrl/public/images/blank_avt.jpg';
    print('🖼️ DEBUG - Using default avatar: $defaultUrl');
    return defaultUrl;
  }

  if (relativePath.startsWith('http')) {
    print('🖼️ DEBUG - Path is absolute URL: $relativePath');
    return relativePath;
  }

  String fullUrl;
  if (relativePath.startsWith('/public')) {
    fullUrl = '$imageBaseUrl$relativePath';
  } else if (!relativePath.startsWith('/')) {
    fullUrl = '$imageBaseUrl/$relativePath';
  } else {
    fullUrl = '$imageBaseUrl$relativePath';
  }

  print('🖼️ DEBUG - Final image URL: $fullUrl');
  return fullUrl;
}

class AddPostSection extends StatelessWidget {
  final TextEditingController contentController;
  final List<File> selectedImages;
  final VoidCallback onPickImages;
  final String avatarPath; // Network URL
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
    final List<String> momentTypes = ['Diary', 'Event', 'Report'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => print('👤 DEBUG - Avatar tapped, URL: $avatarPath'),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: ClipOval(
                  child: Image.network(
                    avatarPath,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const CircularProgressIndicator(strokeWidth: 2);
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('❌ DEBUG - Avatar load failed: $avatarPath');
                      return const Icon(Icons.person,
                          color: Colors.white, size: 20);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Row(
                children: [
                  Text(
                    username.isNotEmpty
                        ? username
                        : 'Anonymous', // Fallback for empty u_name
                    style: const TextStyle(
                      fontFamily: 'Oktah',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  const Icon(
                    Icons.location_pin,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 5.0),
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
                onChanged: onMomentTypeChanged,
                icon: const Icon(Icons.arrow_drop_down, size: 18),
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
              child: DropdownButtonFormField<Category>(
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
                onChanged: onCategoryChanged,
                icon: const Icon(Icons.arrow_drop_down, size: 18),
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
        Row(
          children: [
            const Text(
              'Visibility:',
              style: TextStyle(
                fontFamily: 'Oktah',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8.0),
            ChoiceChip(
              label: const Text('Public'),
              selected: isPublic,
              onSelected: (selected) {
                if (selected) onPublicChanged(true);
              },
              selectedColor: button,
              labelStyle: TextStyle(
                color: isPublic ? Colors.white : Colors.black,
                fontFamily: 'Oktah',
              ),
            ),
            const SizedBox(width: 8.0),
            ChoiceChip(
              label: const Text('Private'),
              selected: !isPublic,
              onSelected: (selected) {
                if (selected) onPublicChanged(false);
              },
              selectedColor: button,
              labelStyle: TextStyle(
                color: !isPublic ? Colors.white : Colors.black,
                fontFamily: 'Oktah',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
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
                        Icon(
                          Icons.add_photo_alternate,
                          size: 50,
                          color: Colors.grey,
                        ),
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
                      children: selectedImages.map((image) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18.0),
                            child: Image.file(
                              image,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
