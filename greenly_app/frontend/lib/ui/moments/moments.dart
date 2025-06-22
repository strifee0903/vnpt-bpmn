import 'package:flutter/material.dart';
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
  bool _showFilterBar = true;

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

  Widget _buildFilterBar() {
    return _showFilterBar
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChip('All', 'all', Icon(Icons.all_inclusive, size: 16)),
                const SizedBox(width: 6),
                _buildChip(
                    'Diary',
                    'diary',
                    Icon(Icons.book,
                        size: 18, color: Color.fromARGB(255, 48, 39, 176))),
                const SizedBox(width: 6),
                _buildChip('Event', 'event',
                    Icon(Icons.event, size: 18, color: Colors.blueAccent)),
                const SizedBox(width: 6),
                _buildChip(
                    'Report',
                    'report',
                    Icon(Icons.list_alt_rounded,
                        size: 18, color: Color.fromARGB(255, 163, 22, 22))),
              ],
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildChip(String label, String value, Icon icon) {
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
        setState(() => _typeFilter = value);
        _refreshFeed();
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _FilterHeader(
                showFilterBar: _showFilterBar,
                onToggleFilter: () {
                  setState(() => _showFilterBar = !_showFilterBar);
                },
                filterBar: _buildFilterBar(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: AddMomentPlace(),
              ),
            ),
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
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF708C5B).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: MomentCard(
                      key: ValueKey(moment.id),
                      moment: moment,
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                ],
              ),
            )
          : Container(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
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
            ),
    );
  }

  @override
  double get maxExtent => 80;

  @override
  double get minExtent => 80;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
