// user_provider.dart
import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load current user
  Future<void> loadCurrentUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _userService.getCurrentUser();
    } catch (e) {
      _error = 'Failed to load user: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh user profile (call this after profile update)
  Future<void> refreshUserProfile() async {
    try {
      _currentUser = await _userService.getMyProfile();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to refresh profile: $e';
      notifyListeners();
    }
  }

  // Update user locally (for immediate UI updates)
  void updateUser(User updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  // Clear user data (for logout)
  void clearUser() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }
}
