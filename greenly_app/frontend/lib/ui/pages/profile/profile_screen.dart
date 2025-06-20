import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../shared/getImageUrl.dart';
import '../../auth/auth_manager.dart';
import '../../../components/colors.dart';
import '../../moments/moments_card.dart';
import '../../moments/add_moment_place.dart';
import '../../../services/moment_service.dart';
import '../../../models/moment.dart';

class ProfileScreen extends StatefulWidget {
  final bool showBottomNav; 
  const ProfileScreen({super.key, this.showBottomNav = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final MomentService _momentService = MomentService();
  List<Moment> _moments = [];
  bool? _privacyFilter; // null, true, false
  String? _typeFilter; // null, 'diary', 'event', 'report'
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMoments();
  }

  Future<void> _fetchMoments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final moments = await _momentService.getMyMoments(
        page: 1,
        limit: 20,
        is_public: _privacyFilter,
        moment_type: _typeFilter,
      );

      setState(() {
        _moments = moments;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load moments: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildPrivacyChip(String label, bool? value) {
    return ChoiceChip(
      label: Text(label),
      selected: _privacyFilter == value,
      onSelected: (_) {
        setState(() {
          _privacyFilter = value;
        });
        _fetchMoments();
      },
      selectedColor: button,
      labelStyle: TextStyle(
        color: _privacyFilter == value ? Colors.white : Colors.black,
        fontFamily: 'Oktah',
        fontSize: 13
      ),
      backgroundColor: Colors.grey.shade200,
      shape: StadiumBorder(
        side: BorderSide(color: Colors.grey.shade400),
      ),
    );
  }

  Widget _buildTypeChip(String label, String? value) {
    return ChoiceChip(
      label: Text(label),
      selected: _typeFilter == value,
      onSelected: (_) {
        setState(() {
          _typeFilter = value;
        });
        _fetchMoments();
      },
      selectedColor: button,
      labelStyle: TextStyle(
        color: _typeFilter == value ? Colors.white : Colors.black,
        fontFamily: 'Oktah',
        fontSize: 13
      ),
      backgroundColor: Colors.grey.shade200,
      shape: StadiumBorder(
        side: BorderSide(color: Colors.grey.shade400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authManager = Provider.of<AuthManager>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120), // Tăng chiều cao AppBar
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter chips bên trái
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hàng đầu: privacy filter
                        // Hàng thứ hai: type filter
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildTypeChip('All', null),
                              const SizedBox(width: 6),
                              _buildTypeChip('Diary', 'diary'),
                              const SizedBox(width: 6),
                              _buildTypeChip('Event', 'event'),
                              const SizedBox(width: 6),
                              _buildTypeChip('Report', 'report'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildPrivacyChip('All', null),
                              const SizedBox(width: 6),
                              _buildPrivacyChip('Public', true),
                              const SizedBox(width: 6),
                              _buildPrivacyChip('Private', false),
                            ],
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                  // Nút settings bên phải
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.settings, color: Colors.black),
                    onSelected: (value) {
                      if (value == 'logout') {
                        authManager.logout();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                          value: 'profile', child: Text('Edit Profile')),
                      const PopupMenuItem(
                          value: 'logout', child: Text('Logout')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Main content
            Expanded(
              child: CustomScrollView(
                slivers: [
                  if (_error != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                  else if (_isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == 0) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: AddMomentPlace(),
                            );
                          }
                          if (_moments.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'No moments found.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          final moment = _moments[index - 1];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF708C5B).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: MomentCard(
                                userId: moment.user.u_id,
                                username: moment.user.u_name,
                                avatar: fullImageUrl(moment.user.u_avt),
                                status: moment.content,
                                images: moment.media.isNotEmpty
                                    ? moment.media
                                        .map((m) => fullImageUrl(m.media_url))
                                        .toList()
                                    : null,
                                location: moment.address,
                                time: DateFormat('yyyy-MM-dd HH:mm')
                                    .format(moment.createdAt),
                                type: moment.type,
                                category: moment.category.category_name,
                                latitude: moment.latitude,
                                longitude: moment.longitude,
                              )
                          );
                        },
                        childCount: _moments.isEmpty ? 2 : _moments.length + 1,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    
    
    );
  }
}
