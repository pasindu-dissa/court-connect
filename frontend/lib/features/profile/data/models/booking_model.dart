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
    // courtId can be either a populated object or just an ID string
    final court = json['courtId'] is Map 
        ? json['courtId'] as Map<String, dynamic>
        : null;

    return BookingModel(
      id: (json['_id'] ?? '').toString(),
      courtName: court?['name']?.toString() ?? 'Unknown Court',
      courtType: (court?['sports'] is List && 
                 (court!['sports'] as List).isNotEmpty)
          ? court['sports'][0].toString()
          : 'Unknown',
      dateTime: _parseDateTime(
        (json['date'] ?? '').toString(),
        (json['startTime'] ?? '').toString(),
      ),
      imageUrl: (court?['images'] is List && 
                (court!['images'] as List).isNotEmpty)
          ? court['images'][0].toString()
          : null,
    );
  }

  static DateTime _parseDateTime(String date, String startTime) {
    try {
      if (date.isEmpty || startTime.isEmpty) return DateTime.now();
      
      final dateParts = date.split('-');
      if (dateParts.length < 3) return DateTime.now();
      
      final timeParts = startTime.split(' ');
      if (timeParts.length < 2) return DateTime.now();
      
      final hourMin = timeParts[0].split(':');
      if (hourMin.length < 2) return DateTime.now();
      
      int hour = int.tryParse(hourMin[0]) ?? 0;
      final int minute = int.tryParse(hourMin[1]) ?? 0;

      if (timeParts[1] == 'PM' && hour != 12) hour += 12;
      if (timeParts[1] == 'AM' && hour == 12) hour = 0;

      return DateTime(
        int.tryParse(dateParts[0]) ?? 2026,
        int.tryParse(dateParts[1]) ?? 1,
        int.tryParse(dateParts[2]) ?? 1,
        hour,
        minute,
      );
    } catch (e) {
      return DateTime.now();
    }
  }
}