import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:greenly_app/models/library.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const defaultUrl = 'http://192.168.1.7:3000/api';

class LibraryService {
  static final String baseUrl =
      dotenv.env['BASE_URL'] ?? defaultUrl; // 🔁 thay đổi nếu cần

  Future<List<LibraryDocument>> fetchAllDocuments() async {
    final uri = Uri.parse('$baseUrl/v1/library/content/all_content');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'] as List;

        return data.map((json) => LibraryDocument.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi khi lấy danh sách tài liệu: ${response.body}');
      }
    } catch (e) {
      print('❌ Lỗi fetchAllDocuments: $e');
      return [];
    }
  }

  Future<LibraryDocument?> fetchDocumentById(String id) async {
    final uri = Uri.parse('$baseUrl/v1/library/content/$id');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];
        return LibraryDocument.fromJson(data);
      } else {
        throw Exception('Lỗi khi lấy chi tiết tài liệu: ${response.body}');
      }
    } catch (e) {
      print('❌ Lỗi fetchDocumentById: $e');
      return null;
    }
  }
}
