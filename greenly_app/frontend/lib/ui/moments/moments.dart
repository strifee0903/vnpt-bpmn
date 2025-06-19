// moments_page.dart (unchanged, verified)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/colors.dart';
import '../../services/moment_service.dart';
import '../../models/moment.dart';
import 'add_moment.dart';
import 'moments_card.dart';

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
      final moments = await _momentService.getNewsFeedMoments(
          page: _currentPage, limit: _itemsPerPage);
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

  Future<void> _loadMoreMoments() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);
    _currentPage++;
    try {
      final moments = await _momentService.getNewsFeedMoments(
          page: _currentPage, limit: _itemsPerPage);
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

  Future<void> _navigateToAddMoment() async {
    final newMoment = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMomentPage()),
    );
    if (newMoment != null && newMoment is Moment) {
      setState(() {
        _moments.insert(0, newMoment);
      });
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_home',
        onPressed: _navigateToAddMoment,
        backgroundColor: button,
        tooltip: 'Create New Moment',
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _moments.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshFeed,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _moments.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
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
              ),
            ),
    );
  }
}
