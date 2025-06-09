import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

const user_url = 'http://10.0.2.2:3000/api/users';

class AuthService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? user_url;

  Future<http.Response> getUserProfile() async {
    final uri = Uri.parse('$baseUrl/users/profile/');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load user profile: ${response.body}');
    }

    return response;
  }

  Future<http.Response> registerUser({
    required String uName,
    required String uEmail,
    required String uPass,
    required String uAddress,
    required String uBirthday,
  }) async {
    final uri = Uri.parse('$baseUrl/users/registration/');
    var request = http.MultipartRequest('POST', uri);

    request.fields['u_name'] = uName;
    request.fields['u_email'] = uEmail;
    request.fields['u_pass'] = uPass;
    request.fields['u_address'] = uAddress;
    request.fields['u_birthday'] = uBirthday;

    print('😵‍💫😵‍💫😵‍💫Sending to: ${uri.toString()}');
    print('😵‍💫😵‍💫😵‍💫With data: ${request.fields}');

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 400 || response.statusCode == 500) {
      throw Exception(
          '😡😡😡 Register failed (${response.statusCode}): $responseBody');
    }

    return http.Response(responseBody, response.statusCode);
  }

  Future<http.Response> login({
    required String uEmail,
    required String uPass,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/users/login/');
      var request = http.MultipartRequest('POST', uri);

      request.fields['u_email'] = uEmail;
      request.fields['u_pass'] = uPass;

      print('😵‍💫😵‍💫😵‍💫Sending to: ${uri.toString()}');
      print('😵‍💫😵‍💫😵‍💫With data: ${request.fields}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('😎😎😎Received: ${response.statusCode}');
      print('😎😎😎Response: $responseBody');

      if (response.statusCode != 200) {
        throw Exception(
            '😡😡😡Login failed (${response.statusCode}): $responseBody');
      }

      return http.Response(responseBody, response.statusCode);
    } catch (e) {
      print('😵‍💫😵‍💫😵‍💫Login error: $e');
      rethrow;
    }
  }

  Future<http.Response> logout() async {
    final uri = Uri.parse('$baseUrl/logout/');
    final response = await http.post(uri);

    if (response.statusCode != 200) {
      throw Exception('Logout failed: ${response.body}');
    }

    return response;
  }
}
