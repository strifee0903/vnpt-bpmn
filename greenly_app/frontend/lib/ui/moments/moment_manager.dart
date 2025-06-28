import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/moment.dart';
import '../../services/moment_service.dart';

class MomentProvider with ChangeNotifier {
  final MomentService _momentService = MomentService();
  // State for MomentsPage (news feed)
  List<Moment> _moments = [];
  List<Marker> _markers = [];
  Map<String, List<Moment>> _markerMomentMap = {};
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String _typeFilter = 'all';
  LatLng? _currentLocation;
  LatLng? get currentLocation => _currentLocation;

  // State for ProfileScreen
  List<Moment> _profileMoments = [];
  int _profileCurrentPage = 1;
  bool _profileIsLoading = false;
  bool _profileHasMore = true;
  bool _privacyFilter = true;
  String? _profileTypeFilter;

  // Getters for MomentsPage
  List<Moment> get moments => _moments;
  List<Marker> get markers => _markers;
  Map<String, List<Moment>> get markerMomentMap => _markerMomentMap;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String get typeFilter => _typeFilter;

  // Getters for ProfileScreen
  List<Moment> get profileMoments => _profileMoments;
  bool get profileIsLoading => _profileIsLoading;
  bool get profileHasMore => _profileHasMore;
  bool get privacyFilter => _privacyFilter;
  String? get profileTypeFilter => _profileTypeFilter;

  // In MomentProvider class
  void updateMomentLocally(Moment updatedMoment) {
    // Update in main moments list
    final momentIndex = _moments.indexWhere((m) => m.id == updatedMoment.id);
    if (momentIndex != -1) {
      _moments[momentIndex] = updatedMoment;
    }

    // Update in profile moments list
    final profileMomentIndex =
        _profileMoments.indexWhere((m) => m.id == updatedMoment.id);
    if (profileMomentIndex != -1) {
      _profileMoments[profileMomentIndex] = updatedMoment;
    }

    notifyListeners();
  }

  void updateCurrentLocation(LatLng location) {
    _currentLocation = location;
    notifyListeners();
  }

  // Load initial moments for news feed
  Future<void> loadInitialMoments() async {
    _isLoading = true;
    _currentPage = 1;
    notifyListeners();

    try {
      final moments = await _momentService.getNewsFeedMoments(
        page: _currentPage,
        moment_type: _typeFilter == 'all' ? null : _typeFilter,
      );
      _moments = moments;
      _hasMore = moments.isNotEmpty;
    } catch (e) {
      debugPrint('Error loading moments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more moments for news feed
  Future<void> loadMoreMoments() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _currentPage++;
    notifyListeners();

    try {
      final moments = await _momentService.getNewsFeedMoments(
        page: _currentPage,
        moment_type: _typeFilter == 'all' ? null : _typeFilter,
      );
      _moments.addAll(moments);
      _hasMore = moments.isNotEmpty;
    } catch (e) {
      _currentPage--;
      debugPrint('Error loading more moments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set type filter for news feed
  void setTypeFilter(String filter) {
    _typeFilter = filter;
    loadInitialMoments();
  }

  // Load initial moments for profile
  Future<void> loadInitialProfileMoments() async {
    _profileIsLoading = true;
    _profileCurrentPage = 1;
    notifyListeners();

    try {
      final moments = await _momentService.getMyMoments(
        page: _profileCurrentPage,
        is_public: _privacyFilter,
        moment_type: _profileTypeFilter,
      );
      _profileMoments = moments;
      _profileHasMore = moments.isNotEmpty;
    } catch (e) {
      debugPrint('Error loading profile moments: $e');
    } finally {
      _profileIsLoading = false;
      notifyListeners();
    }
  }

  // Load more moments for profile
  Future<void> loadMoreProfileMoments() async {
    if (_profileIsLoading || !_profileHasMore) return;

    _profileIsLoading = true;
    _profileCurrentPage++;
    notifyListeners();

    try {
      final moments = await _momentService.getMyMoments(
        page: _profileCurrentPage,
        is_public: _privacyFilter,
        moment_type: _profileTypeFilter,
      );
      _profileMoments.addAll(moments);
      _profileHasMore = moments.isNotEmpty;
    } catch (e) {
      _profileCurrentPage--;
      debugPrint('Error loading more profile moments: $e');
    } finally {
      _profileIsLoading = false;
      notifyListeners();
    }
  }

  // Set privacy filter for profile
  void setPrivacyFilter(bool isPublic) {
    _privacyFilter = isPublic;
    loadInitialProfileMoments();
  }

  // Set type filter for profile
  void setProfileTypeFilter(String? filter) {
    _profileTypeFilter = filter;
    loadInitialProfileMoments();
  }

  // Refresh both feeds after a moment is created, updated, or deleted
  Future<void> refreshAllFeeds() async {
    try {
      await Future.wait([
        loadInitialMoments(),
        loadInitialProfileMoments(),
      ]);
    } catch (e) {
      debugPrint('🔴🔴🔴Error refreshing feeds: $e');
    }
  }

  // Cập nhật trạng thái like/unlike cho một bài viết
  void updateMomentLikeStatus(int momentId, bool isLiked, int likeCount) {
    // Cập nhật trong danh sách _moments
    final momentIndex = _moments.indexWhere((m) => m.id == momentId);
    if (momentIndex != -1) {
      _moments[momentIndex] = _moments[momentIndex].copyWith(
        isLikedByCurrentUser: isLiked,
        likeCount: likeCount,
      );
      print('Updated like status in _moments for moment: $momentId');
    } else {
      print('Moment $momentId not found in _moments');
    }

    // Cập nhật trong danh sách _profileMoments
    final profileMomentIndex =
        _profileMoments.indexWhere((m) => m.id == momentId);
    if (profileMomentIndex != -1) {
      _profileMoments[profileMomentIndex] =
          _profileMoments[profileMomentIndex].copyWith(
        isLikedByCurrentUser: isLiked,
        likeCount: likeCount,
      );
      print('Updated like status in _profileMoments for moment: $momentId');
    } else {
      print('Moment $momentId not found in _profileMoments');
    }

    notifyListeners();
  }

  Future<void> fetchAllMoments() async {
    print('📞 DEBUG - Fetching all moments...');
    final List<Marker> newMarkers = [];
    final Map<String, List<Moment>> newMarkerMomentMap = {};
    _moments.clear();
    _markerMomentMap.clear();

    int page = 1;
    int limit = 100;
    bool hasMore = true;

    while (hasMore) {
      try {
        final moments = await _momentService.getNewsFeedMoments(
          page: page,
          limit: limit,
        );
        _moments.addAll(moments);

        for (var moment in moments) {
          if (moment.latitude != null && moment.longitude != null) {
            final LatLng point = LatLng(moment.latitude!, moment.longitude!);
            newMarkers.add(
              Marker(
                point: point,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  color: Color.fromARGB(255, 41, 149, 86),
                  size: 35,
                ),
              ),
            );
            newMarkerMomentMap
                .putIfAbsent(point.toString(), () => [])
                .add(moment);
          }
        }

        if (moments.length < limit) {
          hasMore = false;
        } else {
          page++;
        }
      } catch (e) {
        print('❌ Error fetching page $page: $e');
        hasMore = false;
      }
    }

    _markers = newMarkers; // 👈 Gán lại list mới
    _markerMomentMap = newMarkerMomentMap; // 👈 Gán lại map mới
    notifyListeners();
  }
}
