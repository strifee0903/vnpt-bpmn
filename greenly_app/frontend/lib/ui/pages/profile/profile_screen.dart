import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_manager.dart';
import '../../../components/colors.dart';
import '../../moments/moments_card.dart';
import '../../moments/add_moment_place.dart';
import '../../../services/moment_service.dart';
import '../../../models/moment.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final MomentService _momentService = MomentService();
  List<Moment> _moments = [];
  bool _privacyFilter = true; // Default to public (true)
  String? _typeFilter;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _showFilterBar = true;

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
        page: _currentPage,
        limit: _itemsPerPage,
        is_public: _privacyFilter,
        moment_type: _typeFilter,
      );
      setState(() {
        if (_currentPage == 1) {
          _moments = moments;
        } else {
          _moments.addAll(moments);
        }
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

  Future<void> _refreshFeed() async {
    setState(() {
      _currentPage = 1;
      _moments.clear();
    });
    await _fetchMoments();
  }

  Widget _buildTypeFilterBar() {
    return _showFilterBar
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTypeChip(
                    'All', null, Icon(Icons.all_inclusive, size: 16)),
                const SizedBox(width: 6),
                _buildTypeChip(
                    'Diary',
                    'diary',
                    Icon(Icons.book,
                        size: 18, color: Color.fromARGB(255, 48, 39, 176))),
                const SizedBox(width: 6),
                _buildTypeChip('Event', 'event',
                    Icon(Icons.event, size: 18, color: Colors.blueAccent)),
                const SizedBox(width: 6),
                _buildTypeChip(
                    'Report',
                    'report',
                    Icon(Icons.list_alt_rounded,
                        size: 18, color: Color.fromARGB(255, 163, 22, 22))),
              ],
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildTypeChip(String label, String? value, Icon icon) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: _typeFilter == value,
      onSelected: (_) {
        setState(() {
          _typeFilter = value;
          _currentPage = 1;
        });
        _fetchMoments();
      },
      selectedColor: button,
      labelStyle: TextStyle(
        color: _typeFilter == value ? Colors.white : Colors.black,
        fontFamily: 'Oktah',
        fontSize: 13,
      ),
      backgroundColor: Colors.grey.shade200,
      shape: StadiumBorder(
        side: BorderSide(color: Colors.grey.shade400),
      ),
    );
  }

  Widget _buildPrivacySwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white,
      child: Row(
        children: [
          Switch(
            value: _privacyFilter,
            onChanged: (value) {
              setState(() {
                _privacyFilter = value;
                _currentPage = 1;
              });
              _refreshFeed();
            },
            activeColor: button,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.shade300,
          ),
          const SizedBox(width: 8),
          Icon(
            _privacyFilter ? Icons.public : Icons.lock,
            color: _privacyFilter ? Colors.green : Colors.grey,
            size: 25,
          ),
          // const SizedBox(width: 8),
          // Text(
          //   _privacyFilter ? 'Public' : 'Private',
          //   style: TextStyle(
          //     fontFamily: 'Oktah',
          //     fontWeight: FontWeight.w500,
          //     color: _privacyFilter ? Colors.green : Colors.grey,
          //   ),
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshFeed,
          child: CustomScrollView(
            slivers: [
              // Filter bar (can be toggled)
              SliverPersistentHeader(
                pinned: true,
                delegate: _FilterHeader(
                  showFilterBar: _showFilterBar,
                  onToggleFilter: () {
                    setState(() => _showFilterBar = !_showFilterBar);
                  },
                  filterBar: _buildTypeFilterBar(),
                ),
              ),

              // Privacy switch bar (below filter bar)
              SliverToBoxAdapter(
                child: _buildPrivacySwitch(),
              ),

              // Content
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
              else if (_isLoading && _moments.isEmpty)
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
                          moment: moment,
                          refreshFeed: _refreshFeed,
                        ),
                      );
                    },
                    childCount: _moments.isEmpty ? 2 : _moments.length + 1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterHeader extends SliverPersistentHeaderDelegate {
  final bool showFilterBar;
  final VoidCallback onToggleFilter;
  final Widget filterBar;

  _FilterHeader({
    required this.showFilterBar,
    required this.onToggleFilter,
    required this.filterBar,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: showFilterBar
          ? Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF708C5B).withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onToggleFilter,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.filter_alt,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: filterBar),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.settings, color: Colors.black87),
                    onSelected: (value) {
                      if (value == 'logout') {
                        Provider.of<AuthManager>(context, listen: false)
                            .logout();
                      } else if (value == 'profile') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EditProfileScreen()),
                        );
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
            )
          : Container(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onToggleFilter,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.filter_alt_off,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Spacer(),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.settings, color: Colors.black87),
                    onSelected: (value) {
                      if (value == 'logout') {
                        Provider.of<AuthManager>(context, listen: false)
                            .logout();
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
    );
  }

  @override
  double get maxExtent => 72;

  @override
  double get minExtent => 72;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
