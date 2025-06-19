// add_moment.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../components/colors.dart';
import '../../models/category.dart';
import '../../models/user.dart';
import '../../services/category_service.dart';
import '../../services/moment_service.dart';
import '../../services/user_service.dart';
import 'add_moment_section.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';


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

class AddMomentPage extends StatefulWidget {
  const AddMomentPage({super.key});

  @override
  _AddMomentPageState createState() => _AddMomentPageState();
}

class _AddMomentPageState extends State<AddMomentPage> {
  final TextEditingController _contentController = TextEditingController();
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  final MomentService _momentService = MomentService();
  final CategoryService _categoryService = CategoryService();
  final UserService _userService = UserService();
  List<Category> _categories = [];
  Category? _selectedCategory;
  String? _selectedMomentType;
  bool _isPublic = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _address;
  double? _latitude;
  double? _longitude;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _fetchCategories();
    _getCurrentLocation();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final user = await _userService.getCurrentUser();
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user data: $e';
      });
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _categoryService.getAllCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load categories: $e';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled.';
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permissions are denied.';
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permissions are permanently denied.';
        });
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
        _latitude = position.latitude;
        _longitude = position.longitude;
        _address = placemarks.isNotEmpty
            ? '${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].country}'
            : 'Unknown location';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: $e';
      });
    }
  }

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _selectedImages.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  Future<void> _postMoment() async {
    if (_currentUser == null) {
      setState(() {
        _errorMessage = 'Please log in to post a moment.';
      });
      return;
    }
    if (_contentController.text.isEmpty ||
        _selectedMomentType == null ||
        _selectedCategory == null) {
      setState(() {
        _errorMessage = 'Please fill in all required fields.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final moment = await _momentService.createMoment(
        content: _contentController.text,
        address: _address ?? 'Unknown',
        latitude: _latitude,
        longitude: _longitude,
        type: _selectedMomentType!.toLowerCase(),
        categoryId: _selectedCategory!.category_id,
        isPublic: _isPublic,
        images: _selectedImages,
      );

      if (mounted) {
        Navigator.pop(context, moment);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create moment: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: button,
        elevation: 0,
        title: const Text(
          'Create Moment',
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
      body: _isLoading || _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    AddPostSection(
                      contentController: _contentController,
                      selectedImages: _selectedImages,
                      onPickImages: _pickImages,
                      avatarPath:
                          fullImageUrl(_currentUser!.u_avt), // Use fullImageUrl
                      username: _currentUser!.u_name,
                      categories: _categories,
                      selectedCategory: _selectedCategory,
                      onCategoryChanged: (Category? category) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      selectedMomentType: _selectedMomentType,
                      onMomentTypeChanged: (String? type) {
                        setState(() {
                          _selectedMomentType = type;
                        });
                      },
                      isPublic: _isPublic,
                      onPublicChanged: (bool value) {
                        setState(() {
                          _isPublic = value;
                        });
                      },
                      address: _address,
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 16.0),
                      child: ElevatedButton(
                        onPressed: _postMoment,
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
