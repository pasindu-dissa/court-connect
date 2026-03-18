import '../models/user_model.dart';
import '../models/match_model.dart';
import '../models/booking_model.dart';

class ProfileMockData {
  static UserModel getMockUser() {
    return UserModel(
      id: 'user_001',
      name: 'Alex',
      email: 'alex@courtconnect.com',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      activityStats: ActivityStats(
        matchesPlayed: 12,
        wins: 7,
        losses: 5,
        hoursOnCourt: 18,
        clubRank: 24,
      ),
    );
  }

  static MatchModel getMockUpcomingMatch() {
    return MatchModel(
      id: 'match_001',
      opponentName: 'Jordan Lee',
      dateTime: DateTime.now().add(const Duration(hours: 4)),
      courtName: 'Court 3',
      venue: 'Greenfield Tennis Center',
      imageUrl: 'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=800',
    );
  }

  static List<BookingModel> getMockBookings() {
    final now = DateTime.now();
    return [
      BookingModel(
        id: 'booking_001',
        courtName: 'Court 5',
        courtType: 'Hard',
        dateTime: now.add(const Duration(days: 3, hours: 10)),
        imageUrl: 'https://images.unsplash.com/photo-1622163642998-1ea32b0bbc67?w=400',
      ),
      BookingModel(
        id: 'booking_002',
        courtName: 'Court 2',
        courtType: 'Clay',
        dateTime: now.add(const Duration(days: 5, hours: 14)),
        imageUrl: 'https://images.unsplash.com/photo-1617083199595-2dd395f79ef8?w=400',
      ),
      BookingModel(
        id: 'booking_003',
        courtName: 'Court 1',
        courtType: 'Grass',
        dateTime: now.add(const Duration(days: 7, hours: 17)),
        imageUrl: 'https://images.unsplash.com/photo-1542144582-1ba00456b5e3?w=400',
      ),
    ];
  }
}