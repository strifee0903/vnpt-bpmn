class Campaign {
  final int id;
  final String title;
  final String description;
  final String? location;
  final String startDate;
  final String endDate;
  final int? categoryId;

  Campaign({
    required this.id,
    required this.title,
    required this.description,
    this.location,
    required this.startDate,
    required this.endDate,
    this.categoryId,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      categoryId: json['category_id'],
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
