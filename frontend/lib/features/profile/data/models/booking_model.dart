class BookingModel {
  final String id;
  final String courtName;
  final String courtType;
  final DateTime dateTime;
  final String? imageUrl;

  BookingModel({
    required this.id,
    required this.courtName,
    required this.courtType,
    required this.dateTime,
    this.imageUrl,
  });

  String get formattedDate {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final day = days[dateTime.weekday - 1];
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$day, ${dateTime.day}th - $hour $period';
  }

  String get courtInfo => '$courtName - $courtType';

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      courtName: json['courtName'] as String,
      courtType: json['courtType'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      imageUrl: json['imageUrl'] as String?,
    );
  }
}