class Category {
  final int category_id;
  final String category_name;
  final String? category_image;

  Category({
    required this.category_id,
    required this.category_name,
    this.category_image,
  });
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          category_id == other.category_id;

  @override
  int get hashCode => category_id.hashCode;
  factory Category.fromJson(Map<String, dynamic> json) {
    print('📂 DEBUG - Parsing category JSON: $json');

    try {
      final categoryId = json['category_id'];
      print(
          '📂 DEBUG - category_id value: $categoryId (${categoryId.runtimeType})');

      return Category(
        category_id: _parseIntSafe(categoryId, 'category_id'),
        category_name: json['category_name']?.toString() ?? '',
        category_image: json['category_image']?.toString(),
      );
    } catch (e, stackTrace) {
      print('❌ DEBUG - Error parsing Category JSON: $e');
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

  Map<String, dynamic> toJson() {
    return {
      'category_id': category_id,
      'category_name': category_name,
      'category_image': category_image,
    };
  }
}
