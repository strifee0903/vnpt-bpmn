class Vote {
  final int momentId;
  final bool voteState; // true: like, false: dislike
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vote({
    required this.momentId,
    required this.voteState,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      momentId: json['moment_id'],
      voteState: json['vote_state'],
      userId: json['u_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moment_id': momentId,
      'vote_state': voteState,
      'u_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
