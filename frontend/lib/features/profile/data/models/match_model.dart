class MatchModel {
  final String id;
  final String opponentName;
  final DateTime dateTime;
  final String courtName;
  final String venue;
  final String? imageUrl;

  MatchModel({
    required this.id,
    required this.opponentName,
    required this.dateTime,
    required this.courtName,
    required this.venue,
    this.imageUrl,
  });

  String get formattedTime {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return 'Today, $hour:${dateTime.minute.toString().padLeft(2, '0')} $period - $courtName';
  }

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as String,
      opponentName: json['opponentName'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      courtName: json['courtName'] as String,
      venue: json['venue'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}