import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const defaultUrl = 'http://10.0.2.2:3000/api';

class CategoryService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? defaultUrl;
  

  Future<List<Category>> getAllCategories({int page = 1, int limit = 10}) async {
  final prefs = await SharedPreferences.getInstance();
  final sessionCookie = prefs.getString('session_cookie') ?? '';

  final requestUrl =
      '$baseUrl/category/all?limit=$limit&page=$page';
  print('🌐 DEBUG - Request URL: $requestUrl');

  try {
    final response = await http.get(
      Uri.parse(requestUrl),
      headers: {
        'Cookie': sessionCookie,
      },
    );

    print('📡 DEBUG - Response status: ${response.statusCode}');
    print('📡 DEBUG - Response headers: ${response.headers}');

    if (response.statusCode == 200) {
      print('✅ DEBUG - Categories fetched successfully');
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('📝 DEBUG - Parsed JSON keys: ${jsonResponse.keys}');

      final List data = jsonResponse['data']['categories'];
      print('📊 DEBUG - Number of categories: ${data.length}');

      // Log metadata for debugging
      final metadata = jsonResponse['data']['metadata'];
      print(
          '📊 DEBUG - Metadata: totalRecords=${metadata['totalRecords']}, page=${metadata['page']}, limit=${metadata['limit']}');

      return data.map((item) => Category.fromJson(item)).toList();
    } else {
      print('❌ DEBUG - Failed to fetch categories: ${response.statusCode}');
      print('❌ DEBUG - Response body: ${response.body}');
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  } catch (e, stackTrace) {
    print('❌ DEBUG - Error fetching categories: $e');
    print('❌ DEBUG - StackTrace: $stackTrace');
    throw Exception('Failed to load categories: $e');
  }
}
}
