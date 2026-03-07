class ApiConstants {
  // Use 10.0.2.2 for Android Emulator
  // Use your local IP (e.g., 192.168.1.5) for Real Device
  static const String baseUrl = "http://10.0.2.2:5000/api"; 
  
  static const String matches = "$baseUrl/matches";
  static const String opponents = "$baseUrl/matchmaking/find"; // Existing endpoint
}