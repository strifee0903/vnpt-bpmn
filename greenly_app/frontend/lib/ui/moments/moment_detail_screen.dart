import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/moment.dart';
import '../../services/moment_service.dart';
import 'moment_manager.dart';

class MomentDetailScreen extends StatefulWidget {
  final int momentId;
  

  const MomentDetailScreen({super.key, required this.momentId});

  @override
  State<MomentDetailScreen> createState() => _MomentDetailScreenState();
}

class _MomentDetailScreenState extends State<MomentDetailScreen> {
  Moment? _moment;
  bool _isLoading = true;

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
    if (_moment == null) return;

    setState(() => _isLoading = true);
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
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết bài viết'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _moment == null
              ? const Center(child: Text('Không tìm thấy bài viết'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with user info
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(
                                MomentService.fullImageUrl(
                                    _moment!.user.u_avt ?? ''),
                              ),
                              onBackgroundImageError: (_, __) =>
                                  const Icon(Icons.person),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _moment!.user.u_name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  DateFormat('dd/MM/yyyy - HH:mm')
                                      .format(_moment!.createdAt),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          _moment!.content,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Media
                      if (_moment!.media.isNotEmpty)
                        SizedBox(
                          height: 300,
                          child: PageView.builder(
                            itemCount: _moment!.media.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Image.network(
                                  MomentService.fullImageUrl(
                                      _moment!.media[index].media_url),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.broken_image),
                                ),
                              );
                            },
                          ),
                        ),

                      // Location info
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_moment!.address.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    _moment!.address,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            if (_moment!.latitude != null &&
                                _moment!.longitude != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.map,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_moment!.latitude?.toStringAsFixed(4)}, '
                                      '${_moment!.longitude?.toStringAsFixed(4)}',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Like/comment/share section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Like button
                            IconButton(
                              icon: FaIcon(
                                _moment!.isLikedByCurrentUser
                                    ? FontAwesomeIcons.solidHeart
                                    : FontAwesomeIcons.heart,
                                color: _moment!.isLikedByCurrentUser
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              onPressed: _toggleLike,
                            ),
                            Text('${_moment!.likeCount}'),

                            // Comment button
                            IconButton(
                              icon:
                                  const Icon(Icons.comment, color: Colors.grey),
                              onPressed: () {
                                // TODO: Implement comment functionality
                              },
                            ),
                            const Text('0'),

                            // Share button
                            IconButton(
                              icon: const Icon(Icons.share, color: Colors.grey),
                              onPressed: () {
                                // TODO: Implement share functionality
                              },
                            ),
                          ],
                        ),
                      ),

                      // Additional info
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Icon(
                              _getMomentTypeIconData(_moment!.type),
                              size: 16,
                              color: _getMomentTypeColor(_moment!.type),
                            ),
                            const SizedBox(width: 8),
                            Text(_moment!.type),
                            const SizedBox(width: 16),
                            Icon(
                              _getCategoryIconData(
                                  _moment!.category.category_name),
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(_moment!.category.category_name),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  IconData _getMomentTypeIconData(String type) {
    switch (type.toLowerCase()) {
      case 'event':
        return Icons.event;
      case 'diary':
        return Icons.book;
      case 'report':
        return Icons.list_alt;
      default:
        return Icons.help_outline;
    }
  }

  Color _getMomentTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'event':
        return Colors.blue;
      case 'diary':
        return Colors.indigo;
      case 'report':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIconData(String category) {
    final map = {
      'Nhặt rác': Icons.cleaning_services,
      'Trồng cây': Icons.park,
      'Tái chế': Icons.loop,
      'Tiết kiệm điện': Icons.lightbulb,
    };
    return map[category] ?? Icons.category;
  }
}
