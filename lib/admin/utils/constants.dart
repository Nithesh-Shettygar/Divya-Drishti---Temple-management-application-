import 'dart:ui';

import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Divya Drishti Admin';
  static const String version = '1.0.0';
  
  // API Endpoints
  static const String baseUrl = 'http://localhost:5000';
  
  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF1976D2);
  static const Color accentColor = Color(0xFF03A9F4);
  
  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  
  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black54,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );
  
  static final TextStyle captionStyle = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );
  
  // Spacing
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;
  static const double cardRadius = 12.0;
  
  // Timeouts
  static const int apiTimeout = 30; // seconds
  static const int connectTimeout = 10; // seconds
  
  // Pagination
  static const int itemsPerPage = 20;
  
  // Local Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';
  
  // Notification Types
  static const List<String> notificationTypes = [
    'general',
    'booking_created',
    'payment_success',
    'booking_updated',
    'booking_cancelled',
  ];
  
  // Booking Status
  static const List<String> bookingStatuses = [
    'pending',
    'paid',
    'confirmed',
    'cancelled',
    'completed',
  ];
  
  // Time Slots
  static const List<String> timeSlots = [
    '09:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '12:00 PM - 01:00 PM',
    '02:00 PM - 03:00 PM',
    '03:00 PM - 04:00 PM',
    '04:00 PM - 05:00 PM',
  ];
}

class AppImages {
  static const String logo = 'assets/images/logo.png';
  static const String placeholder = 'assets/images/placeholder.png';
  static const String avatar = 'assets/images/avatar.png';
}

class AppIcons {
  static const String dashboard = 'assets/icons/dashboard.svg';
  static const String users = 'assets/icons/users.svg';
  static const String bookings = 'assets/icons/bookings.svg';
  static const String notifications = 'assets/icons/notifications.svg';
  static const String statistics = 'assets/icons/statistics.svg';
  static const String settings = 'assets/icons/settings.svg';
}