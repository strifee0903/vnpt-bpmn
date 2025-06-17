class Media {
  final int? media_id;
  final int? moment_id;
  final String media_url;

  Media({
    this.media_id,
    this.moment_id,
    required this.media_url,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    print('🎬 DEBUG - Parsing media JSON: $json');

    try {
      final mediaId = json['media_id'];
      final momentId = json['moment_id'];

      print('🎬 DEBUG - media_id value: $mediaId (${mediaId.runtimeType})');
      print('🎬 DEBUG - moment_id value: $momentId (${momentId.runtimeType})');

      return Media(
        media_id: mediaId != null ? _parseIntSafe(mediaId, 'media_id') : null,
        moment_id:
            momentId != null ? _parseIntSafe(momentId, 'moment_id') : null,
        media_url: json['media_url']?.toString() ?? '',
      );
    } catch (e, stackTrace) {
      print('❌ DEBUG - Error parsing Media JSON: $e');
      print('❌ DEBUG - StackTrace: $stackTrace');
      print('❌ DEBUG - JSON data: $json');
      rethrow;
    }
  }

  // Helper method for safe integer parsing
  static int _parseIntSafe(dynamic value, String fieldName) {
    if (value == null) {
      throw FormatException(
          'Field $fieldName is null when parsing was attempted');
    }

    if (value is int) return value;

    if (value is String) {
      if (value.isEmpty) {
        throw FormatException('Field $fieldName is empty string');
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

  Map<String, dynamic> toJson() {
    return {
      'media_id': media_id,
      'moment_id': moment_id,
      'media_url': media_url,
    };
  }
}
