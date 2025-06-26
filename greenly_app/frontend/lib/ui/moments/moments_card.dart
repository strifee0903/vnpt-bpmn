import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/moment.dart';
import '../../services/moment_service.dart';
import '../../shared/main_layout.dart';
import '../auth/auth_manager.dart';
import '../pages/profile/otherUserProfile.dart';
import '../pages/profile/user_manager.dart';
import 'edit_moment.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'moment_manager.dart';

class MomentCard extends StatefulWidget {
  final Moment moment;
  final void Function(int userId, String username, String avatarUrl)? onUserTap;
  final VoidCallback? refreshFeed;
  final VoidCallback? onLikeToggle;
  final void Function(Moment updatedMoment)? onUpdateMoment;

  const MomentCard({
    super.key,
    required this.moment,
    this.onUserTap,
    this.refreshFeed,
    this.onLikeToggle,
    this.onUpdateMoment,
  });

  @override
  State<MomentCard> createState() => _MomentCardState();
}

class _MomentCardState extends State<MomentCard> {
  late Moment moment;
  bool _isLikeLoading = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    moment = widget.moment;
  }

  // Get the current avatar URL - use updated avatar if it's the current user
  String _getCurrentAvatarUrl() {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = authManager.loggedInUser;

    // If this moment belongs to the current user, use the updated avatar from UserProvider
    if (currentUser != null &&
        currentUser.u_id == moment.user.u_id &&
        userProvider.currentUser != null) {
      return userProvider.currentUser!.u_avt ?? moment.user.u_avt ?? '';
    }

    // Otherwise, use the original moment's user avatar
    return moment.user.u_avt ?? '';
  }

  String _getCurrentUserName() {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = authManager.loggedInUser;

    // Nếu moment là của current user → ưu tiên lấy tên mới từ UserProvider
    if (currentUser != null &&
        currentUser.u_id == moment.user.u_id &&
        userProvider.currentUser != null) {
      return userProvider.currentUser!.u_name;
    }

    // Ngược lại dùng tên từ moment
    return moment.user.u_name;
  }

  void _handleUserTap(BuildContext context) {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    final currentUser = authManager.loggedInUser;

    if (currentUser != null && currentUser.u_id == moment.user.u_id) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MainLayout(initialIndex: 3),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtherUserProfileScreen(
            userId: moment.user.u_id,
            username: moment.user.u_name,
            avatarUrl: moment.user.u_avt ?? '',
          ),
        ),
      );
    }
  }

  Future<void> _toggleLike() async {
    if (_isLikeLoading) return;

    setState(() => _isLikeLoading = true);

    final momentService = Provider.of<MomentService>(context, listen: false);
    final momentProvider = Provider.of<MomentProvider>(context, listen: false);

    try {
      final result = moment.isLikedByCurrentUser
          ? await momentService.unlikeMoment(moment.id)
          : await momentService.likeMoment(moment.id);

      // Cập nhật trạng thái trong MomentProvider
      momentProvider.updateMomentLikeStatus(
        moment.id,
        result['isLiked'],
        result['likeCount'],
      );

      // Cập nhật trạng thái cục bộ
      setState(() {
        moment = moment.copyWith(
          isLikedByCurrentUser: result['isLiked'],
          likeCount: result['likeCount'],
        );
        _isLikeLoading = false;
      });

      // Gọi callback nếu có
      widget.onLikeToggle?.call();
    } catch (e) {
      setState(() => _isLikeLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle like: $e')),
      );
    }
  }

  @override
  void didUpdateWidget(MomentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.moment != oldWidget.moment) {
      setState(() {
        moment = widget.moment;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + username
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _handleUserTap(context),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[300],
                          child: ClipOval(
                            child: Image.network(
                              MomentService.fullImageUrl(
                                  _getCurrentAvatarUrl()),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.person),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _handleUserTap(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getCurrentUserName(),
                            style: const TextStyle(
                              fontFamily: 'Oktah',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('dd/MM/yyyy - HH:mm')
                                .format(moment.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      switch (value) {
                        case 'edit':
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditMomentScreen(moment: moment),
                            ),
                          );
                          if (result == 'deleted' || result is Moment) {
                            // Cập nhật trạng thái cục bộ nếu nhận được Moment mới
                            if (result is Moment) {
                              setState(() {
                                moment = result;
                              });
                              widget.onUpdateMoment?.call(result);
                            }
                            widget.refreshFeed?.call();
                          }
                          break;
                        case 'delete':
                          final momentService = Provider.of<MomentService>(
                              context,
                              listen: false);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Moment',
                                  style: TextStyle(
                                    fontFamily: 'Oktah',
                                    fontWeight: FontWeight.w700,
                                    color: Colors.red,
                                    fontSize: 18,
                                  )),
                              content: const Text(
                                  'Are you sure you want to delete this moment?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(221, 38, 68, 29),
                                  )),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      await momentService
                                          .deleteMoment(moment.id);
                                      Provider.of<MomentProvider>(context,
                                              listen: false)
                                          .refreshAllFeeds();
                                      Navigator.pop(context);
                                      widget.refreshFeed?.call();
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Failed to delete moment: $e')),
                                      );
                                    }
                                  },
                                  child: const Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          break;
                        case 'hide':
                          // TODO: Implement hide functionality
                          break;
                        case 'report':
                          // TODO: Implement report functionality
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      final currentUser =
                          Provider.of<AuthManager>(context, listen: false)
                              .loggedInUser;
                      final isOwner = currentUser != null &&
                          currentUser.u_id == moment.user.u_id;

                      if (isOwner) {
                        return [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Sửa bài viết'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Xoá bài viết'),
                          ),
                        ];
                      } else {
                        return [
                          const PopupMenuItem(
                            value: 'hide',
                            child: Text('Ẩn bài viết'),
                          ),
                          const PopupMenuItem(
                            value: 'report',
                            child: Text('Báo cáo bài viết'),
                          ),
                        ];
                      }
                    },
                  ),
                ],
              ),
            ),

            // Status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                moment.content,
                style: const TextStyle(
                  fontFamily: 'Oktah',
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
            const SizedBox(height: 10),

            // Image carousel
            if (moment.media.isNotEmpty)
              SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: moment.media.length,
                  itemBuilder: (context, index) {
                    final image = MomentService.fullImageUrl(
                        moment.media[index].media_url);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          image,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Image indicator
            if (moment.media.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(moment.media.length, (index) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    );
                  }),
                ),
              ),
            const SizedBox(height: 10),

            // Info section with 4 rows layout
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Like, Comment, Share actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _toggleLike,
                        child: Row(
                          children: [
                            FaIcon(
                              moment.isLikedByCurrentUser
                                  ? FontAwesomeIcons.heartCircleCheck
                                  : FontAwesomeIcons.heartCrack,
                              color: moment.isLikedByCurrentUser
                                  ? Colors.red
                                  : const Color.fromARGB(255, 96, 96, 96),
                              size: 19,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${moment.likeCount}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Comment button
                      Row(
                        children: [
                          FaIcon(FontAwesomeIcons.solidCommentDots,
                              size: 19,
                              color: const Color.fromARGB(255, 96, 96, 96)),
                          const SizedBox(width: 4),
                          const Text('0', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(width: 16),

                      Row(
                        children: [
                          FaIcon(FontAwesomeIcons.share,
                              size: 19,
                              color: const Color.fromARGB(255, 96, 96, 96)),
                          const SizedBox(width: 4),
                          const Text('0', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Row 2: Type & Category + expand icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getMomentTypeIcon(moment.type),
                      const SizedBox(width: 4),
                      Text(moment.type, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 16),
                      getCategoryIcon(moment.category.category_name),
                      const SizedBox(width: 4),
                      Text(moment.category.category_name,
                          style: const TextStyle(fontSize: 12)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _isExpanded = !_isExpanded),
                        child: Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  if (_isExpanded) ...[
                    const SizedBox(height: 8),
                    // Coordinates
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on,
                            size: 18, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${moment.latitude?.toStringAsFixed(4) ?? 'N/A'}, ${moment.longitude?.toStringAsFixed(4) ?? 'N/A'}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Location
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.travel_explore,
                            size: 18, color: Colors.black),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            moment.address,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),

            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
}

Icon getMomentTypeIcon(String type) {
  switch (type.toLowerCase()) {
    case 'event':
      return const Icon(Icons.event, size: 18, color: Colors.blueAccent);
    case 'diary':
      return const Icon(Icons.book,
          size: 18, color: Color.fromARGB(255, 48, 39, 176));
    case 'report':
      return const Icon(Icons.list_alt_rounded,
          size: 18, color: Color.fromARGB(255, 163, 22, 22));
    default:
      return const Icon(Icons.help_outline, size: 18, color: Colors.grey);
  }
}

Icon getCategoryIcon(String category) {
  final map = {
    'Nhặt rác': Icons.cleaning_services,
    'Trồng cây': Icons.park,
    'Tái chế': Icons.loop,
    'Tiết kiệm điện': Icons.lightbulb,
    'Không dùng nhựa': Icons.block,
    'Chia sẻ kiến thức môi trường': Icons.school,
    'Đi xe đạp': Icons.directions_bike,
    'Sử dụng năng lượng mặt trời': Icons.solar_power,
    'Sống xanh': Icons.eco,
    'Làm sạch bãi biển': Icons.beach_access,
  };

  return Icon(map[category] ?? Icons.category, size: 18, color: Colors.green);
}
