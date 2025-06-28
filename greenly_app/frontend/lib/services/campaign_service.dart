import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/campaign.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const defaultUrl = 'http://192.168.1.7:3000/api';

class CampaignService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? defaultUrl;

  Future<bool> getParticipationStatus(int campaignId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie') ?? '';
      final userId = prefs.getString('user_id');
      print('🗄️ Checking SharedPreferences in getParticipationStatus:');
      print('🗄️ user_id: $userId');
      print('🗄️ session_cookie: $sessionCookie');
      if (userId == null) {
        print('⚠️ User ID not found in SharedPreferences');
        return false;
      }

      final uri = Uri.parse('$baseUrl/campaign/$campaignId/participants');
      print('🌐 Fetching participation status for campaign $campaignId: $uri');
      final response = await http.get(
        uri,
        headers: {
          'Cookie': sessionCookie,
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final participants = jsonData['data']['participants'] ?? [];
        print('👥 Participants list: $participants');
        final isJoined = participants.any((participant) =>
            participant['u_id'].toString() == userId &&
            participant['status'] == 1);
        print('✅ Participation status for campaign $campaignId: $isJoined');
        return isJoined;
      } else {
        print(
            '❌ Error fetching participation status: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error checking participation status: $e');
      return false;
    }
  }

  // Tạo chiến dịch
  Future<int?> createCampaign(Campaign campaign) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie') ?? '';
      final uri = Uri.parse('$baseUrl/campaign/create');
      final request = http.MultipartRequest('POST', uri);

      request.headers['Cookie'] = sessionCookie;
      print('🍪 Session Cookie: $sessionCookie');
      request.fields.addAll(campaign.toJson());

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return jsonData['data']['moment_id'];
      } else {
        print('❌ Tạo thất bại (${response.statusCode}): ${response.body}');
        return null;
      }
    } catch (e) {
      print('⚠️ Lỗi tạo campaign: $e');
      return null;
    }
  }

  // Lấy tất cả campaign
  Future<List<Campaign>> getAllCampaigns({int page = 1, int limit = 10}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie') ?? '';
      final uri = Uri.parse('$baseUrl/campaign/all?page=$page&limit=$limit');
      // final response = await http.get(uri);
      final response = await http.get(
        uri,
        headers: {
          'Cookie': sessionCookie, // Add cookie to get like status
        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List campaignsJson = jsonData['data']['campaigns'] ?? [];
        print('📦 Campaigns fetched: ${campaignsJson.length}');
        for (var item in campaignsJson) {
          print('📦 Raw item: $item');
        }

        return campaignsJson.map((json) => Campaign.fromJson(json)).toList();
      } else {
        print('❌ Lỗi lấy danh sách: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('⚠️ Exception: $e');
      return [];
    }
  }

  // Lấy campaign theo ID
  Future<Campaign?> getCampaignById(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/$id');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Campaign.fromJson(jsonData['data']);
      } else {
        print('❌ Không tìm thấy campaign: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('⚠️ Exception: $e');
      return null;
    }
  }

  // Tham gia / rời chiến dịch
  Future<bool> postAction(int campaignId, String action) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('session_cookie') ?? '';
      final uri = Uri.parse('$baseUrl/campaign/$campaignId/$action');
      final response = await http.post(
        uri,
        headers: {
          'Cookie': sessionCookie,
        },
      );

      if (response.statusCode == 200) {
        print('✅ $action campaign successfully: $campaignId');
        return true;
      } else {
        print('❌ Lỗi khi $action (${response.statusCode}): ${response.body}');
        return false;
      }
    } catch (e) {
      print('⚠️ Lỗi khi $action: $e');
      return false;
    }
  }

  Future<bool> joinCampaign(int id) => postAction(id, 'join');
  Future<bool> leaveCampaign(int id) => postAction(id, 'leave');
}
