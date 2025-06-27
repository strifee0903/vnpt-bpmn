import 'package:flutter/material.dart';
import '../../../components/colors.dart';
import '../../../services/moment_service.dart';
import '../../../models/moment.dart';
import '../../moments/moments_card.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final int userId;
  final String username;
  final String avatarUrl;

  const OtherUserProfileScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.avatarUrl,
  });

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  final MomentService _momentService = MomentService();
  List<Moment> _moments = [];
  String? _typeFilter;
  bool _isLoading = false;
  String? _error;
  bool _showFilterBar = false;

  // Draggable filter position
  Offset _filterGroupPosition = Offset(20, 100);
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _fetchUserMoments();
  }

  Future<void> _fetchUserMoments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final moments = await _momentService.getPublicMomentsOfUser(
        userId: widget.userId,
        page: 1,
        limit: 20,
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
            Icon(Icons.book, size: 18, color: Color.fromARGB(255, 48, 39, 176)),
          ),
          const SizedBox(width: 6),
          _buildTypeChip(
            'Event',
            'event',
            Icon(Icons.event, size: 18, color: Colors.blueAccent),
          ),
          const SizedBox(width: 6),
          _buildTypeChip(
            'Report',
            'report',
            Icon(Icons.list_alt_rounded,
                size: 18, color: Color.fromARGB(255, 163, 22, 22)),
          ),
        ],
      ),
    );
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
        });
        _fetchUserMoments();
      },
      selectedColor: button,
      labelStyle: TextStyle(
        color: _typeFilter == value ? Colors.white : Colors.black,
        fontFamily: 'Baloo Bhaijaan 2',
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.white,
          scrolledUnderElevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey[300],
                        child: ClipOval(
                          child: Image.network(
                            MomentService.fullImageUrl(widget.avatarUrl),
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.person),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.username,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: 4),
              ),
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
                      if (_moments.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'No public moments found.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }
                      final moment = _moments[index];
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
                        ),
                      );
                    },
                    childCount: _moments.isEmpty ? 1 : _moments.length,
                  ),
                ),
            ],
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
                      color:
                          _showFilterBar ? button : Colors.grey.withAlpha(100),
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
      bottomNavigationBar: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.transparent,
          border: Border(
            top: BorderSide(color: Colors.transparent),
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 120,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF708C5B).withOpacity(0.8),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Center(
                child: Text(
                  'Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}