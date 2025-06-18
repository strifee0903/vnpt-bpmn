import 'category.dart';
import 'media.dart';
import 'user.dart';

class Moment {
  final int id;
  final String content;
  final String address;
  final String type;
  final double? latitude; 
  final double? longitude; 
  final DateTime createdAt;
  final User user;
  final Category category;
  final List<Media> media;

  Moment({
    required this.id,
    required this.content,
    required this.address,
    this.latitude,
    this.longitude,
    required this.type,
    required this.createdAt,
    required this.user,
    required this.category,
    required this.media,
  });

  factory Moment.fromJson(Map<String, dynamic> json) {
    print('📝 DEBUG - Parsing moment JSON keys: ${json.keys}');

    try {
      final momentId = json['moment_id'];
      print('📝 DEBUG - moment_id value: $momentId (${momentId.runtimeType})');

      // Parse created_at safely
      final createdAtStr = json['created_at'];
      print('📝 DEBUG - created_at value: $createdAtStr');

      // Parse user
      final userData = json['user'];
      print('📝 DEBUG - user data: $userData');

      // Parse category
      final categoryData = json['category'];
      print('📝 DEBUG - category data: $categoryData');

      // Parse media array
      final mediaData = json['media'] as List? ?? [];
      print('📝 DEBUG - media data: $mediaData');

      return Moment(
        id: _parseIntSafe(momentId, 'moment_id'),
        content: json['moment_content']?.toString() ?? '',
        address: json['moment_address']?.toString() ?? '',
        latitude: json['latitude']?.toDouble(),
        longitude: json['longitude']?.toDouble(),
        type: json['moment_type']?.toString() ?? '',
        createdAt: DateTime.parse(createdAtStr.toString()),
        user: User.fromJson(userData),
        category: Category.fromJson(categoryData),
        media: mediaData.map((e) => Media.fromJson(e)).toList(),
      );
    } catch (e, stackTrace) {
      print('❌ DEBUG - Error parsing Moment JSON: $e');
      print('❌ DEBUG - StackTrace: $stackTrace');
      print('❌ DEBUG - JSON data: $json');
      rethrow;
    }
  }

  // Helper method for safe integer parsing
  static int _parseIntSafe(dynamic value, String fieldName) {
    if (value == null) {
      throw FormatException('Required field $fieldName is null');
    }

    if (value is int) return value;

    if (value is String) {
      if (value.isEmpty) {
        throw FormatException('Required field $fieldName is empty string');
      }
      return int.parse(value);
    }

    // Try to convert other types to string first
    try {
      return int.parse(value.toString());
    } catch (e) {
      throw FormatException('Cannot parse $fieldName value "$value" to int');
    }
  }
}
