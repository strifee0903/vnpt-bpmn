// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // Add this import
// import 'package:greenly_app/services/moment_service.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// import '../../../components/colors.dart';
// import '../../../models/user.dart';
// import '../../../services/user_service.dart';
// import 'user_manager.dart'; // Add this import

// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});

//   @override
//   _EditProfileScreenState createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final UserService _userService = UserService();
//   final _formKey = GlobalKey<FormState>();
//   User? _user;
//   bool _isLoading = true;
//   String? _error;
//   File? _avatarFile;
//   final ImagePicker _picker = ImagePicker();

//   // Controllers and date
//   late TextEditingController _nameController;
//   late TextEditingController _emailController;
//   late TextEditingController _addressController;
//   DateTime? _selectedDate;

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController();
//     _emailController = TextEditingController();
//     _addressController = TextEditingController();
//     _fetchUserProfile();
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchUserProfile() async {
//     try {
//       final user = await _userService.getMyProfile();
//       setState(() {
//         _user = user;
//         _nameController.text = user.u_name;
//         _emailController.text = user.u_email;
//         if (user.u_birthday != null) {
//           _selectedDate = DateTime.parse(user.u_birthday!);
//         }
//         _addressController.text = user.u_address;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = 'Failed to load profile: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _pickAvatar() async {
//     final XFile? pickedFile = await _picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 85,
//     );

//     if (pickedFile != null) {
//       final file = File(pickedFile.path);
//       final bytes = await file.readAsBytes();

//       if (bytes.lengthInBytes > 5 * 1024 * 1024) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Image too large (max 5MB)')),
//         );
//         return;
//       }

//       setState(() {
//         _avatarFile = file;
//       });
//     }
//   }

//   Future<void> _selectDate() async {
//     final DateTime now = DateTime.now();
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? now,
//       firstDate: DateTime(1900),
//       lastDate: now,
//       builder: (context, child) {
//         return Theme(
//           data: ThemeData.light().copyWith(
//             primaryColor: button,
//             colorScheme: ColorScheme.light(primary: button),
//             buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   Future<void> _saveProfile() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     final fields = {
//       'u_name': _nameController.text,
//       'u_birthday': _selectedDate != null
//           ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
//           : '',
//       'u_address': _addressController.text,
//     };

//     http.MultipartFile? avatarMultipart;
//     if (_avatarFile != null) {
//       avatarMultipart = await http.MultipartFile.fromPath(
//         'u_avtFile',
//         _avatarFile!.path,
//         contentType: MediaType('image', 'jpeg'),
//       );
//     }

//     try {
//       final updatedUser = await _userService.updateCurrentUser(fields,
//           u_avtFile: avatarMultipart);

//       // Update the global user state using UserProvider
//       if (mounted) {
//         Provider.of<UserProvider>(context, listen: false)
//             .updateUser(updatedUser);
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Profile updated successfully'),
//           backgroundColor: Colors.green,
//         ),
//       );
//       Navigator.pop(context);
//     } catch (e) {
//       setState(() {
//         _error = 'Failed to update profile: $e';
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: background,
//       appBar: AppBar(
//         title: Text('Edit Profile', style: TextStyle(fontFamily: 'Baloo Bhaijaan 2')),
//         backgroundColor: background,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : _error != null
//               ? Center(
//                   child: Text(_error!,
//                       style: TextStyle(color: Colors.red, fontFamily: 'Baloo Bhaijaan 2')))
//               : Padding(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 16.0, vertical: 8.0),
//                   child: Form(
//                     key: _formKey,
//                     child: SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Avatar
//                           Center(
//                             child: GestureDetector(
//                               onTap: _pickAvatar,
//                               child: Stack(
//                                 children: [
//                                   CircleAvatar(
//                                     radius: 50,
//                                     backgroundImage: _avatarFile != null
//                                         ? FileImage(_avatarFile!)
//                                         : _user?.u_avt != null
//                                             ? NetworkImage(
//                                                 MomentService.fullImageUrl(
//                                                     _user!.u_avt))
//                                             : AssetImage(
//                                                     'assets/images/blankava.png')
//                                                 as ImageProvider,
//                                   ),
//                                   Positioned(
//                                     bottom: 0,
//                                     right: 0,
//                                     child: Container(
//                                       padding: EdgeInsets.all(4),
//                                       decoration: BoxDecoration(
//                                         color: button,
//                                         shape: BoxShape.circle,
//                                       ),
//                                       child: Icon(Icons.camera_alt,
//                                           size: 20, color: Colors.white),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 20),

//                           // Name field
//                           Container(
//                             margin: EdgeInsets.symmetric(vertical: 6),
//                             padding: EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF708C5B).withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: TextFormField(
//                               controller: _nameController,
//                               decoration: InputDecoration(
//                                 labelText: 'Name',
//                                 border: InputBorder.none,
//                                 filled: true,
//                                 fillColor: Colors.transparent,
//                               ),
//                               style: TextStyle(fontFamily: 'Baloo Bhaijaan 2'),
//                               validator: (value) =>
//                                   value == null || value.isEmpty
//                                       ? 'Name is required'
//                                       : null,
//                             ),
//                           ),
//                           SizedBox(height: 16),

//                           // Email field (disabled)
//                           Container(
//                             margin: EdgeInsets.symmetric(vertical: 6),
//                             padding: EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF708C5B).withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: TextFormField(
//                               controller: _emailController,
//                               decoration: InputDecoration(
//                                 labelText: 'Email',
//                                 border: InputBorder.none,
//                                 filled: true,
//                                 fillColor: Colors.transparent,
//                               ),
//                               style: TextStyle(fontFamily: 'Baloo Bhaijaan 2'),
//                               enabled: false,
//                             ),
//                           ),
//                           SizedBox(height: 16),

//                           // Birthday field
//                           Container(
//                             margin: EdgeInsets.symmetric(vertical: 6),
//                             padding: EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF708C5B).withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: GestureDetector(
//                               onTap: _selectDate,
//                               child: AbsorbPointer(
//                                 child: TextFormField(
//                                   decoration: InputDecoration(
//                                     labelText: 'Birthday (MM/DD/YYYY)',
//                                     border: InputBorder.none,
//                                     filled: true,
//                                     fillColor: Colors.transparent,
//                                     suffixIcon: Icon(Icons.calendar_today,
//                                         color: Colors.black87),
//                                   ),
//                                   style: TextStyle(fontFamily: 'Baloo Bhaijaan 2'),
//                                   controller: TextEditingController(
//                                     text: _selectedDate != null
//                                         ? DateFormat('MM/dd/yyyy')
//                                             .format(_selectedDate!)
//                                         : '',
//                                   ),
//                                   validator: (value) {
//                                     if (_selectedDate == null)
//                                       return 'Birthday is required';
//                                     final now = DateTime.now();
//                                     if (_selectedDate!.isAfter(now) ||
//                                         _selectedDate!.isAtSameMomentAs(now)) {
//                                       return 'Birthday cannot be today or in the future';
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 16),

//                           // Address field
//                           Container(
//                             margin: EdgeInsets.symmetric(vertical: 6),
//                             padding: EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF708C5B).withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: TextFormField(
//                               controller: _addressController,
//                               decoration: InputDecoration(
//                                 labelText: 'Address',
//                                 border: InputBorder.none,
//                                 filled: true,
//                                 fillColor: Colors.transparent,
//                               ),
//                               style: TextStyle(fontFamily: 'Baloo Bhaijaan 2'),
//                               maxLength: 100,
//                             ),
//                           ),
//                           SizedBox(height: 20),

//                           // Save button
//                           Center(
//                             child: ElevatedButton(
//                               onPressed: _isLoading ? null : _saveProfile,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: button,
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal: 40, vertical: 12),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                               child: _isLoading
//                                   ? CircularProgressIndicator(
//                                       color: Colors.white)
//                                   : Text(
//                                       'Save',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontFamily: 'Baloo Bhaijaan 2',
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                             ),
//                           ),
//                           if (_error != null) ...[
//                             SizedBox(height: 10),
//                             Center(
//                               child: Text(
//                                 _error!,
//                                 style: TextStyle(
//                                     color: Colors.red, fontFamily: 'Baloo Bhaijaan 2'),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//     );
//   }
// }