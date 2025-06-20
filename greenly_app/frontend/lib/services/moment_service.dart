import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/moment.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const defaultUrl =
    'http://192.168.1.7:3000/api'; 
class MomentService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? defaultUrl;
  static final client = http.Client(); // Persistent client for session cookies

  static String get imageBaseUrl {
    final envUrl = dotenv.env['BASE_URL'];
    if (envUrl != null) {
      return envUrl.replaceAll(RegExp(r'/api/?'), '');
    }
    return 'http://192.168.1.7:3000'; 
  }

  Future<Moment> createMoment({
    required String content,
    required String address,
    required double? latitude,
    required double? longitude,
    required String type,
    required int categoryId,
    required bool isPublic,
    required List<File> images,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie') ?? '';

    final requestUrl = '$baseUrl/moment/new';
    print('🌐 DEBUG - Request URL: $requestUrl');

    try {
      // MultipartRequest (upload ảnh + text)
      var request = http.MultipartRequest('POST', Uri.parse(requestUrl));

      // thêm Cookie vào header
      request.headers['Cookie'] = sessionCookie;
      print('🔐 Cookie header added: $sessionCookie');

      // Thêm các fields text
      request.fields['moment_content'] = content;
      request.fields['moment_address'] = address;
      if (latitude != null) request.fields['latitude'] = latitude.toString();
      if (longitude != null) request.fields['longitude'] = longitude.toString();
      request.fields['moment_type'] = type.toLowerCase();
      request.fields['category_id'] = categoryId.toString();
      request.fields['is_public'] = isPublic.toString().toLowerCase();

      // Thêm các ảnh
      for (var image in images) {
        request.files.add(await http.MultipartFile.fromPath(
          'images',
          image.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      // Gửi request bằng http client
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('📡 DEBUG - Response status: ${response.statusCode}');
      print('📡 DEBUG - Response body: $responseBody');

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody);
        final momentData = jsonResponse['data']['moment'];

        // Chuẩn hóa media
        momentData['media'] ??= [];

        // // Thêm fallback user & category nếu thiếu
        // momentData['user'] ??= {
        //   'u_id': momentData['u_id'] ?? 1,
        //   'u_name': 'Current User',
        //   'u_avt': null,
        // };
        // momentData['category'] ??= {
        //   'category_id': categoryId,
        //   'category_name': 'General',
        // };

        return Moment.fromJson(momentData);
      } else {
        throw Exception(
            'Failed to create moment: ${jsonDecode(responseBody)['message'] ?? responseBody}');
      }
    } catch (e, stackTrace) {
      print('❌ DEBUG - Error creating moment: $e');
      print('❌ DEBUG - StackTrace: $stackTrace');
      throw Exception('Failed to create moment: $e');
    }
  }

  Future<List<Moment>> getNewsFeedMoments(
      {int page = 1, int limit = 10, bool? is_public}) async {
    print('🔧 DEBUG - Environment BASE_URL: ${dotenv.env['BASE_URL']}');
    print('🔧 DEBUG - Service baseUrl: $baseUrl');
    print('🔧 DEBUG - Image baseUrl: $imageBaseUrl');

    final requestUrl = '$baseUrl/moment/public/feed?page=$page&limit=$limit';
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

      // Log metadata for debugging
      final metadata = jsonResponse['data']['metadata'];
      print(
          '📊 DEBUG - Metadata: totalRecords=${metadata['totalRecords']}, page=${metadata['page']}, limit=${metadata['limit']}');

      return data.map((item) => Moment.fromJson(item)).toList();
    } else {
      print('❌ DEBUG - Request failed with status: ${response.statusCode}');
      print('❌ DEBUG - Response body: ${response.body}');
      throw Exception('Failed to load moments: ${response.statusCode}');
    }
  }

  Future<List<Moment>> getMyMoments(
      {int page = 1, int limit = 10, bool? is_public}) async {
    print('🔧 DEBUG - Environment BASE_URL: ${dotenv.env['BASE_URL']}');
    print('🔧 DEBUG - Service baseUrl: $baseUrl');
    print('🔧 DEBUG - Image baseUrl: $imageBaseUrl');

    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie') ?? '';

    String url = '$baseUrl/moment/me?page=$page&limit=$limit';
    if (is_public != null) {
      url += '&is_public=$is_public';
    }

    print('🌐 DEBUG - Request URL: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Cookie': sessionCookie,
      },
    );

    print('🔐 Cookie header added: $sessionCookie');
    print('📡 DEBUG - Response status: ${response.statusCode}');
    print('📡 DEBUG - Response headers: ${response.headers}');

    if (response.statusCode == 200) {
      print('✅ DEBUG - Response received successfully');
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('📝 DEBUG - Parsed JSON keys: ${jsonResponse.keys}');

      final List data = jsonResponse['data']['moments'];
      print('📊 DEBUG - Number of moments: ${data.length}');

      final metadata = jsonResponse['data']['metadata'];
      print(
          '📊 DEBUG - Metadata: totalRecords=${metadata['totalRecords']}, page=${metadata['page']}, limit=${metadata['limit']}');

      return data.map((item) => Moment.fromJson(item)).toList();
    } else {
      print('❌ DEBUG - Request failed with status: ${response.statusCode}');
      print('❌ DEBUG - Response body: ${response.body}');
      throw Exception('Failed to load moments: ${response.statusCode}');
    }
  }
}


