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
  final int likeCount;
  final int unlikeCount;
  final bool isLikedByCurrentUser;

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
    required this.likeCount,
    required this.unlikeCount,
    required this.isLikedByCurrentUser,
  });

  factory Moment.fromJson(Map<String, dynamic> json) {
    print('📝 DEBUG - Parsing moment JSON keys: ${json.keys}');
    try {
      final momentId = json['moment_id'];
      final createdAtStr = json['created_at'] ?? DateTime.now().toString();
      final createdAt =
          DateTime.parse(createdAtStr).toUtc().add(const Duration(hours: 7));

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
        createdAt: createdAt,
        user: User.fromJson(userData),
        category: Category.fromJson(categoryData),
        media: mediaData.map((e) => Media.fromJson(e)).toList(),
        isPublic: json['is_public'] != null
            ? (json['is_public'].toString() == 'true' ||
                json['is_public'].toString() == '1' ||
                json['is_public'] == true)
            : true,
        // Fixed: Parse both possible field names for likes
        likeCount: json['likeCount'] ?? json['likes'] ?? 0,
        unlikeCount: json['unlikeCount'] ?? json['unlikes'] ?? 0,
        // Fixed: Parse both possible field names for like status
        isLikedByCurrentUser:
            json['isLikedByCurrentUser'] ?? json['is_liked'] ?? false,
      );
    } catch (e, stackTrace) {
      print('❌ DEBUG - Error parsing Moment JSON: $e');
      print('❌ DEBUG - StackTrace: $stackTrace');
      print('❌ DEBUG - JSON data: $json');
      rethrow;
    }
  }

  Moment copyWith({
    int? id,
    String? content,
    String? address,
    String? type,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    User? user,
    Category? category,
    List<Media>? media,
    bool? isPublic,
    int? likeCount,
    int? unlikeCount,
    bool? isLikedByCurrentUser,
  }) {
    return Moment(
      id: id ?? this.id,
      content: content ?? this.content,
      address: address ?? this.address,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
      category: category ?? this.category,
      media: media ?? this.media,
      isPublic: isPublic ?? this.isPublic,
      likeCount: likeCount ?? this.likeCount,
      unlikeCount: unlikeCount ?? this.unlikeCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moment_id': id,
      'moment_content': content,
      'moment_address': address,
      'latitude': latitude,
      'longitude': longitude,
      'moment_type': type,
      'created_at': createdAt.toIso8601String(),
      'user': user.toJson(),
      'category': category.toJson(),
      'media': media.map((m) => m.toJson()).toList(),
      'is_public': isPublic,
      'likeCount': likeCount,
      'unlikeCount': unlikeCount,
      'isLikedByCurrentUser': isLikedByCurrentUser,
    };
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
