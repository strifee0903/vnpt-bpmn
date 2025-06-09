import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';

class EmailVerificationRequiredException implements Exception {
  final String message;
  EmailVerificationRequiredException(this.message);

  @override
  String toString() => message;
}

class AuthManager with ChangeNotifier {
  final AuthService _authService;
  User? _loggedInUser;
  bool _isInitialized = false;
  bool _isSplashComplete = false;

  AuthManager() : _authService = AuthService() {
    _initializeAuthListener();
  }

  void _initializeAuthListener() {
    _authService.onAuthChange = (User? user) {
      _loggedInUser = user;
      notifyListeners();
    };
  }

  User? get loggedInUser => _loggedInUser;
  bool get isAuth => _loggedInUser != null;
  bool get isInitialized => _isInitialized;
  bool get isSplashComplete => _isSplashComplete;
  

  Future<void> initialize() async {
    print('🔴 Starting initialization');
    await Future.wait([
      tryAutoLogin(),
      Future.delayed(const Duration(seconds: 5)),
    ]);
    _isInitialized = true;
    _isSplashComplete = true;
    notifyListeners();
    print('✅ Initialization complete: isAuth=$isAuth');
  }

  Future<void> tryAutoLogin() async {
    print('🔴 Starting tryAutoLogin()');
    try {
      final user = await _authService.getUserFromStore();
      print(
          '✅ getUserFromStore completed: user = ${user != null ? 'exists (ID: ${user.u_email})' : 'null'}');
      if (user != null) {
        _loggedInUser = user;
        notifyListeners(); // Thông báo khi có người dùng
      } else {
        _loggedInUser = null;
      }
      print('✅ tryAutoLogin completed successfully');
    } catch (error) {
      print('❌ Auto login error: $error');
      _loggedInUser = null;
    }
  }

  Future<void> signup(
      String uName, String uEmail, String uPass, String uAddress, String uBirthday) async {
    try {
      print('🔴 AuthManager: Starting signup process');
      final user = await _authService.signup(uName, uEmail, uPass, uAddress, uBirthday);
      _loggedInUser = user;
      notifyListeners();
      print('✅ AuthManager: Signup completed successfully');
    } catch (error) {
      print('❌ Signup error in manager: $error');
      rethrow;
    }
  }

  Future<void> login(String uEmail, String uPass) async {
    try {
      final user = await _authService.login(uEmail, uPass);
      _loggedInUser = user;
      notifyListeners();
      print(
          '✅ Login successful: isAuth=$isAuth}');
    } catch (error) {
      print('❌ Login error in manager: $error');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _loggedInUser = null;
    notifyListeners();
  }
}
