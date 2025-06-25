import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import '../../components/colors.dart';
import '../../models/category.dart';
import '../../models/moment.dart';
import '../../models/user.dart';
import '../../services/category_service.dart';
import '../../services/moment_service.dart';
import '../../services/user_service.dart';
import '../auth/auth_manager.dart';
import 'moment_manager.dart';

class EditMomentScreen extends StatefulWidget {
  final Moment moment;

  const EditMomentScreen({super.key, required this.moment});

  @override
  _EditMomentScreenState createState() => _EditMomentScreenState();
}

class _EditMomentScreenState extends State<EditMomentScreen> {
  final _formKey = GlobalKey<FormState>();
  final MomentService _momentService = MomentService();
  final CategoryService _categoryService = CategoryService();
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _contentController;
  late TextEditingController _addressController;
  String? _selectedType;
  late Category? _selectedCategory;
  bool _isPublic = true;
  List<File> _newImages = [];
  List<int> _mediaIdsToDelete = [];
  bool _isLoading = false;
  List<Category> _categories = [];
  Position? _currentPosition;
  String? _currentAddress;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.moment.content);
    _addressController = TextEditingController(text: widget.moment.address);
    _selectedType = widget.moment.type;
    _selectedCategory = widget.moment.category;
    _isPublic = widget.moment.isPublic ?? true;
    _fetchCategories();
    _getCurrentLocation();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final user = await _userService.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _categoryService.getAllCategories();
      setState(() {
        _categories = categories;
        _selectedCategory = _categories.firstWhere(
          (c) => c.category_id == _selectedCategory?.category_id,
          orElse: () => _selectedCategory!,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Location permissions are permanently denied')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _currentPosition = position;
        _currentAddress = placemarks.isNotEmpty
            ? '${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].country}'
            : 'Unknown location';
        _addressController.text = _currentAddress!;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    } finally {}
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null) {
        setState(() {
          _newImages.addAll(pickedFiles.map((file) => File(file.path)));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick images: $e')),
      );
    }
  }

  Future<void> _updateMoment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final updatedMoment = await _momentService.updateMoment(
        momentId: widget.moment.id,
        content: _contentController.text,
        address: _addressController.text,
        latitude: _currentPosition?.latitude,
        longitude: _currentPosition?.longitude,
        type: _selectedType!,
        categoryId: _selectedCategory?.category_id ?? 1,
        isPublic: _isPublic,
        images: _newImages,
        mediaIdsToDelete:
        _mediaIdsToDelete.isNotEmpty ? _mediaIdsToDelete : null,
      );

      if (mounted) {
        // Cập nhật dữ liệu trong MomentProvider
        Provider.of<MomentProvider>(context, listen: false)
            .updateMomentLocally(updatedMoment);

        // Làm mới các feed
        await Provider.of<MomentProvider>(context, listen: false)
            .refreshAllFeeds();

        // Thoát màn hình và truyền dữ liệu cập nhật
        print(
            '‼️‼️‼️‼️Popping EditMomentScreen with updated moment: ${updatedMoment.id}');
        Navigator.pop(context, updatedMoment);
      } else {
        print('‼️‼️‼️‼️Widget is not mounted, cannot pop');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update moment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Post',
          style: TextStyle(
            fontFamily: 'Oktah',
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        backgroundColor: button,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _isLoading ? null : _showDeleteDialog,
          ),
        ],
      ),
      backgroundColor: background,
      body: _isLoading && _categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Info Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey.shade100,
                          backgroundImage: NetworkImage(
                            MomentService.fullImageUrl(_currentUser?.u_avt),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Provider.of<AuthManager>(context)
                                        .loggedInUser
                                        ?.u_name ??
                                    'User',
                                style: const TextStyle(
                                  fontFamily: 'Oktah',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
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
                                      _addressController.text,
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
                    const SizedBox(height: 16),

                    // Moment Type + Category Dropdowns
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedType,
                            isExpanded: true,
                            hint: const Text(
                              'Moment Type',
                              style: TextStyle(
                                fontFamily: 'Oktah',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            items: ['diary', 'event', 'report']
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(
                                        type.capitalize(),
                                        style: const TextStyle(
                                          fontFamily: 'Oktah',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedType = value!);
                            },
                            decoration: _dropdownDecoration,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: DropdownButtonFormField<Category>(
                            value: _selectedCategory,
                            isExpanded: true,
                            hint: const Text(
                              'Category',
                              style: TextStyle(
                                fontFamily: 'Oktah',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            items: _categories.map((category) {
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
                            onChanged: (category) {
                              setState(() => _selectedCategory = category);
                            },
                            decoration: _dropdownDecoration,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Public/Private Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isPublic ? 'Public' : 'Private',
                          style: const TextStyle(
                            fontFamily: 'Oktah',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Switch(
                          value: _isPublic,
                          onChanged: (value) {
                            setState(() => _isPublic = value);
                          },
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Content Input
                    TextField(
                      controller: _contentController,
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
                    const SizedBox(height: 16),

                    // Current Images - Giữ nguyên cách hiển thị ảnh cũ
                    if (widget.moment.media.isNotEmpty) ...[
                      const Text(
                        'Current Images',
                        style: TextStyle(
                          fontFamily: 'Oktah',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: widget.moment.media.map((media) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(18.0),
                                    child: Image.network(
                                      MomentService.fullImageUrl(
                                          media.media_url),
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () =>
                                          _toggleMediaDeletion(media.media_id),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _mediaIdsToDelete
                                                  .contains(media.media_id)
                                              ? Icons.check_circle
                                              : Icons.remove_circle,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // New Images - Giữ nguyên cách hiển thị ảnh mới
                    if (_newImages.isNotEmpty) ...[
                      const Text(
                        'New Images',
                        style: TextStyle(
                          fontFamily: 'Oktah',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _newImages.map((image) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
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
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _newImages.remove(image);
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.remove_circle,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Image Picker Button
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        height: 190,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: fieldborder),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 50,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
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
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Save Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateMoment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: button,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontFamily: 'Oktah',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Moment'),
        content: const Text('Are you sure you want to delete this moment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteMoment();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMoment() async {
    setState(() => _isLoading = true);
    try {
      await _momentService.deleteMoment(widget.moment.id);
      if (mounted) {
        await Provider.of<MomentProvider>(context, listen: false)
            .refreshAllFeeds();
        Navigator.pop(context, 'deleted');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete moment: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleMediaDeletion(int? mediaId) {
    if (mediaId == null) return;

    setState(() {
      if (_mediaIdsToDelete.contains(mediaId)) {
        _mediaIdsToDelete.remove(mediaId);
      } else {
        _mediaIdsToDelete.add(mediaId);
      }
    });
  }
}

InputDecoration get _dropdownDecoration => InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: fieldborder),
        borderRadius: BorderRadius.circular(18),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: fieldborder),
        borderRadius: BorderRadius.circular(18),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: button),
        borderRadius: BorderRadius.circular(18),
      ),
    );

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
