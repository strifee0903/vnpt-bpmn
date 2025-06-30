import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:greenly_app/ui/moments/moment_manager.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../components/colors.dart';
import '../../models/category.dart';

class AddPostSection extends StatefulWidget {
  final TextEditingController contentController;
  final List<File> selectedImages;
  final VoidCallback onPickImages;
  final Function(int)? onRemoveImage; // Add callback for removing images
  final String avatarPath;
  final File? avatarFile;
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
    this.avatarFile,
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
  State<AddPostSection> createState() => _AddPostSectionState();
}

class _AddPostSectionState extends State<AddPostSection> {
  LatLng? currentLocation;
  String? nameOfLocation;
  Future<void> _getLocation() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('📍📍📍 Service enabled: $serviceEnabled');

    if (permission == LocationPermission.deniedForever) return;

    try {
      final pos = await Geolocator.getCurrentPosition();
      final newLocation = LatLng(pos.latitude, pos.longitude);
      nameOfLocation = await getAddressFromLatLng(
          newLocation.latitude, newLocation.longitude);

      setState(() {
        currentLocation = newLocation;
      });
      Provider.of<MomentProvider>(this.context, listen: false)
          .updateCurrentLocation(newLocation);
      print(
          '📍📍📍 Current location: ${currentLocation!.latitude}, ${currentLocation!.longitude}');
      print('📍📍📍 Address: $nameOfLocation');
    } catch (e) {
      print('❌ Error getting location: $e');
    }
  }

// String formatPlacemark(Placemark place) {
//   final parts = [
//     place.name,
//     place.street,
//     place.subLocality,
//     place.locality,
//     place.administrativeArea,
//     place.country,
//   ];

//   // Loại bỏ các phần tử null hoặc rỗng
//   final nonEmpty =
//       parts.where((part) => part != null && part.trim().isNotEmpty).toList();

//   return nonEmpty.join(', ');
// }

  Future<String?> getAddressFromLatLng(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        final parts = [
          place.name,
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ];

        // Loại bỏ các phần tử null hoặc rỗng
        final nonEmpty = parts
            .where((part) => part != null && part.trim().isNotEmpty)
            .toList();
        return nonEmpty.join(', ');
      }
    } catch (e) {
      print('❌ Lỗi khi reverse geocoding: $e');
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    // Lấy vị trí hiện tại khi khởi tạo
    _getLocation();
  }

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
              radius: 30,
              backgroundImage: widget.avatarFile != null
                  ? FileImage(widget.avatarFile!)
                  : AssetImage('public/images/blank_avt.jpg') as ImageProvider,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.username.isNotEmpty ? widget.username : 'Anonymous',
                    style: const TextStyle(
                      fontFamily: 'montserrat',
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
                          nameOfLocation ??
                              widget.address ??
                              'Không rõ địa điểm',
                          style: const TextStyle(
                            fontFamily: 'montserrat',
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
                value: widget.selectedMomentType,
                isExpanded: true,
                hint: const Text(
                  'Loại khoảnh khắc',
                  style: TextStyle(
                      fontFamily: 'montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                items: momentTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type,
                      style: const TextStyle(
                          fontFamily: 'montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
                onChanged: widget.onMomentTypeChanged,
                decoration: _dropdownDecoration,
              ),
            ),
            const SizedBox(width: 5.0),
            Expanded(
              child: DropdownButtonFormField<Category>(
                value: widget.selectedCategory,
                isExpanded: true,
                hint: const Text(
                  'Chọn danh mục',
                  style: TextStyle(
                      fontFamily: 'montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                items: widget.categories.map((category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Text(
                      category.category_name,
                      style: const TextStyle(
                          fontFamily: 'montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
                onChanged: widget.onCategoryChanged,
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
              widget.isPublic ? 'Công khai' : 'Riêng tư',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'montserrat',
              ),
            ),
            Switch(
              value: widget.isPublic,
              onChanged: widget.onPublicChanged,
              activeColor: Colors.green,
            ),
          ],
        ),

        const SizedBox(height: 16.0),

        // Content Input
        TextField(
          controller: widget.contentController,
          maxLines: null,
          cursorColor: button,
          decoration: const InputDecoration(
            hintText: 'Chia sẻ khoảnh khắc...',
            border: InputBorder.none,
          ),
          style: const TextStyle(
            fontFamily: 'montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 16.0),

        // Image Picker with Delete functionality
        GestureDetector(
          onTap: widget.onPickImages,
          child: Container(
            height: 190,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: fieldborder),
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: widget.selectedImages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate,
                            size: 50, color: Colors.grey),
                        SizedBox(height: 8.0),
                        Text(
                          'Ấn để chọn ảnh',
                          style: TextStyle(
                            fontFamily: 'montserrat',
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
                        ...widget.selectedImages.asMap().entries.map((entry) {
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
                                    onTap: () =>
                                        widget.onRemoveImage?.call(index),
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
                        if (widget.selectedImages.isNotEmpty)
                          GestureDetector(
                            onTap: widget.onPickImages,
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
                                    'Thêm',
                                    style: TextStyle(
                                      fontFamily: 'montserrat',
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
