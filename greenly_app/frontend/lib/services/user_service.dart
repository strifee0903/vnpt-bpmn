import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../shared/api_exception.dart';

const userUrl = 'http://10.0.2.2:3000/api/users';

class UserService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? userUrl;

  // Load user from local storage
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('auth_user');
    if (userJson == null) return null;
    final userMap = jsonDecode(userJson);
    return User.fromJson(userMap);
  }

  // Get u_id from local store (shortcut)
  Future<int?> getCurrentUserId() async {
    final user = await getCurrentUser();
    return user?.u_id;
  }

  // Get your own user profile
  Future<User> getMyProfile() async {
    final uri = Uri.parse('$baseUrl/info/');
    final response = await http.get(uri);
    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      final userJson = body['data']['data'];
      return User.fromJson(userJson);
    } else {
      throw ApiException(body['message'] ?? 'Failed to fetch profile.');
    }
  }

  // Get user by ID (used for viewing others)
  Future<User> getUserById(int userId) async {
    final uri = Uri.parse('$baseUrl/$userId');
    final response = await http.get(uri);
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

    final uri = Uri.parse('$baseUrl/update/$userId');
    final request = http.MultipartRequest('PATCH', uri);

    request.fields.addAll(fields);
    if (avatarFile != null) {
      request.files.add(avatarFile);
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      final updatedUser = User.fromJson(body['data']['user']);

      // Update stored user
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user', jsonEncode(updatedUser.toJson()));

      return updatedUser;
    } else {
      throw ApiException(body['message'] ?? 'Update failed.');
    }
  }

  Future<void> deleteCurrentUser() async {
    final userId = await getCurrentUserId();
    if (userId == null) throw ApiException('Not logged in.');

    final uri = Uri.parse('$baseUrl/delete/$userId');
    final response = await http.delete(uri);

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw ApiException(body['message'] ?? 'Delete failed.');
    }
  }
}
