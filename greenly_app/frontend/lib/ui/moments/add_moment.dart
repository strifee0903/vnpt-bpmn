import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
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
import 'package:heic_to_jpg/heic_to_jpg.dart';

import 'moment_manager.dart';

class AddMomentPage extends StatefulWidget {
  const AddMomentPage({super.key});
  static const routeName = '/add-moment';

  @override
  _AddMomentPageState createState() => _AddMomentPageState();
}

class _AddMomentPageState extends State<AddMomentPage> {
  final TextEditingController _contentController = TextEditingController();
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  final CategoryService _categoryService = CategoryService();
  final UserService _userService = UserService();
  final MomentService _momentService =
      MomentService(); // Add MomentService instance
  List<Category> _categories = [];
  Category? _selectedCategory;
  String? _selectedMomentType;
  bool _isPublic = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _address;
  User? _currentUser;
  Position? _currentPosition; // Store current position

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
        _currentPosition = position; // Store the position
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
    if (images != null && images.isNotEmpty) {
      final List<File> newImages = [];
      for (var image in images) {
        String path = image.path;
        if (image.path.toLowerCase().endsWith('.heic')) {
          final jpgPath = await HeicToJpg.convert(image.path);
          if (jpgPath != null) {
            path = jpgPath;
          } else {
            // Skip if conversion fails
            continue;
          }
        }
        newImages.add(File(path));
      }
      setState(() {
        _selectedImages.addAll(newImages);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
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
      // Create the moment using MomentService
      await _momentService.createMoment(
        content: _contentController.text,
        address: _address ?? 'Unknown location',
        latitude: _currentPosition?.latitude,
        longitude: _currentPosition?.longitude,
        type: _selectedMomentType!,
        categoryId: _selectedCategory!.category_id,
        isPublic: _isPublic,
        images: _selectedImages,
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Moment created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        await Provider.of<MomentProvider>(context, listen: false).refreshAllFeeds();
        Navigator.pop(context, 'refresh');
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
          'Create a new post',
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
                      onRemoveImage: _removeImage, // Add this callback
                      avatarPath:
                          MomentService.fullImageUrl(_currentUser!.u_avt),
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
                        onPressed: _isLoading
                            ? null
                            : _postMoment, // Disable button when loading
                        style: ElevatedButton.styleFrom(
                          backgroundColor: button,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
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
