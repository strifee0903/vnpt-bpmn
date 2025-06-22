import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/moment.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const defaultUrl = 'http://192.168.1.7:3000/api';

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

  static String fullImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return '$imageBaseUrl/public/images/blank_avt.jpg';
    }
    if (relativePath.startsWith('http')) {
      return relativePath;
    }
    return '$imageBaseUrl${relativePath.startsWith('/') ? '' : '/'}$relativePath';
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

  Future<Moment> getMomentById(int momentId) async {
    print('🔧 DEBUG - Environment BASE_URL: ${dotenv.env['BASE_URL']}');
    print('🔧 DEBUG - Service baseUrl: $baseUrl');
    print('🔧 DEBUG - Image baseUrl: $imageBaseUrl');

    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie') ?? '';

    final requestUrl = '$baseUrl/moment/public/$momentId';
    print('🌐 DEBUG - Request URL: $requestUrl');

    final response = await http.get(
      Uri.parse(requestUrl),
      headers: {
        'Cookie': sessionCookie, // Add cookie to get like status
      },
    );

    print('📡 DEBUG - Response status: ${response.statusCode}');
    print('📡 DEBUG - Response headers: ${response.headers}');

    if (response.statusCode == 200) {
      print('✅ DEBUG - Response received successfully');
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('📝 DEBUG - Parsed JSON keys: ${jsonResponse.keys}');

      final momentData = jsonResponse['data']['moment'];
      momentData['media'] ??= []; // Ensure media is always a list
      print(momentData);
      return Moment.fromJson(momentData);
    } else {
      print('❌ DEBUG - Request failed with status: ${response.statusCode}');
      print('❌ DEBUG - Response body: ${response.body}');
      throw Exception('Failed to load moment: ${response.statusCode}');
    }
  }

  Future<List<Moment>> getNewsFeedMoments(
      {int page = 1, int limit = 10, String? moment_type}) async {
    print('🔧 DEBUG - Environment BASE_URL: ${dotenv.env['BASE_URL']}');
    print('🔧 DEBUG - Service baseUrl: $baseUrl');
    print('🔧 DEBUG - Image baseUrl: $imageBaseUrl');

    String requestUrl = '$baseUrl/moment/public/feed?page=$page&limit=$limit';
    if (moment_type != null) {
      requestUrl += '&moment_type=$moment_type';
    }
    print('🌐 DEBUG - Request URL: $requestUrl');

    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie') ?? '';

    final response = await http.get(
      Uri.parse(requestUrl),
      headers: {
        'Cookie': sessionCookie, // Add cookie to get like status
      },
    );

    print('📡 DEBUG - Response status: ${response.statusCode}');
    print('📡 DEBUG - Response headers: ${response.headers}');

    if (response.statusCode == 200) {
      print('✅ DEBUG - Response received successfully');
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('📝 DEBUG - Parsed JSON keys: ${jsonResponse.keys}');

      final List data = jsonResponse['data']['moments'];
      print('📊 DEBUG - Number of moments: ${data.length}');

      // Debug: Print first moment's like data
      if (data.isNotEmpty) {
        print(
            '🔍 DEBUG - First moment like data: likeCount=${data[0]['likeCount']}, isLikedByCurrentUser=${data[0]['isLikedByCurrentUser']}');
      }

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
      {int page = 1,
      int limit = 10,
      bool? is_public,
      String? moment_type}) async {
    print('🔧 DEBUG - Environment BASE_URL: ${dotenv.env['BASE_URL']}');
    print('🔧 DEBUG - Service baseUrl: $baseUrl');
    print('🔧 DEBUG - Image baseUrl: $imageBaseUrl');

    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie') ?? '';

    String url = '$baseUrl/moment/me?page=$page&limit=$limit';
    if (is_public != null) {
      url += '&is_public=$is_public';
    }
    if (moment_type != null) {
      url += '&moment_type=$moment_type';
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

  Future<List<Moment>> getPublicMomentsOfUser({
    required int userId,
    int page = 1,
    int limit = 10,
    String? moment_type, // optional: 'diary', 'event', 'report'
  }) async {
    print('🔧 DEBUG - Environment BASE_URL: ${dotenv.env['BASE_URL']}');
    print('🔧 DEBUG - Service baseUrl: $baseUrl');

    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie') ?? '';

    String url = '$baseUrl/moment/public/user/$userId?page=$page&limit=$limit';
    if (moment_type != null) {
      url += '&moment_type=$moment_type';
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
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List data = jsonResponse['data']['moments'];

      print('✅ DEBUG - Number of moments: ${data.length}');

      return data.map((item) => Moment.fromJson(item)).toList();
    } else {
      print('❌ DEBUG - Failed to load public moments: ${response.body}');
      throw Exception('Failed to load public moments for user $userId');
    }
  }

  Future<Moment> updateMoment({
    required int momentId,
    String? content,
    String? address,
    double? latitude,
    double? longitude,
    String? type,
    int? categoryId,
    bool? isPublic,
    List<File>? images,
    List<int>? mediaIdsToDelete,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie') ?? '';

    final requestUrl = '$baseUrl/moment/me/update/$momentId';
    print('🌐 DEBUG - Request URL: $requestUrl');

    try {
      var request = http.MultipartRequest('PATCH', Uri.parse(requestUrl));
      request.headers['Cookie'] = sessionCookie;
      print('🔐 Cookie header added: $sessionCookie');

      if (content != null) request.fields['moment_content'] = content;
      if (address != null) request.fields['moment_address'] = address;
      if (latitude != null) request.fields['latitude'] = latitude.toString();
      if (longitude != null) request.fields['longitude'] = longitude.toString();
      if (type != null) request.fields['moment_type'] = type.toLowerCase();
      if (categoryId != null)
        request.fields['category_id'] = categoryId.toString();
      if (isPublic != null)
        request.fields['is_public'] = isPublic.toString().toLowerCase();
      if (mediaIdsToDelete != null && mediaIdsToDelete.isNotEmpty) {
        request.fields['media_ids_to_delete'] = jsonEncode(mediaIdsToDelete);
      }

      if (images != null) {
        for (var image in images) {
          request.files.add(await http.MultipartFile.fromPath(
            'images',
            image.path,
            contentType: MediaType('image', 'jpeg'),
          ));
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('📡 DEBUG - Response status: ${response.statusCode}');
      print('📡 DEBUG - Response body: $responseBody');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        final momentData = jsonResponse['data']['moment'];
        momentData['media'] ??= [];
        return Moment.fromJson(momentData);
      } else {
        throw Exception(
            'Failed to update moment: ${jsonDecode(responseBody)['message'] ?? responseBody}');
      }
    } catch (e, stackTrace) {
      print('❌ DEBUG - Error updating moment: $e');
      print('❌ DEBUG - StackTrace: $stackTrace');
      throw Exception('Failed to update moment: $e');
    }
  }

  Future<void> deleteMoment(int momentId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie') ?? '';

    final requestUrl = '$baseUrl/moment/me/delete/$momentId';
    print('🌐 DEBUG - Request URL: $requestUrl');

    try {
      final response = await http.delete(
        Uri.parse(requestUrl),
        headers: {'Cookie': sessionCookie},
      );

      print('📡 DEBUG - Response status: ${response.statusCode}');
      print('📡 DEBUG - Response body: ${response.body}');

      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception(
            'Failed to delete moment: ${jsonDecode(response.body)['message'] ?? response.body}');
      }
    } catch (e, stackTrace) {
      print('❌ DEBUG - Error deleting moment: $e');
      print('❌ DEBUG - StackTrace: $stackTrace');
      throw Exception('Failed to delete moment: $e');
    }
  }

  Future<Map<String, dynamic>> toggleMomentVote({
    required int momentId,
    required bool voteState,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('session_cookie') ?? '';

    final requestUrl = '$baseUrl/vote/moment/$momentId';
    print('🌐 DEBUG - Request URL: $requestUrl');

    try {
      var request = http.MultipartRequest('POST', Uri.parse(requestUrl));
      request.headers['Cookie'] = sessionCookie;
      request.fields['vote_state'] = voteState.toString();

      print('🔐 Cookie header added: $sessionCookie');
      print('❤️❤️❤️ Sending vote_state: $voteState');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('❤️❤️❤️ DEBUG - Response status: ${response.statusCode}');
      print('❤️❤️❤️ DEBUG - Response body: $responseBody');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        final voteData = jsonResponse['data']['vote'];

        return {
          'success': true,
          'isLiked': voteData['vote_state'], // Use the vote_state from response
          'likeCount': voteData['likes'], // Use likes count from response
          'unlikeCount': voteData['unlikes'],
        };
      } else {
        throw Exception(
            '❤️Failed to toggle vote: ${jsonDecode(responseBody)['message'] ?? responseBody}');
      }
    } catch (e, stackTrace) {
      print('❌❤️ DEBUG - Error toggling vote: $e');
      print('❌❤️ DEBUG - StackTrace: $stackTrace');
      throw Exception('❤️Failed to toggle vote: $e');
    }
  }

  Future<Map<String, dynamic>> likeMoment(int momentId) async {
    return await toggleMomentVote(momentId: momentId, voteState: true);
  }

  Future<Map<String, dynamic>> unlikeMoment(int momentId) async {
    return await toggleMomentVote(momentId: momentId, voteState: false);
  }
}
