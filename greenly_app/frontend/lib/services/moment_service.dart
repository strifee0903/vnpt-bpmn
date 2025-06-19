import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/moment.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const defaultUrl = 'http://10.0.2.2:3000/api';

class MomentService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? defaultUrl;

  // Static method to get the image base URL (without /api)
  static String get imageBaseUrl {
    final envUrl = dotenv.env['BASE_URL'];
    if (envUrl != null) {
      // Remove /api from the end if present
      return envUrl.replaceAll(RegExp(r'/api/?'), '');
    }
    return 'http://192.168.1.5:3000';
  }

  Future <Moment> createMoment(
    String content,
    String address,
    double latitude,
    double longitude,
    String type,
    int categoryId,
    List<String> mediaUrls,
  ) async {
    final requestUrl = '$baseUrl/moment/new';
    print('🌐 DEBUG - Request URL: $requestUrl');

    final response = await http.post(
      Uri.parse(requestUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'moment_content': content,
        'moment_address': address,
        'latitude': latitude,
        'longitude': longitude,
        'moment_type': type,
        'category_id': categoryId,
        'media_urls': mediaUrls,
        'is_public': true, // Default to public
      }),
    );

    print('📡 DEBUG - Response status: ${response.statusCode}');
    print('📡 DEBUG - Response headers: ${response.headers}');

    if (response.statusCode == 201) {
      print('✅ DEBUG - Moment created successfully');
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return Moment.fromJson(jsonResponse['data']['moment']);
    } else {
      print('❌ DEBUG - Failed to create moment: ${response.statusCode}');
      throw Exception('Failed to create moment: ${response.statusCode}');
    }
  }

  Future<List<Moment>> getNewsFeedMoments() async {
    print('🔧 DEBUG - Environment BASE_URL: ${dotenv.env['BASE_URL']}');
    print('🔧 DEBUG - Service baseUrl: $baseUrl');
    print('🔧 DEBUG - Image baseUrl: $imageBaseUrl');

    final requestUrl = '$baseUrl/moment/public/feed';
    print('🌐 DEBUG - Request URL: $requestUrl');

    final response = await http.get(Uri.parse(requestUrl));

    print('📡 DEBUG - Response status: ${response.statusCode}');
    print('📡 DEBUG - Response headers: ${response.headers}');

    if (response.statusCode == 200) {
      print('✅ DEBUG - Response received successfully');
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('📝 DEBUG - Parsed JSON keys: ${jsonResponse.keys}');

      final List data = jsonResponse['data']['moments'];
      print('📊 DEBUG - Number of moments: ${data.length}');

      // Log first moment's user avatar for debugging
      if (data.isNotEmpty) {
        final firstMoment = data[0];
        print(
            '👤 DEBUG - First moment user avatar: ${firstMoment['user']?['u_avt']}');
      }

      return data.map((item) => Moment.fromJson(item)).toList();
    } else {
      print('❌ DEBUG - Request failed with status: ${response.statusCode}');
      print('❌ DEBUG - Response body: ${response.body}');
      throw Exception('Failed to load moments: ${response.statusCode}');
    }
  }


}


