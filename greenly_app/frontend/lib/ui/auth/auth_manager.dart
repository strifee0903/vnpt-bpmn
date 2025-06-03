import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';

class EmailVerificationRequiredException implements Exception {
  final String message;
  EmailVerificationRequiredException(this.message);

  @override
  String toString() => message;
}

class AuthManager with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isSplashComplete = false;

  bool get isSplashComplete => _isSplashComplete;
  bool get isAuth => _user != null;
  User? get user => _user;

  bool get isInitialized => _isSplashComplete;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');

    if (userData != null) {
      try {
        _user = User.fromJson(jsonDecode(userData));
      } catch (e) {
        _user = null;
      }
    }

    _isSplashComplete = true;
    notifyListeners();
  }

  Future<void> login({
    required String uEmail,
    required String uPass,
  }) async {
    try {
      final response = await _authService.login(uEmail: uEmail, uPass: uPass);
      final json = jsonDecode(response.body);

      if (json['status'] != 'success') {
        throw Exception(json['message'] ?? 'Login failed');
      }

      _user = User.fromJson(json['data']['data']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(_user!.toJson()));
      notifyListeners();
    } catch (e) {
      print('AuthManager error: $e');
      rethrow;
    }
  }

  Future<void> register({
    required String uName,
    required String uEmail,
    required String uPass,
    required String uAddress,
    required String uBirthday,
  }) async {
    final response = await _authService.registerUser(
      uName: uName,
      uEmail: uEmail,
      uPass: uPass,
      uAddress: uAddress,
      uBirthday: uBirthday,
    );

    final json = jsonDecode(response.body);
    if (json['status'] != 'success') {
      throw Exception(json['message'] ?? 'Registration failed');
    }

    final userData = json['data']['user'];
    if (userData['is_verified'] == 0) {
      throw EmailVerificationRequiredException(
        'Registration successful! Please verify your email to continue.',
      );
    }

    _user = User.fromJson(userData);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(_user!.toJson()));
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    notifyListeners();
  }
}
