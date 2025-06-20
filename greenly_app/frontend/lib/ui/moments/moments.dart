import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/colors.dart';
import '../../services/moment_service.dart';
import '../../models/moment.dart';
import 'moments_card.dart';
import 'add_moment_place.dart';

String fullImageUrl(String? relativePath) {
  final imageBaseUrl = MomentService.imageBaseUrl;
  if (relativePath == null || relativePath.isEmpty) {
    return '$imageBaseUrl/public/images/blank_avt.jpg';
  }
  if (relativePath.startsWith('http')) {
    return relativePath;
  }
  return '$imageBaseUrl${relativePath.startsWith('/') ? '' : '/'}$relativePath';
}

class MomentsPage extends StatefulWidget {
  const MomentsPage({super.key});

  @override
  _MomentsPageState createState() => _MomentsPageState();
}

class _MomentsPageState extends State<MomentsPage> {
  final MomentService _momentService = MomentService();
  final ScrollController _scrollController = ScrollController();
  final List<Moment> _moments = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  final int _itemsPerPage = 10;
  String _typeFilter = 'all'; // "diary", "event", "report", "all"

  @override
  void initState() {
    super.initState();
    _loadInitialMoments();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialMoments() async {
    setState(() => _isLoading = true);
    try {
      final moments = await _fetchMoments();
      setState(() {
        _moments.addAll(moments);
        _isLoading = false;
        _hasMore = moments.length == _itemsPerPage;
      });
    } catch (e) {
      print('❌ DEBUG - Error loading initial moments: \$e');
      setState(() => _isLoading = false);
    }
  }

  Future<List<Moment>> _fetchMoments() async {
    return await _momentService.getNewsFeedMoments(
      page: _currentPage,
      limit: _itemsPerPage,
      moment_type: _typeFilter == 'all' ? null : _typeFilter,
    );
  }

  Future<void> _loadMoreMoments() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);
    _currentPage++;
    try {
      final moments = await _fetchMoments();
      setState(() {
        _moments.addAll(moments);
        _isLoading = false;
        _hasMore = moments.length == _itemsPerPage;
      });
    } catch (e) {
      print('❌ DEBUG - Error loading more moments: \$e');
      setState(() {
        _isLoading = false;
        _currentPage--;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_scrollController.position.outOfRange) {
      _loadMoreMoments();
    }
  }

  Future<void> _refreshFeed() async {
    setState(() {
      _currentPage = 1;
      _moments.clear();
      _hasMore = true;
    });
    await _loadInitialMoments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // SliverPersistentHeader chứa filter theo type
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverFilterBar(
                selectedType: _typeFilter,
                onTypeChanged: (value) {
                  setState(() => _typeFilter = value);
                  _refreshFeed();
                },
              ),
            ),

            // AddMomentPlace
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: AddMomentPlace(),
              ),
            ),

            // Moments list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= _moments.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: _hasMore
                            ? const CircularProgressIndicator()
                            : const Text('No more moments to load'),
                      ),
                    );
                  }

                  final moment = _moments[index];
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
                    time:
                        DateFormat('yyyy-MM-dd HH:mm').format(moment.createdAt),
                    type: moment.type,
                    category: moment.category.category_name,
                    latitude: moment.latitude,
                    longitude: moment.longitude,
                  );
                },
                childCount: _moments.length + (_hasMore ? 1 : 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Sliver filter bar delegate with only type filter
class _SliverFilterBar extends SliverPersistentHeaderDelegate {
  final String selectedType;
  final Function(String) onTypeChanged;

  _SliverFilterBar({
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildChip('All', 'all'),
            const SizedBox(width: 6),
            _buildChip('Diary', 'diary'),
            const SizedBox(width: 6),
            _buildChip('Event', 'event'),
            const SizedBox(width: 6),
            _buildChip('Report', 'report'),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedType == value,
      onSelected: (_) => onTypeChanged(value),
      selectedColor: button,
      labelStyle: TextStyle(
        color: selectedType == value ? Colors.white : Colors.black,
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
  double get maxExtent => 56;
  @override
  double get minExtent => 56;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
