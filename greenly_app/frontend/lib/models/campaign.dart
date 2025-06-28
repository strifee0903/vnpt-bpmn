import 'user.dart';

class Campaign {
  final int id;
  final String title;
  final String description;
  final String? location;
  final String startDate;
  final String endDate;
  final int? categoryId;
  final User? user;
  
  Campaign({
    required this.id,
    required this.title,
    required this.description,
    this.location,
    required this.startDate,
    required this.endDate,
    this.categoryId,
    this.user,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ??
        {
          'u_id': json['u_id'] ?? 1,
          'u_name': 'Anonymous',
          'u_avt': null,
          'u_email': '',
          'u_address': '',
        };
    return Campaign(
      id: json['campaign_id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      categoryId: json['category_id'],
      user: User.fromJson(userData),
    );
  }

  Map<String, String> toJson() {
    return {
      'title': title,
      'description': description,
      'location': location ?? '',
      'start_date': startDate,
      'end_date': endDate,
      'category_id': categoryId?.toString() ?? '49',
      
    };
  }
}
