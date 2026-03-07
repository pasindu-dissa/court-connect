class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final ActivityStats activityStats;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.activityStats,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      activityStats: ActivityStats.fromJson(
        json['activityStats'] as Map<String, dynamic>,
      ),
    );
  }
}

class ActivityStats {
  final int matchesPlayed;
  final int wins;
  final int losses;
  final int hoursOnCourt;
  final int clubRank;

  ActivityStats({
    required this.matchesPlayed,
    required this.wins,
    required this.losses,
    required this.hoursOnCourt,
    required this.clubRank,
  });

  String get winLossRatio => '${wins}W/${losses}L';

  factory ActivityStats.fromJson(Map<String, dynamic> json) {
    return ActivityStats(
      matchesPlayed: json['matchesPlayed'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      hoursOnCourt: json['hoursOnCourt'] as int? ?? 0,
      clubRank: json['clubRank'] as int? ?? 0,
    );
  }
}