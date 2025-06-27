import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/colors.dart';
import 'moment_manager.dart';
import 'moments_card.dart';
import 'add_moment_place.dart';

class MomentsPage extends StatefulWidget {
  const MomentsPage({super.key});

  @override
  _MomentsPageState createState() => _MomentsPageState();
}

class _MomentsPageState extends State<MomentsPage> {
  final ScrollController _scrollController = ScrollController();
  Offset _filterGroupPosition = Offset(20, 100);
  bool _isDragging = false;
  bool _showFilterBar = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MomentProvider>(context, listen: false).loadInitialMoments();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_scrollController.position.outOfRange) {
      Provider.of<MomentProvider>(context, listen: false).loadMoreMoments();
    }
  }

  Future<void> _refreshFeed() async {
    await Provider.of<MomentProvider>(context, listen: false)
        .loadInitialMoments();
  }

  // Method to handle post creation callback
  void _handlePostCreated() {
    _refreshFeed();
  }

  // Method to handle post deletion callback
  void _handlePostDeleted() {
    _refreshFeed();
  }

  // Giới hạn phạm vi di chuyển
  void _updateFilterPosition(Offset newPosition) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Giới hạn tọa độ X (ngang)
    double x = newPosition.dx;
    x = x.clamp(0.0, screenWidth - 30); // Trừ đi chiều rộng ước tính của nút

    // Giới hạn tọa độ Y (dọc)
    double y = newPosition.dy;
    y = y.clamp(0.0, screenHeight - 120); // Tránh phần header và footer

    setState(() {
      _filterGroupPosition = Offset(x, y);
    });
  }

  @override
  Widget build(BuildContext context) {
    final momentProvider = Provider.of<MomentProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshFeed,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: AddMomentPlace(
                      onPostCreated: _handlePostCreated, // Pass the callback
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= momentProvider.moments.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: momentProvider.hasMore
                                ? const CircularProgressIndicator()
                                : const Text('No more moments to load'),
                          ),
                        );
                      }
                      final moment = momentProvider.moments[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF708C5B).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: MomentCard(
                          key: ValueKey(moment.id),
                          moment: moment,
                          refreshFeed:
                              _handlePostDeleted, // Pass the refresh callback for deletion
                        ),
                      );
                    },
                    childCount: momentProvider.moments.length + (momentProvider.hasMore ? 1 : 0),
                  ),
                ),
              ],
            ),
          ),

          // Floating draggable filter group (icon + filter bar)
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
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildChip('All', 'all',
                                  Icon(Icons.all_inclusive, size: 16)),
                              const SizedBox(width: 6),
                              _buildChip(
                                'Diary',
                                'diary',
                                Icon(Icons.book,
                                    size: 18,
                                    color: Color.fromARGB(255, 48, 39, 176)),
                              ),
                              const SizedBox(width: 6),
                              _buildChip(
                                'Event',
                                'event',
                                Icon(Icons.event,
                                    size: 18, color: Colors.blueAccent),
                              ),
                              const SizedBox(width: 6),
                              _buildChip(
                                'Report',
                                'report',
                                Icon(Icons.list_alt_rounded,
                                    size: 18,
                                    color: Color.fromARGB(255, 163, 22, 22)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String value, Icon icon) {
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
          selected: momentProvider.typeFilter == value,
          onSelected: (_) {
            momentProvider.setTypeFilter(value);
          },
          selectedColor: button,
          labelStyle: TextStyle(
            color: momentProvider.typeFilter == value
                ? Colors.white
                : Colors.black,
            fontFamily: 'Baloo Bhaijaan 2',
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
}
