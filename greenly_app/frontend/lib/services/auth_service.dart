import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../shared/api_exception.dart';

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
      } else {
        final errorJson = json.decode(response.body);
        final message = errorJson['message'] ?? 'Registration failed.';
        throw ApiException(message);
      }
    } catch (error) {
      print('💥 Signup exception: $error');
      throw ApiException("Signup failed: $error");
    }
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
      print('📄 With data: u_email=$email');
      print('📥 Raw response: ${response.body}');
      print(
          '🌐🌐🌐🌐🌐🌐🌐🌐DEBUG - Cookie: ${response.headers['set-cookie']}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['data'] == null ||
            jsonResponse['data']['user'] == null) {
          throw ApiException("Invalid response format: missing user data.");
        }

        final userData = jsonResponse['data']['user'];
        final user = User.fromJson(userData);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_user', jsonEncode(userData));
        await prefs.setString('user_id', user.u_id.toString());

        // ⚠️ Lưu cookie
        final rawCookie = response.headers['set-cookie'];
        if (rawCookie != null) {
          final sessionCookie = rawCookie.split(';').first;
          await prefs.setString('session_cookie', sessionCookie);
          print('🍪 Session cookie saved: $sessionCookie');
        } else {
          print('⚠️ No cookie received from server!');
        }

        // Debug: Verify SharedPreferences
        print('🗄️ SharedPreferences saved:');
        print('🗄️ user_id: ${prefs.getString('user_id')}');
        print('🗄️ auth_user: ${prefs.getString('auth_user')}');
        print('🗄️ session_cookie: ${prefs.getString('session_cookie')}');

        _currentUser = user;
        onAuthChange?.call(user);

        print('✅ Login success! User data: $userData');

        return user;
      } else {
        final errorJson = json.decode(response.body);
        final message = errorJson['message'] ?? 'Login failed.';
        throw ApiException(message);
      }
    } catch (error) {
      print('💥 Login exception: $error');
      throw ApiException("Login failed: $error");
    }
  }
// Future<User> login(String email, String password) async {
//     final uri = Uri.parse('$baseUrl/users/login/');
//     var request = http.MultipartRequest('POST', uri);
//     request.fields['u_email'] = email;
//     request.fields['u_pass'] = password;
//     try {
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);

//       print('📤 Sending login to: ${uri.toString()}');
//       print('📄 With data: u_email=$email');
//       print('📥 Raw response: ${response.body}');
//       print(
//           '🌐🌐🌐🌐🌐🌐🌐🌐DEBUG - Cookie: ${response.headers['set-cookie']}');

//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);

//         if (jsonResponse['data'] == null ||
//             jsonResponse['data']['user'] == null) {
//           throw ApiException("Invalid response format: missing user data.");
//         }

//         final userData = jsonResponse['data']['user'];
//         final user = User.fromJson(userData);

//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('auth_user', jsonEncode(userData));
//         await prefs.setString('user_id', user.u_id.toString());

//         // ⚠️ Lưu cookie
//         final rawCookie = response.headers['set-cookie'];
//         if (rawCookie != null) {
//           final sessionCookie = rawCookie.split(';').first;
//           await prefs.setString('session_cookie', sessionCookie);
//           print('🍪 Session cookie saved: $sessionCookie');
//         } else {
//           print('⚠️ No cookie received from server!');
//         }

//         _currentUser = user;
//         onAuthChange?.call(user);

//         print('✅ Login success! User data: $userData');

//         return user;
//       } else {
//         final errorJson = json.decode(response.body);
//         final message = errorJson['message'] ?? 'Login failed.';
//         throw ApiException(message);
//       }
//     } catch (error) {
//       print('💥 Login exception: $error');
//       throw ApiException("Login failed: $error");
//     }
//   }

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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_user');
    _currentUser = null;
    onAuthChange?.call(null);
    print('👋 Logged out');
  }
}
