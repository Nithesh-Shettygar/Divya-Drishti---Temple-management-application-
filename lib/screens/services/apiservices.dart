import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  // For web: Use network IP (localhost won't work in browser)
  // For mobile: Use localhost for emulator/device on same machine
  static String get baseUrl => kIsWeb 
      ? 'http://172.25.2.161:5000'  // Network IP for web
      : 'http://127.0.0.1:5000';    // Localhost for mobile
  
  // API endpoints
  static String get loginUrl => '$baseUrl/login';
  static String get registerUrl => '$baseUrl/register';
  static String get sendOtpUrl => '$baseUrl/send-otp';
  static String get verifyOtpUrl => '$baseUrl/verify-otp';
  
  // Helper method to get full URL
  static String endpoint(String path) {
    // Remove leading slash if present
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$baseUrl/$cleanPath';
  }
}