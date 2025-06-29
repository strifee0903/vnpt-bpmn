import 'dart:convert';
import 'package:greenly_app/models/process.dart' as model;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

const process_url = 'http://192.168.1.5:3000/api';

class ProcessService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? process_url;

  // Lấy thông tin chi tiết của một quy trình dựa trên processId
  Future<http.Response> getProcessDetails(String processId) async {
    final uri = Uri.parse(
        '$baseUrl/processes/$processId'); // Sửa endpoint để lấy theo processId
    print('😵‍💫😵‍💫😵‍💫Fetching process details from: ${uri.toString()}');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load process details: ${response.body}');
    }

    return response;
  }

  // Lấy danh sách tất cả các quy trình (sử dụng /api/v1/bpmn/all)
  Future<http.Response> getAllProcesses() async {
    final uri = Uri.parse(
        '$baseUrl/v1/bpmn/all'); // Sửa endpoint thành /api/v1/bpmn/all
    print('😵‍💫😵‍💫😵‍💫Fetching all processes from: ${uri.toString()}');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load processes list: ${response.body}');
    }

    return response;
  }

  // Tạo một quy trình mới
  Future<http.Response> createProcess({
    required String processId,
    required String name,
  }) async {
    final uri = Uri.parse('$baseUrl/processes/');
    var request = http.MultipartRequest('POST', uri);

    request.fields['process_id'] = processId;
    request.fields['name'] = name;

    print('😵‍💫😵‍💫😵‍💫Sending to: ${uri.toString()}');
    print('😵‍💫😵‍💫😵‍💫With data: ${request.fields}');

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 400 || response.statusCode == 500) {
      throw Exception(
          '😡😡😡 Process creation failed (${response.statusCode}): $responseBody');
    }

    return http.Response(responseBody, response.statusCode);
  }

  // Cập nhật thông tin của một quy trình
  Future<http.Response> updateProcess({
    required String processId,
    String? name,
  }) async {
    final uri = Uri.parse('$baseUrl/processes/$processId');
    var request = http.MultipartRequest('PUT', uri);

    if (name != null) request.fields['name'] = name;

    print('😵‍💫😵‍💫😵‍💫Sending to: ${uri.toString()}');
    print('😵‍💫😵‍💫😵‍💫With data: ${request.fields}');

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 400 || response.statusCode == 500) {
      throw Exception(
          '😡😡😡 Process update failed (${response.statusCode}): $responseBody');
    }

    return http.Response(responseBody, response.statusCode);
  }

  // Xóa một quy trình
  Future<http.Response> deleteProcess(String processId) async {
    final uri = Uri.parse('$baseUrl/processes/$processId');
    final response = await http.delete(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete process: ${response.body}');
    }

    return response;
  }

  Future<(List<model.Step>, List<model.Flow>)> fetchProcess(
      String processId) async {
    try {
      final uri = Uri.parse(
          '$baseUrl/v1/bpmn/details/$processId'); // Sửa endpoint để lấy theo processId
      print('😵‍💫😵‍💫😵‍💫Fetching process details from: ${uri.toString()}');
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to load process details: ${response.body}');
      }
      print('😵‍💫😵‍💫😵‍💫Response received successfully: ${response.body}');

      final Map<String, dynamic> jsonResponse =
          jsonDecode(response.body)['data'];

      final data = jsonResponse;
      final steps =
          (data['steps'] as List).map((e) => model.Step.fromJson(e)).toList();
      final flows =
          (data['flows'] as List).map((e) => model.Flow.fromJson(e)).toList();
      return (steps, flows);
    } catch (e) {
      print('Error fetching process: $e');
      return (<model.Step>[], <model.Flow>[]);
    }
  }

  Future<List<model.Process>> fetchAllDynamicProcesses() async {
    try {
      final uri = Uri.parse('$baseUrl/v1/bpmn/all?type=dynamic');
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to load dynamic processes: ${response.body}');
      }

      final List<dynamic> jsonList = jsonDecode(response.body)['data'];
      return jsonList.map((e) => model.Process.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching dynamic processes: $e');
      return [];
    }
  }
}
