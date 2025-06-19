// moment.dart
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
  final bool? isPublic;

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
    this.isPublic,
  });

  factory Moment.fromJson(Map<String, dynamic> json) {
    print('📝 DEBUG - Parsing moment JSON keys: ${json.keys}');
    try {
      final momentId = json['moment_id'];
      final createdAtStr = json['created_at'] ?? DateTime.now().toString();
      final userData = json['user'] ??
          {
            'u_id': json['u_id'] ?? 1,
            'u_name': 'Anonymous',
            'u_avt': null,
            'u_email': '',
            'u_address': '',
          };
      final categoryData = json['category'] ??
          {
            'category_id': json['category_id'] ?? 1,
            'category_name': 'General',
          };
      final mediaData = (json['media'] as List?) ??
          (json['media_urls'] != null
              ? (json['media_urls'] as List)
                  .map((url) => {'media_url': url, 'moment_id': momentId})
                  .toList()
              : []);

      return Moment(
        id: _parseIntSafe(momentId, 'moment_id'),
        content: json['moment_content']?.toString() ?? '',
        address: json['moment_address']?.toString() ?? '',
        latitude: json['latitude']?.toDouble(),
        longitude: json['longitude']?.toDouble(),
        type: json['moment_type']?.toString() ?? 'diary',
        createdAt: DateTime.parse(createdAtStr),
        user: User.fromJson(userData),
        category: Category.fromJson(categoryData),
        media: mediaData.map((e) => Media.fromJson(e)).toList(),
        isPublic: json['is_public'] != null
            ? (json['is_public'].toString() == 'true' ||
                json['is_public'].toString() == '1' ||
                json['is_public'] == true)
            : true,
      );
    } catch (e, stackTrace) {
      print('❌ DEBUG - Error parsing Moment JSON: $e');
      print('❌ DEBUG - StackTrace: $stackTrace');
      print('❌ DEBUG - JSON data: $json');
      rethrow;
    }
  }

  static int _parseIntSafe(dynamic value, String fieldName) {
    if (value == null) {
      throw FormatException('Required field $fieldName is null');
    }
    if (value is int) return value;
    if (value is String && value.isNotEmpty) return int.parse(value);
    try {
      return int.parse(value.toString());
    } catch (e) {
      throw FormatException('Cannot parse $fieldName value "$value" to int');
    }
  }
}
