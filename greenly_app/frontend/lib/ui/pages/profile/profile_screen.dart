import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_manager.dart';
import '../../../components/colors.dart';
import '../../moments/moment_manager.dart';
import '../../moments/moments_card.dart';
import '../../moments/add_moment_place.dart';

import 'edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Draggable filter position
  Offset _filterGroupPosition = Offset(20, 100);
  bool _isDragging = false;
  bool _showFilterBar = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MomentProvider>(context, listen: false)
          .loadInitialProfileMoments();
    });
  }

  Future<void> _refreshFeed() async {
    await Provider.of<MomentProvider>(context, listen: false)
        .loadInitialProfileMoments();
  }

  // Update filter position with constraints
  void _updateFilterPosition(Offset newPosition) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Constrain X coordinate
    double x = newPosition.dx;
    x = x.clamp(0.0, screenWidth - 30);

    // Constrain Y coordinate
    double y = newPosition.dy;
    y = y.clamp(0.0, screenHeight - 120);

    setState(() {
      _filterGroupPosition = Offset(x, y);
    });
  }

  Widget _buildTypeChip(String label, String? value, Icon icon) {
    return Consumer<MomentProvider>(
      builder: (context, momentProvider, child) {
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 4),
              Text(label),
            ],
          ),
          selected: momentProvider.profileTypeFilter == value,
          onSelected: (_) {
            momentProvider.setProfileTypeFilter(value);
          },
          selectedColor: button,
          labelStyle: TextStyle(
            color: momentProvider.profileTypeFilter == value
                ? Colors.white
                : Colors.black,
            fontFamily: 'Oktah',
            fontSize: 13,
          ),
          backgroundColor: Colors.grey.shade200,
          shape: StadiumBorder(
            side: BorderSide(color: Colors.grey.shade400),
          ),
        );
      },
    );
  }

  Widget _buildTypeFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTypeChip('All', null, Icon(Icons.all_inclusive, size: 16)),
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
    );
  }
  
  Widget _buildPrivacySwitch(MomentProvider momentProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white,
      child: Row(
        children: [
          Switch(
            value: momentProvider.privacyFilter,
            onChanged: (value) {
              momentProvider.setPrivacyFilter(value);
            },
            activeColor: button,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.shade300,
          ),
          const SizedBox(width: 8),
          Icon(
            momentProvider.privacyFilter ? Icons.public : Icons.lock,
            color: momentProvider.privacyFilter ? Colors.green : Colors.grey,
            size: 25,
          ),
          const Spacer(),
          PopupMenuButton<String>(
            icon: Icon(Icons.settings, color: Colors.black87),
            onSelected: (value) {
              if (value == 'logout') {
                Provider.of<AuthManager>(context, listen: false).logout();
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
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<MomentProvider>(context);
    return Consumer<MomentProvider>(
    builder: (context, momentProvider, child) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _refreshFeed,
              child: CustomScrollView(
                slivers: [
                  // Privacy switch bar
                  SliverToBoxAdapter(
                    child: _buildPrivacySwitch(momentProvider),
                  ),

                  // Content
                  if (momentProvider.profileIsLoading &&
                      momentProvider.profileMoments.isEmpty)
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
                          if (momentProvider.profileMoments.isEmpty) {
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
                          final moment = momentProvider.profileMoments[index - 1];
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
                        childCount: momentProvider.profileMoments.isEmpty ? 2 : momentProvider.profileMoments.length + 1,
                      ),
                    ),
                ],
              ),
            ),

            // Floating draggable filter group
            Positioned(
              left: _filterGroupPosition.dx,
              top: _filterGroupPosition.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  _updateFilterPosition(
                    Offset(
                      _filterGroupPosition.dx + details.delta.dx,
                      _filterGroupPosition.dy + details.delta.dy,
                    ),
                  );
                  setState(() => _isDragging = true);
                },
                onPanEnd: (_) {
                  Future.delayed(const Duration(milliseconds: 200), () {
                    if (mounted) {
                      setState(() => _isDragging = false);
                    }
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter icon button
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _showFilterBar
                            ? button
                            : Colors.grey.withAlpha(100),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: _isDragging ? 8 : 4,
                            spreadRadius: _isDragging ? 2 : 1,
                            offset: Offset(0, _isDragging ? 4 : 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          _showFilterBar
                              ? Icons.filter_alt
                              : Icons.filter_4_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          setState(() => _showFilterBar = !_showFilterBar);
                        },
                      ),
                    ),

                    // Filter bar
                    if (_showFilterBar) ...[
                      const SizedBox(height: 10),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.81,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF708C5B).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 300,
                          child: _buildTypeFilterBar(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  });
  }
}
