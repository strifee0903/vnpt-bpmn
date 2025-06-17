class User {
  final int u_id;
  final String u_email;
  final String u_name;
  final int? role_id;
  final String u_address;
  final String? u_birthday;
  final String? u_avt;
  final bool? is_verified;
  final String? last_login;

  User({
    required this.u_id,
    required this.u_email,
    required this.u_name,
    this.role_id,
    required this.u_address,
    this.u_birthday,
    this.u_avt,
    this.is_verified,
    this.last_login,
  });

  User copyWith({
    int? u_id,
    String? u_email,
    String? u_name,
    int? role_id,
    String? u_address,
    String? u_birthday,
    String? u_avt,
    bool? is_verified,
    String? last_login,
  }) {
    return User(
      u_id: u_id ?? this.u_id,
      u_email: u_email ?? this.u_email,
      u_name: u_name ?? this.u_name,
      role_id: role_id ?? this.role_id,
      u_address: u_address ?? this.u_address,
      u_birthday: u_birthday ?? this.u_birthday,
      u_avt: u_avt ?? this.u_avt,
      is_verified: is_verified ?? this.is_verified,
      last_login: last_login ?? this.last_login,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    print('👤 DEBUG - Parsing user JSON: $json');

    try {
      // Safe parsing for u_id (required field)
      final uId = json['u_id'];
      print('👤 DEBUG - u_id value: $uId (${uId.runtimeType})');

      // Safe parsing for role_id (optional field)
      final roleId = json['role_id'];
      print('👤 DEBUG - role_id value: $roleId (${roleId.runtimeType})');

      return User(
        u_id: _parseIntSafe(uId, 'u_id'),
        u_email: json['u_email']?.toString() ?? '',
        u_name: json['u_name']?.toString() ?? '',
        role_id: roleId != null
            ? _parseIntSafe(roleId, 'role_id', allowNull: true)
            : null,
        u_address: json['u_address']?.toString() ?? '',
        u_birthday: json['u_birthday']?.toString(),
        u_avt: json['u_avt']?.toString(),
        is_verified: json['is_verified'] != null
            ? (json['is_verified'].toString() == '1' ||
                json['is_verified'] == true)
            : null,
        last_login: json['last_login']?.toString(),
      );
    } catch (e, stackTrace) {
      print('❌ DEBUG - Error parsing User JSON: $e');
      print('❌ DEBUG - StackTrace: $stackTrace');
      print('❌ DEBUG - JSON data: $json');
      rethrow;
    }
  }

  // Helper method for safe integer parsing
  static int _parseIntSafe(dynamic value, String fieldName,
      {bool allowNull = false}) {
    if (value == null) {
      if (allowNull) return 0; // or throw error if required
      throw FormatException('Required field $fieldName is null');
    }

    if (value is int) return value;

    if (value is String) {
      if (value.isEmpty && allowNull) return 0;
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
      'u_id': u_id,
      'u_email': u_email,
      'u_name': u_name,
      'role_id': role_id,
      'u_address': u_address,
      'u_birthday': u_birthday,
      'u_avt': u_avt,
      'is_verified': is_verified == true ? 1 : 0,
      'last_login': last_login,
    };
  }
}
