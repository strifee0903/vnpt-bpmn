// import 'package:flutter/material.dart';
// import 'package:greenly_app/shared/main_layout.dart';
// import 'package:provider/provider.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:intl/intl.dart';
// import '../../components/colors.dart';
// import '../../models/moment.dart';
// import '../../services/moment_service.dart';
// import 'moment_manager.dart';
// import '../auth/auth_manager.dart';
// import '../pages/profile/otherUserProfile.dart';
// import '../pages/profile/user_manager.dart';
// import 'moments.dart';

// class MomentDetailScreen extends StatefulWidget {
//   final int momentId;

//   const MomentDetailScreen({super.key, required this.momentId});

//   @override
//   State<MomentDetailScreen> createState() => _MomentDetailScreenState();
// }

// class _MomentDetailScreenState extends State<MomentDetailScreen> {
//   Moment? _moment;
//   bool _isLoading = true;
//   bool _isLikeLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadMoment();
//   }

//   Future<void> _loadMoment() async {
//     final momentProvider = Provider.of<MomentProvider>(context, listen: false);

//     // First try to find in existing moments
//     Moment? existingMoment;
//     for (var m in momentProvider.moments) {
//       if (m.id == widget.momentId) {
//         existingMoment = m;
//         break;
//       }
//     }

//     if (existingMoment != null) {
//       setState(() {
//         _moment = existingMoment;
//         _isLoading = false;
//       });
//     } else {
//       // If not found, fetch from API
//       try {
//         final momentService =
//             Provider.of<MomentService>(context, listen: false);
//         final moment = await momentService.getMomentById(widget.momentId);
//         setState(() {
//           _moment = moment;
//           _isLoading = false;
//         });
//       } catch (e) {
//         setState(() => _isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Không thể tải bài viết: $e')),
//         );
//         Navigator.pop(context);
//       }
//     }
//   }

//   Future<void> _toggleLike() async {
//     if (_moment == null || _isLikeLoading) return;

//     setState(() => _isLikeLoading = true);
//     final momentService = Provider.of<MomentService>(context, listen: false);
//     final momentProvider = Provider.of<MomentProvider>(context, listen: false);

//     try {
//       final result = _moment!.isLikedByCurrentUser
//           ? await momentService.unlikeMoment(_moment!.id)
//           : await momentService.likeMoment(_moment!.id);

//       momentProvider.updateMomentLikeStatus(
//         _moment!.id,
//         result['isLiked'],
//         result['likeCount'],
//       );

//       setState(() {
//         _moment = _moment!.copyWith(
//           isLikedByCurrentUser: result['isLiked'],
//           likeCount: result['likeCount'],
//         );
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Không thể thay đổi trạng thái like: $e')),
//       );
//     } finally {
//       setState(() => _isLikeLoading = false);
//     }
//   }

//   void _handleUserTap() {
//     final authManager = Provider.of<AuthManager>(context, listen: false);
//     final currentUser = authManager.loggedInUser;

