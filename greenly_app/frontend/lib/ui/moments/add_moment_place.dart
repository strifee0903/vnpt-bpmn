// import 'package:flutter/material.dart';
// import 'package:greenly_app/services/moment_service.dart';
// import '../../../services/user_service.dart';
// import '../../../models/user.dart';
// import 'add_moment.dart';

// class AddMomentPlace extends StatefulWidget {
//   const AddMomentPlace({super.key});

//   @override
//   State<AddMomentPlace> createState() => _AddMomentPlaceState();
// }

// class _AddMomentPlaceState extends State<AddMomentPlace> {
//   final UserService _userService = UserService();
//   User? _currentUser;
//   String? _error;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchCurrentUser();
//   }

//   Future<void> _fetchCurrentUser() async {
//     try {
//       final user = await _userService.getCurrentUser();
//       if (mounted) {
//         setState(() {
//           _currentUser = user;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _error = 'Failed to load user data';
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Padding(
//         padding: EdgeInsets.symmetric(vertical: 16.0),
//         child: Center(
//           child: SizedBox(
//             width: 24,
//             height: 24,
//             child: CircularProgressIndicator(strokeWidth: 2),
//           ),
//         ),
//       );
//     }

//     if (_error != null) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 16.0),
//         child: Center(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline, color: Colors.red, size: 20),
//               const SizedBox(width: 8),
//               Text(
//                 _error!,
//                 style: const TextStyle(color: Colors.red),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const AddMomentPage()),
//           );
//         },
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: const Color(0xFF708C5B).withOpacity(0.2),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Avatar + username
//               Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 20,
//                     backgroundColor: Colors.grey.shade100,
//                     backgroundImage: NetworkImage(
//                       MomentService.fullImageUrl(_currentUser?.u_avt),
//                     ),
//                   ),
//                   const SizedBox(width: 15),
//                   Expanded(
//                     child: Text(
//                       _currentUser?.u_name ?? 'Unknown User',
//                       style: const TextStyle(
//                         fontFamily: 'Oktah',
//                         fontWeight: FontWeight.w700,
//                         fontSize: 18,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12.0),

//               // Share your moment
//               Container(
//                 width: double.infinity,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.7),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.edit_outlined,
//                         color: Colors.grey.shade500, size: 20),
//                     const SizedBox(width: 12),
//                     const Text(
//                       'Share your moment...',
//                       style: TextStyle(
//                         fontFamily: 'Oktah',
//                         fontSize: 15,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.black54,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );

//   }
// }

import 'package:flutter/material.dart';
import 'package:greenly_app/services/moment_service.dart';
import '../../../services/user_service.dart';
import '../../../models/user.dart';
import 'add_moment.dart';

class AddMomentPlace extends StatefulWidget {
  final VoidCallback? onPostCreated; // Add callback for when post is created

  const AddMomentPlace({super.key, this.onPostCreated});

  @override
  State<AddMomentPlace> createState() => _AddMomentPlaceState();
}

class _AddMomentPlaceState extends State<AddMomentPlace> {
  final UserService _userService = UserService();
  User? _currentUser;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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
          _error = 'Failed to load user data';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToAddMoment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMomentPage()),
    );

    // If the result is 'refresh', call the callback to refresh the moments
    if (result == 'refresh' && widget.onPostCreated != null) {
      widget.onPostCreated!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _navigateToAddMoment,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF708C5B).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar + username
              Row(
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
                    child: Text(
                      _currentUser?.u_name ?? 'Unknown User',
                      style: const TextStyle(
                        fontFamily: 'Oktah',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),

              // Share your moment
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined,
                        color: Colors.grey.shade500, size: 20),
                    const SizedBox(width: 12),
                    const Text(
                      'Share your moment...',
                      style: TextStyle(
                        fontFamily: 'Oktah',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
