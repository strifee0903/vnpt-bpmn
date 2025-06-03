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
    return User(
      u_id: int.parse(json['u_id'].toString()),
      u_email: json['u_email'].toString(),
      u_name: json['u_name'].toString(),
      role_id: json['role_id'] != null
          ? int.tryParse(json['role_id'].toString())
          : null,
      u_address: json['u_address'].toString(),
      u_birthday: json['u_birthday']?.toString(),
      u_avt: json['u_avt']?.toString(),
      is_verified: json['is_verified'] != null
          ? json['is_verified'].toString() == '1'
          : null,
      last_login: json['last_login']?.toString(),
    );
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
