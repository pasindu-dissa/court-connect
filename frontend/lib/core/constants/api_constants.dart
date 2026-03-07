class ApiConstants {
  // Use 10.0.2.2 for Android Emulator
  // Use your local IP (e.g., 192.168.1.5) for Real Device
<<<<<<< HEAD
  static const String baseUrl = "http://10.0.2.2:5005/api";
  static const String matches = "$baseUrl/matches";
  static const String opponents =
      "$baseUrl/matchmaking/find"; // Existing endpoint
  static const String leaderboard = "$baseUrl/leaderboard";
=======
  static const String baseUrl = "http://10.0.2.2:5000/api";

  static const String matches = "$baseUrl/matches";
  static const String opponents =
      "$baseUrl/matchmaking/find"; // Existing endpoint
>>>>>>> 57a9c36c7b9f1ee73f7ab25ce6d5b1947db65410
}
