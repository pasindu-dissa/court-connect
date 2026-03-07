class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String bio;
  final String profileImage;
  final String role;
  final String district;
  final String city;
  final String location;
  final List<Skill> skills;
  final Stats stats;
  final String createdAt;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.bio,
    required this.profileImage,
    required this.role,
    required this.district,
    required this.city,
    required this.location,
    required this.skills,
    required this.stats,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return ProfileModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      bio: data['bio'] ?? '',
      profileImage: data['profileImage'] ?? '',
      role: data['role'] ?? 'player',
      district: data['district'] ?? '',
      city: data['city'] ?? '',
      location: data['location'] ?? '',
      skills: (data['skills'] as List<dynamic>?)
              ?.map((s) => Skill.fromJson(s))
              .toList() ??
          [],
      stats: Stats.fromJson(data['stats'] ?? {}),
      createdAt: data['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'bio': bio,
      'district': district,
      'city': city,
      'location': location,
    };
  }

  ProfileModel copyWith({
    String? name,
    String? phone,
    String? bio,
    String? profileImage,
    String? district,
    String? city,
    String? location,
  }) {
    return ProfileModel(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      role: role,
      district: district ?? this.district,
      city: city ?? this.city,
      location: location ?? this.location,
      skills: skills,
      stats: stats,
      createdAt: createdAt,
    );
  }
}

class Skill {
  final String sport;
  final String level;

  Skill({
    required this.sport,
    required this.level,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      sport: json['sport'] ?? '',
      level: json['level'] ?? 'Beginner',
    );
  }
}

class Stats {
  final int matchesPlayed;
  final int wins;
  final int losses;
  final int points;

  Stats({
    required this.matchesPlayed,
    required this.wins,
    required this.losses,
    required this.points,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      matchesPlayed: json['matchesPlayed'] ?? 0,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      points: json['points'] ?? 0,
    );
  }

  String get winLossRatio => '${wins}W/${losses}L';
}