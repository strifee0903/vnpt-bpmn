import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  List<Moment> _moments = [];
  bool? _privacyFilter;
  String? _typeFilter;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _fetchMoments(); // Remove the duplicate call, just use this one
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
          _moments = moments; // Replace if first page
        } else {
          _moments.addAll(moments); // Add if loading more
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

  Widget _buildPrivacyChip(String label, bool? value) {
    return ChoiceChip(
      label: Text(label),
      selected: _privacyFilter == value,
      onSelected: (_) {
        setState(() {
          _privacyFilter = value;
          _currentPage = 1; // Reset to first page when filter changes
        });
        _fetchMoments();
      },
      selectedColor: button,
      labelStyle: TextStyle(
        color: _privacyFilter == value ? Colors.white : Colors.black,
        fontFamily: 'Oktah',
        fontSize: 13,
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
          _currentPage = 1; // Reset to first page when filter changes
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

  @override
  Widget build(BuildContext context) {
    final authManager = Provider.of<AuthManager>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshFeed,
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
                          childCount:
                              _moments.isEmpty ? 2 : _moments.length + 1,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