//     if (currentUser != null && currentUser.u_id == _moment!.user.u_id) {
//       // Nếu là bài viết của chính mình thì chuyển về trang profile
//       Navigator.pop(context); // Đóng màn hình chi tiết trước
//       Navigator.pushReplacementNamed(context, '/profile');
//     } else {
//       // Nếu là bài viết của người khác thì mở trang profile của họ
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => OtherUserProfileScreen(
//             userId: _moment!.user.u_id,
//             username: _moment!.user.u_name,
//             avatarUrl: _moment!.user.u_avt ?? '',
//           ),
//         ),
//       );
//     }
//   }

//   String _getCurrentAvatarUrl() {
//     final authManager = Provider.of<AuthManager>(context, listen: false);
//     final userProvider = Provider.of<UserProvider>(context, listen: false);
//     final currentUser = authManager.loggedInUser;

//     // If this moment belongs to the current user, use the updated avatar from UserProvider
//     if (currentUser != null &&
//         currentUser.u_id == _moment!.user.u_id &&
//         userProvider.currentUser != null) {
//       return userProvider.currentUser!.u_avt ?? _moment!.user.u_avt ?? '';
//     }

//     // Otherwise, use the original moment's user avatar
//     return _moment!.user.u_avt ?? '';
//   }

//   String _getCurrentUserName() {
//     final authManager = Provider.of<AuthManager>(context, listen: false);
//     final userProvider = Provider.of<UserProvider>(context, listen: false);
//     final currentUser = authManager.loggedInUser;

//     if (currentUser != null &&
//         currentUser.u_id == _moment!.user.u_id &&
//         userProvider.currentUser != null) {
//       return userProvider.currentUser!.u_name;
//     }

//     return _moment!.user.u_name;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: optcard2, // Màu nền AppBar
//         title: const Text(
//           'Chi tiết bài viết',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.home, color: Colors.white),
//             onPressed: () {
//               Navigator.of(context).pushAndRemoveUntil(
//                 MaterialPageRoute(builder: (ctx) => const MainLayout(initialIndex: 1,)),
//                 (route) => false,
//               );
//             },
//           ),
//         ],
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _moment == null
//               ? const Center(child: Text('Không tìm thấy bài viết'))
//               : SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // 1. Avatar + Username + Thời gian
//                       Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             GestureDetector(
//                               onTap: _handleUserTap,
//                               child: CircleAvatar(
//                                 radius: 20,
//                                 backgroundColor: Colors.grey[300],
//                                 child: ClipOval(
//                                   child: Image.network(
//                                     MomentService.fullImageUrl(
//                                         _getCurrentAvatarUrl()),
//                                     width: 40,
//                                     height: 40,
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (_, __, ___) =>
//                                         const Icon(Icons.person),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: GestureDetector(
//                                 onTap: _handleUserTap,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       _getCurrentUserName(),
//                                       style: const TextStyle(
//                                         fontFamily: 'Lato',
//                                         fontWeight: FontWeight.w700,
//                                         fontSize: 18,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 2),
//                                     Text(
//                                       DateFormat('dd/MM/yyyy - HH:mm')
//                                           .format(_moment!.createdAt),
//                                       style: const TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       // 2. Nội dung
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                         child: Text(
//                           _moment!.content,
//                           style: const TextStyle(
//                             fontFamily: 'Lato',
//                             fontSize: 17,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.black87,
//                           ),
//                           softWrap: true,
//                         ),
//                       ),

//                       const SizedBox(height: 10),

//                       // 3. Media
//                       if (_moment!.media.isNotEmpty)
//                         SizedBox(
//                           height: 300,
//                           child: PageView.builder(
//                             itemCount: _moment!.media.length,
//                             itemBuilder: (context, index) {
//                               final image = MomentService.fullImageUrl(
//                                   _moment!.media[index].media_url);
//                               return Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 8.0),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: Image.network(
//                                     image,
//                                     width: double.infinity,
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (_, __, ___) =>
//                                         const Icon(Icons.broken_image),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),

//                       if (_moment!.media.length > 1)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 8.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children:
//                                 List.generate(_moment!.media.length, (index) {
//                               return Container(
//                                 width: 8,
//                                 height: 8,
//                                 margin:
//                                     const EdgeInsets.symmetric(horizontal: 4),
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Colors.grey.withOpacity(0.5),
//                                 ),
//                               );
//                             }),
//                           ),
//                         ),

//                       const SizedBox(height: 10),

//                       // 4. Info block
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Like - comment - share row
//                             Row(
//                               children: [
//                                 GestureDetector(
//                                   onTap: _toggleLike,
//                                   child: Row(
//                                     children: [
//                                       FaIcon(
//                                         _moment!.isLikedByCurrentUser
//                                             ? FontAwesomeIcons.heartCircleCheck
//                                             : FontAwesomeIcons.heartCrack,
//                                         color: _moment!.isLikedByCurrentUser
//                                             ? Colors.red
//                                             : const Color.fromARGB(
//                                                 255, 96, 96, 96),
//                                         size: 19,
//                                       ),
//                                       const SizedBox(width: 4),
//                                       Text('${_moment!.likeCount}',
//                                           style: const TextStyle(fontSize: 14)),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(width: 16),
//                                 const Row(
//                                   children: [
//                                     FaIcon(FontAwesomeIcons.solidCommentDots,
//                                         size: 19,
//                                         color: Color.fromARGB(255, 96, 96, 96)),
//                                     SizedBox(width: 4),
//                                     Text('0', style: TextStyle(fontSize: 14)),
//                                   ],
//                                 ),
//                                 const SizedBox(width: 16),
//                                 const Row(
//                                   children: [
//                                     FaIcon(FontAwesomeIcons.share,
//                                         size: 19,
//                                         color: Color.fromARGB(255, 96, 96, 96)),
//                                     SizedBox(width: 4),
//                                   ],
//                                 ),
//                               ],
//                             ),

//                             const SizedBox(height: 10),

//                             // Type + Category
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Icon(
//                                   _getMomentTypeIconData(_moment!.type),
//                                   size: 18,
//                                   color: _getMomentTypeColor(_moment!.type),
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(_moment!.type,
//                                     style: const TextStyle(fontSize: 12)),
//                                 const SizedBox(width: 16),
//                                 Icon(
//                                   _getCategoryIconData(
//                                       _moment!.category.category_name),
//                                   size: 18,
//                                   color: Colors.green,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(_moment!.category.category_name,
//                                     style: const TextStyle(fontSize: 12)),
//                               ],
//                             ),

//                             const SizedBox(height: 10),

//                             // Location
//                             if (_moment!.address.isNotEmpty)
//                               Row(
//                                 children: [
//                                   const Icon(Icons.location_on,
//                                       size: 18, color: Colors.grey),
//                                   const SizedBox(width: 4),
//                                   Expanded(
//                                     child: Text(
//                                       _moment!.address,
//                                       style: const TextStyle(
//                                           fontSize: 12, color: Colors.grey),
//                                     ),
//                                   ),
//                                 ],
//                               ),

//                             if (_moment!.latitude != null &&
//                                 _moment!.longitude != null)
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 4.0),
//                                 child: Row(
//                                   children: [
//                                     const Icon(Icons.map,
//                                         size: 18, color: Colors.grey),
//                                     const SizedBox(width: 4),
//                                     Text(
//                                       '${_moment!.latitude?.toStringAsFixed(4)}, ${_moment!.longitude?.toStringAsFixed(4)}',
//                                       style: const TextStyle(
//                                           fontSize: 12, color: Colors.grey),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//     );
//   }

//   IconData _getMomentTypeIconData(String type) {
//     switch (type.toLowerCase()) {
//       case 'event':
//         return Icons.event;
//       case 'diary':
//         return Icons.book;
//       case 'report':
//         return Icons.list_alt;
//       default:
//         return Icons.help_outline;
//     }
//   }

//   Color _getMomentTypeColor(String type) {
//     switch (type.toLowerCase()) {
//       case 'event':
//         return Colors.blue;
//       case 'diary':
//         return Colors.indigo;
//       case 'report':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   IconData _getCategoryIconData(String category) {
//     final map = {
//       'Nhặt rác': Icons.cleaning_services,
//       'Trồng cây': Icons.park,
//       'Tái chế': Icons.loop,
//       'Tiết kiệm điện': Icons.lightbulb,
//     };
//     return map[category] ?? Icons.category;
//   }
// }

import 'package:flutter/material.dart';
import 'package:greenly_app/shared/main_layout.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../components/colors.dart';
import '../../models/moment.dart';
import '../../services/moment_service.dart';
import 'moment_manager.dart';
import '../auth/auth_manager.dart';
import '../pages/profile/otherUserProfile.dart';
import '../pages/profile/user_manager.dart';
import 'moments.dart';
import 'moments_card.dart'; // Thêm import này

class MomentDetailScreen extends StatefulWidget {
  final int momentId;

  const MomentDetailScreen({super.key, required this.momentId});

  @override
  State<MomentDetailScreen> createState() => _MomentDetailScreenState();
}

class _MomentDetailScreenState extends State<MomentDetailScreen> {
  Moment? _moment;
  bool _isLoading = true;
  bool _isLikeLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMoment();
  }

  Future<void> _loadMoment() async {
    final momentProvider = Provider.of<MomentProvider>(context, listen: false);

    // First try to find in existing moments
    Moment? existingMoment;
    for (var m in momentProvider.moments) {
      if (m.id == widget.momentId) {
        existingMoment = m;
        break;
      }
    }

    if (existingMoment != null) {
      setState(() {
        _moment = existingMoment;
        _isLoading = false;
      });
    } else {
      // If not found, fetch from API
      try {
        final momentService =
            Provider.of<MomentService>(context, listen: false);
        final moment = await momentService.getMomentById(widget.momentId);
        setState(() {
          _moment = moment;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải bài viết: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _toggleLike() async {
    if (_moment == null || _isLikeLoading) return;

    setState(() => _isLikeLoading = true);
    final momentService = Provider.of<MomentService>(context, listen: false);
    final momentProvider = Provider.of<MomentProvider>(context, listen: false);

    try {
      final result = _moment!.isLikedByCurrentUser
          ? await momentService.unlikeMoment(_moment!.id)
          : await momentService.likeMoment(_moment!.id);

      momentProvider.updateMomentLikeStatus(
        _moment!.id,
        result['isLiked'],
        result['likeCount'],
      );

      setState(() {
        _moment = _moment!.copyWith(
          isLikedByCurrentUser: result['isLiked'],
          likeCount: result['likeCount'],
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể thay đổi trạng thái like: $e')),
      );
    } finally {
      setState(() => _isLikeLoading = false);
    }
  }

  void _handleUserTap() {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    final currentUser = authManager.loggedInUser;

    if (currentUser != null && currentUser.u_id == _moment!.user.u_id) {
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/profile');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtherUserProfileScreen(
            userId: _moment!.user.u_id,
            username: _moment!.user.u_name,
            avatarUrl: _moment!.user.u_avt ?? '',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: optcard2,
        title: const Text(
          'Chi tiết bài viết',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (ctx) => const MainLayout(
                          initialIndex: 1,
                        )),
                (route) => false,
              );
            },
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _moment == null
              ? const Center(child: Text('Không tìm thấy bài viết'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Sử dụng MomentCard với padding và margin phù hợp
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF708C5B).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: MomentCard(
                          key: ValueKey(_moment!.id),
                          moment: _moment!,
                          onLikeToggle: _toggleLike,
                          alwaysShowLocation: true,
                        ),
                      ),

                      // Thêm các phần khác nếu cần
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}
