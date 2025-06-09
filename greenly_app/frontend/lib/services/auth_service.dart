import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

const user_url = 'http://10.0.2.2:3000/api/users';

class AuthService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? user_url;
  void Function(User? user)? onAuthChange;
  AuthService({this.onAuthChange});

  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<User> signup(
    String username,
    String email,
    String password,
    String address,
    String birthday,
  ) async {
    final uri = Uri.parse('$baseUrl/users/registration/');
    var request = http.MultipartRequest('POST', uri);

    request.fields['u_name'] = username;
    request.fields['u_email'] = email;
    request.fields['u_pass'] = password;
    request.fields['u_address'] = address;
    request.fields['u_birthday'] = birthday;

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📤 Sending to: ${uri.toString()}');
      print('📄 With data: ${request.fields}');

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        final userData = jsonResponse['data']['user'];
        final user = User.fromJson(userData);

        _currentUser = user;
        onAuthChange?.call(user);

        print('✅ Registration success! User data: $userData');

        return user;
      } else if (response.statusCode == 409) {
        throw Exception("⚠️ Email already exists.");
      } else {
        print('❌ Registration failed: ${response.body}');
        throw Exception("Registration failed: ${response.body}");
      }
    } catch (error) {
      print('💥 Signup exception: $error');
      throw Exception("Signup failed: $error");
    }
  }

  Future<User?> getUserFromStore() async {
    if (_currentUser != null) return _currentUser;

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('auth_user');
    if (userJson == null) return null;

    final data = jsonDecode(userJson);
    final user = User.fromJson(data);
    _currentUser = user;
    onAuthChange?.call(user); 
    return user;
  }
  Future<User> login(String email, String password) async {
    final uri = Uri.parse('$baseUrl/users/login/');
    var request = http.MultipartRequest('POST', uri);

    request.fields['u_email'] = email;
    request.fields['u_pass'] = password;

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📤 Sending login to: ${uri.toString()}');
      print('📄 With data: ${request.fields}');
      print('📥 Raw response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['data'] == null ||
            jsonResponse['data']['user'] == null) {
          throw Exception("⚠️ Invalid response format: missing user data.");
        }

        final userData = jsonResponse['data']['user'];
        final user = User.fromJson(userData);

        // Lưu dữ liệu người dùng vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_user', jsonEncode(userData));

        _currentUser = user;
        onAuthChange?.call(user);

        print('✅ Login success! User data: $userData');

        return user;
      } else if (response.statusCode == 400) {
        throw Exception("⚠️ Invalid email or password.");
      } else {
        print('❌ Login failed: ${response.body}');
        throw Exception("Login failed: ${response.body}");
      }
    } catch (error) {
      print('💥 Login exception: $error');
      throw Exception("Login failed: $error");
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_user');
    _currentUser = null;
    onAuthChange?.call(null);
    print('👋 Logged out');
  }
}
