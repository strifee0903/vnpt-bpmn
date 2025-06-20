// moments_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/colors.dart';
import '../../services/moment_service.dart';
import '../../models/moment.dart';
import 'add_moment.dart';
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
  String _filter = 'all';

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
      print('❌ DEBUG - Error loading initial moments: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<List<Moment>> _fetchMoments() async {
    bool? isPublic;
    if (_filter == 'public') isPublic = true;
    if (_filter == 'private') isPublic = false;
    return await _momentService.getNewsFeedMoments(
      page: _currentPage,
      limit: _itemsPerPage,
      is_public: _filter == 'all' ? null : isPublic,
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
      print('❌ DEBUG - Error loading more moments: $e');
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

  Widget _buildChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) {
        setState(() {
          _filter = value;
          _currentPage = 1;
          _moments.clear();
        });
        _loadInitialMoments();
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
    return Scaffold(
      backgroundColor: background,
      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Filter (Pinned)
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverFilterBar(
                selected: _filter,
                onChanged: (value) {
                  setState(() => _filter = value);
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
class _SliverFilterBar extends SliverPersistentHeaderDelegate {
  final String selected;
  final Function(String) onChanged;

  _SliverFilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    );
  }

  Widget _buildChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: selected == value,
      onSelected: (_) => onChanged(value),
      selectedColor: button,
      labelStyle: TextStyle(
        color: selected == value ? Colors.white : Colors.black,
        fontFamily: 'Oktah',
      ),
      backgroundColor: Colors.grey.shade200,
      shape: StadiumBorder(
        side: BorderSide(color: Colors.grey.shade400),
      ),
    );
  }

  @override
  double get maxExtent => 48 + 16; // height + padding
  @override
  double get minExtent => 48 + 16;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
