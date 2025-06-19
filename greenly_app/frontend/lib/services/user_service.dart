// user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../shared/api_exception.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const userUrl = 'http://192.168.1.7:3000/api/users'; // Updated to match backend

class UserService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? userUrl;
  static final client = http.Client(); // Persistent client for cookies

  Future<String?> _getSessionCookie() async {
    final prefs = await SharedPreferences.getInstance();
    final cookie = prefs.getString('session_cookie');
    print('🔐 DEBUG - Session cookie: $cookie');
    return cookie;
  }

  // Load user from local storage
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('auth_user');
    print('📦 DEBUG - Stored auth_user: $userJson');
    if (userJson == null) return null;

    try {
      final userMap = jsonDecode(userJson);
      return User.fromJson(userMap);
    } catch (e) {
      print('❌ Failed to parse user data: $e');
      return null;
    }
  }


  // Get u_id from local store (shortcut)
  Future<int?> getCurrentUserId() async {
    final user = await getCurrentUser();
    return user?.u_id;
  }

  // Get your own user profile
  Future<User> getMyProfile() async {
    final uri = Uri.parse('$baseUrl/users/myInfo/');
    print('🌐 DEBUG - Request URL: $uri');
    final sessionCookie = await _getSessionCookie();
    final Map<String, String> headers =
        sessionCookie != null && sessionCookie.isNotEmpty
            ? {'Cookie': sessionCookie}
            : <String, String>{};

    final response = await client.get(uri, headers: headers);
    print('📡 DEBUG - Response status: ${response.statusCode}');
    print('📡 DEBUG - Response body: ${response.body}');

    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      final userJson = body['data']['contact'];
      final user = User.fromJson(userJson);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user', jsonEncode(user.toJson()));
      print('📦 DEBUG - Updated auth_user: ${jsonEncode(user.toJson())}');
      return user;
    } else {
      throw ApiException(body['message'] ?? 'Failed to fetch profile.');
    }
  }

  // Get user by ID (used for viewing others)
  Future<User> getUserById(int userId) async {
    final uri = Uri.parse('$baseUrl/users/info/$userId');
    print('🌐 DEBUG - Request URL: $uri');
    final sessionCookie = await _getSessionCookie();
    final Map<String, String> headers = sessionCookie != null && sessionCookie.isNotEmpty
        ? {'Cookie': sessionCookie}
        : <String, String>{};

    final response = await client.get(uri, headers: headers);
    print('📡 DEBUG - Response status: ${response.statusCode}');
    print('📡 DEBUG - Response body: ${response.body}');

    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      final userJson = body['data']['user'];
      return User.fromJson(userJson);
    } else {
      throw ApiException(body['message'] ?? 'User not found.');
    }
  }

  // Update current user
  Future<User> updateCurrentUser(Map<String, String> fields,
      {http.MultipartFile? avatarFile}) async {
    final userId = await getCurrentUserId();
    if (userId == null) throw ApiException('Not logged in.');

    final uri = Uri.parse('$baseUrl/updateProfile');
    print('🌐 DEBUG - Request URL: $uri');
    final request = http.MultipartRequest('PATCH', uri);
    final sessionCookie = await _getSessionCookie();
    if (sessionCookie != null && sessionCookie.isNotEmpty) {
      request.headers['Cookie'] = sessionCookie;
    }

    request.fields.addAll(fields);
    if (avatarFile != null) {
      request.files.add(avatarFile);
    }

    final streamed = await client.send(request);
    final response = await http.Response.fromStream(streamed);
    print('📡 DEBUG - Response status: ${response.statusCode}');
    print('📡 DEBUG - Response body: ${response.body}');

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final updatedUser = User.fromJson(body['data']['user']);
      // Update stored user
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user', jsonEncode(updatedUser.toJson()));
      print(
          '📦 DEBUG - Updated auth_user: ${jsonEncode(updatedUser.toJson())}');
      return updatedUser;
    } else {
      final body = json.decode(response.body);
      throw ApiException(body['message'] ?? 'Update failed.');
    }
  }

  Future<void> deleteCurrentUser() async {
    final userId = await getCurrentUserId();
    if (userId == null) throw ApiException('Not logged in.');

    final uri = Uri.parse('$baseUrl/deleteAccount');
    print('🌐 DEBUG - Request URL: $uri');
    final sessionCookie = await _getSessionCookie();
    final Map<String, String> headers = sessionCookie != null && sessionCookie.isNotEmpty
        ? {'Cookie': sessionCookie}
        : <String, String>{};

    final response = await client.delete(uri, headers: headers);
    print('📡 DEBUG - Response status: ${response.statusCode}');
    print('📡 DEBUG - Response body: ${response.body}');

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw ApiException(body['message'] ?? 'Delete failed.');
    }
  }
}
