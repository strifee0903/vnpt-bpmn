import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/user.dart';
import '../../../services/user_service.dart';
import '../../../shared/getImageUrl.dart';
import '../../auth/auth_manager.dart';
import '../../../components/colors.dart';
import '../../moments/moments_card.dart';
import '../../moments/add_moment_place.dart';
import '../../../services/moment_service.dart';
import '../../../models/moment.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final MomentService _momentService = MomentService();
  final UserService _userService = UserService();
  List<Moment> _moments = [];
  String _filter = 'all';
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _fetchMoments();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      setState(() {
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load user data: $e';
      });
    }
  }

  Future<void> _fetchMoments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      bool? isPublic;
      if (_filter == 'public') isPublic = true;
      if (_filter == 'private') isPublic = false;

      final moments = await _momentService.getMyMoments(
        page: 1,
        limit: 20,
        is_public: _filter == 'all' ? null : isPublic,
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

  Widget _buildChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) {
        setState(() {
          _filter = value;
        });
        _fetchMoments();
      },
      selectedColor: button,
      labelStyle: TextStyle(
        color: _filter == value ? Colors.white : Colors.black,
        fontFamily: 'Oktah',
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildChip('All', 'all'),
                    const SizedBox(width: 6),
                    _buildChip('Public', 'public'),
                    const SizedBox(width: 6),
                    _buildChip('Private', 'private'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.settings, color: Colors.black),
              onSelected: (value) {
                if (value == 'logout') {
                  authManager.logout();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'profile',
                  child: Text('Edit Profile'),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ],
            ),
          ],
        ),
      ),

      body: SafeArea(
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
                    return MomentCard(
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
                    );
                  },
                  childCount: _moments.isEmpty ? 2 : _moments.length + 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
