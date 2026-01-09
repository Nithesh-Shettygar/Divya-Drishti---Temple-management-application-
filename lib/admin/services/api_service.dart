import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/booking_model.dart';
import '../models/notification_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000';
  // Use your server IP for real device: 'http://192.168.x.x:5000'

  // Helper method for making requests
  static Future<Map<String, dynamic>> _makeRequest(
    String endpoint,
    String method, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = {'Content-Type': 'application/json'};

      http.Response response;

      switch (method) {
        case 'GET':
          response = await http.get(url, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        default:
          throw Exception('Invalid HTTP method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to load data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Admin authentication (using existing user login)
  static Future<Map<String, dynamic>> adminLogin(
      String phone, String password) async {
    return await _makeRequest('/login', 'POST', body: {
      'phone': phone,
      'password': password,
    });
  }

  // Get all users
  static Future<List<User>> getAllUsers() async {
    final response = await _makeRequest('/dev/users', 'GET');
    final List<dynamic> usersJson = response['users'];
    return usersJson.map((json) => User.fromJson(json)).toList();
  }

  // Get all bookings
  static Future<List<Booking>> getAllBookings() async {
    final response = await _makeRequest('/history', 'GET');
    final List<dynamic> bookingsJson = response['history'];
    return bookingsJson.map((json) => Booking.fromJson(json)).toList();
  }

  // Get user-specific bookings
  static Future<List<Booking>> getUserBookings(String phone) async {
    final response = await _makeRequest('/history/user?phone=$phone', 'GET');
    final List<dynamic> bookingsJson = response['history'];
    return bookingsJson.map((json) => Booking.fromJson(json)).toList();
  }

  // Get notifications
  // static Future<List<Notification>> getNotifications() async {
  //   final response = await _makeRequest('/notifications?limit=100', 'GET');
  //   final List<dynamic> notificationsJson = response['notifications'];
  //   return notificationsJson.map((json) => Notification.fromJson(json)).toList();
  // }

  // Mark notification as read
  static Future<void> markNotificationAsRead(int notificationId) async {
    await _makeRequest('/notifications/$notificationId/read', 'PUT');
  }

  // Get booking details
  static Future<Booking> getBookingDetails(int bookingId) async {
    final response = await _makeRequest('/booking/$bookingId', 'GET');
    return Booking.fromJson(response['booking']);
  }

  // Update booking payment status
  static Future<void> updatePaymentStatus(
      int bookingId, bool paid, String paymentRef) async {
    await _makeRequest('/payment', 'POST', body: {
      'booking_id': bookingId,
      'amount': 0, // You might want to fetch actual amount first
      'payment_ref': paymentRef,
    });
  }

  // Delete booking
  static Future<void> deleteBooking(int bookingId) async {
    await _makeRequest('/booking/$bookingId', 'DELETE');
  }

  // Get slots availability
  static Future<List<Map<String, dynamic>>> getSlots(
      String startDate, int days) async {
    final response =
        await _makeRequest('/slots?start=$startDate&days=$days', 'GET');
    return List<Map<String, dynamic>>.from(response['slots']);
  }

  // Get bookings count by date
  static Future<Map<String, dynamic>> getBookingsCount(String date) async {
    return await _makeRequest('/stats/bookings-count?date=$date', 'GET');
  }

  // Clear all bookings (dev only)
  static Future<void> clearAllBookings() async {
    await _makeRequest('/dev/clear-bookings', 'POST');
  }

  // Send OTP (for admin verification)
  static Future<void> sendOTP(String phone) async {
    await _makeRequest('/send-otp', 'POST', body: {'phone': phone});
  }

  // Verify OTP
  static Future<void> verifyOTP(String phone, String otp) async {
    await _makeRequest('/verify-otp', 'POST', body: {
      'phone': phone,
      'otp': otp,
    });
  }

  // Update user profile
  static Future<void> updateUserProfile(
      String phone, String name, String dob, String gender, String address) async {
    await _makeRequest('/profile', 'PUT', body: {
      'phone': phone,
      'name': name,
      'dob': dob,
      'gender': gender,
      'address': address,
    });
  }

  // Reset user password
  static Future<void> resetUserPassword(String phone, String newPassword) async {
    await _makeRequest('/reset-password', 'POST', body: {
      'phone': phone,
      'new_password': newPassword,
    });
  }
}