// notification_page.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:divya_drishti/core/constants/app_colors.dart';
import 'package:divya_drishti/screens/services/apiservices.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  bool _loading = true;
  bool _refreshing = false;
  String? _errorMessage;
  List<BookingNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _notifications = [];
    });

    try {
      // Get logged-in user info
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        setState(() {
          _loading = false;
          _errorMessage = "User not logged in. Please login again.";
        });
        return;
      }

      // Use the updated backend endpoint with user_id filter
      final uri = Uri.parse('${AppConfig.baseUrl}/notifications?user_id=$userId&limit=50');
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(resp.body);
        final List items = body['notifications'] ?? [];
        final list = items.map((e) {
          try {
            return BookingNotification.fromJson(e as Map<String, dynamic>);
          } catch (err) {
            final map = e as Map<String, dynamic>;
            return BookingNotification(
              notificationId: map['id'] is int
                  ? map['id'] as int
                  : (map['id'] != null ? int.tryParse('${map['id']}') : null),
              bookingId: (map['booking_id'] is int)
                  ? map['booking_id'] as int
                  : (map['booking_id'] != null
                      ? int.tryParse('${map['booking_id']}')
                      : null),
              title: map['title'] ?? 'Booking',
              message: map['message'] ?? '',
              createdAt: map['created_at'] != null
                  ? DateTime.tryParse(map['created_at'])
                  : null,
              isRead: map['is_read'] == true || map['paid'] == true,
            );
          }
        }).toList();

        setState(() {
          _notifications = list;
          _loading = false;
          _refreshing = false;
        });
      } else {
        setState(() {
          _loading = false;
          _errorMessage = "Backend returned ${resp.statusCode}: ${resp.body}";
        });
      }
    } on Exception catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = "Network error: $e\n\n"
            "Suggestions:\n"
            "- Ensure Flask server is running (python app.py).\n"
            "- Current base URL: ${AppConfig.baseUrl}\n"
            "- Check your network connection.";
      });
    }
  }

  Future<void> _clearUserNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      
      if (userId == null) {
        _showSnack("User not logged in");
        return;
      }

      // We'll implement a new endpoint to clear user-specific notifications
      // For now, we'll mark all as read
      for (var notification in _notifications) {
        if (notification.notificationId != null) {
          await _markNotificationRead(notification.notificationId!);
        }
      }
      
      _showSnack("All notifications marked as read");
      await _loadNotifications();
    } catch (e) {
      _showSnack("Error: $e");
    }
  }

  Future<void> _markNotificationRead(int notificationId) async {
    try {
      final uri = Uri.parse(
          '${AppConfig.baseUrl}/notifications/$notificationId/read');
      final resp = await http.put(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        setState(() {
          final idx = _notifications
              .indexWhere((n) => n.notificationId == notificationId);
          if (idx != -1) {
            final n = _notifications[idx];
            _notifications[idx] = BookingNotification(
              notificationId: n.notificationId,
              bookingId: n.bookingId,
              title: n.title,
              message: n.message,
              createdAt: n.createdAt,
              isRead: true,
            );
          }
        });
      }
    } catch (e) {
      // ignore network error on mark-read; it's not critical
    }
  }

  Future<void> _showBookingDetailsDialog(int bookingId,
      {int? notificationId}) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/booking/$bookingId');
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(resp.body);
        final booking = body['booking'];

        if (booking == null) {
          _showSnack("Booking details not found");
          return;
        }

        // Check if this booking belongs to the current user
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt('user_id');
        final bookingUserId = booking['user_id'];
        
        if (userId != null && bookingUserId != null && userId != bookingUserId) {
          _showSnack("You don't have permission to view this booking");
          return;
        }

        if (!mounted) return;

        if (notificationId != null) {
          _markNotificationRead(notificationId);
        }

        showDialog(
          context: context,
          builder: (ctx) {
            final dateStr = booking['booking_date'] ?? booking['date'] ?? '';
            final formattedDate = _formatDateString(dateStr);
            final timeSlot = booking['time_slot'] ?? '';
            final persons = booking['persons']?.toString() ?? '';
            final amount = booking['amount']?.toString() ?? '';
            final paid = booking['paid'] == true;
            final bookingRef =
                booking['payment_ref'] ?? booking['booking_ref'] ?? '';
            final List personsList = booking['person_details'] ?? [];

            // Create structured QR code data in readable format
            final qrData = _createStructuredQRData(
              bookingId: bookingId,
              title: booking['title'] ?? 'Booking',
              bookingRef: bookingRef,
              date: formattedDate,
              timeSlot: timeSlot,
              persons: persons,
              amount: amount,
              paid: paid,
              personsList: personsList,
            );

            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${booking['title'] ?? 'Booking'}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (bookingRef != null &&
                                bookingRef.toString().isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Ref: $bookingRef",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // QR Code Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: QrImageView(
                                data: qrData,
                                version: QrVersions.auto,
                                size: 200.0,
                                backgroundColor: Colors.white,
                                eyeStyle: QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: AppColors.primary,
                                ),
                                dataModuleStyle: QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Scan to view booking details",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Booking Details
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(Icons.calendar_today, "Date",
                                formattedDate),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                                Icons.access_time, "Time", timeSlot),
                            const SizedBox(height: 12),
                            _buildDetailRow(Icons.people, "Persons", persons),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              Icons.payments,
                              "Amount",
                              "₹$amount • ${paid ? 'Paid ✓' : 'Pending'}",
                            ),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 12),
                            const Text(
                              "Person Details:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            ...personsList.map((p) {
                              final name = p['name'] ?? '-';
                              final phone = p['phone'] ?? '-';
                              final elder = (p['is_elder_disabled'] == true ||
                                      p['is_elder_disabled'] == 1)
                                  ? ' (Elder/Disabled)'
                                  : '';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.person,
                                        color: AppColors.primary, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "$name$elder",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            phone,
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Close Button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text(
                              'Close',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      } else {
        _showSnack("Failed to load booking details (${resp.statusCode})");
      }
    } catch (e) {
      _showSnack("Error fetching booking details: $e");
    }
  }

  // Create structured, human-readable QR data
  String _createStructuredQRData({
    required int bookingId,
    required String title,
    required String bookingRef,
    required String date,
    required String timeSlot,
    required String persons,
    required String amount,
    required bool paid,
    required List personsList,
  }) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('    BOOKING CONFIRMATION');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln();
    
    // Booking Information
    buffer.writeln('📋 $title');
    buffer.writeln('Booking ID: $bookingId');
    if (bookingRef.isNotEmpty) {
      buffer.writeln('Reference: $bookingRef');
    }
    buffer.writeln();
    
    // Date & Time
    buffer.writeln('📅 DATE & TIME');
    buffer.writeln('Date: $date');
    buffer.writeln('Time: $timeSlot');
    buffer.writeln();
    
    // Payment Information
    buffer.writeln('💰 PAYMENT DETAILS');
    buffer.writeln('Total Persons: $persons');
    buffer.writeln('Amount: ₹$amount');
    buffer.writeln('Status: ${paid ? "PAID ✓" : "PENDING"}');
    buffer.writeln();
    
    // Person Details
    if (personsList.isNotEmpty) {
      buffer.writeln('👥 VISITOR DETAILS');
      buffer.writeln('─────────────────────────────');
      for (int i = 0; i < personsList.length; i++) {
        final person = personsList[i];
        final name = person['name'] ?? 'N/A';
        final phone = person['phone'] ?? 'N/A';
        final age = person['age'] ?? 'N/A';
        final gender = person['gender'] ?? 'N/A';
        final isElder = (person['is_elder_disabled'] == true || 
                        person['is_elder_disabled'] == 1);
        
        buffer.writeln('${i + 1}. $name');
        buffer.writeln('   Phone: $phone');
        buffer.writeln('   Age: $age | Gender: ${gender[0].toUpperCase()}${gender.substring(1)}');
        if (isElder) {
          buffer.writeln('   ♿ Elder/Disabled');
        }
        if (i < personsList.length - 1) {
          buffer.writeln();
        }
      }
    }
    
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Thank you for your booking!');
    buffer.writeln('Please show this QR at entry');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    return buffer.toString();
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateString(String raw) {
    if (raw.isEmpty) return raw;
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd-MM-yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg), backgroundColor: AppColors.primary));
  }

  Future<void> _onRefresh() async {
    setState(() => _refreshing = true);
    await _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context)),
                  const SizedBox(width: 10),
                  const Text('My Notifications',
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.mark_email_read,
                          color: Colors.white),
                      tooltip: 'Mark all as read',
                      onPressed: _confirmClearAll),
                ],
              ),
            ),
            // Body
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? _errorWidget()
                        : RefreshIndicator(
                            onRefresh: _onRefresh,
                            child: _notifications.isEmpty
                                ? _emptyState()
                                : ListView.separated(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _notifications.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final n = _notifications[index];
                                      return _buildNotificationCard(n);
                                    },
                                  ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[700]),
          const SizedBox(height: 12),
          Text("Error",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700])),
          const SizedBox(height: 8),
          Text(_errorMessage ?? "Unknown error", 
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: _loadNotifications,
            child: const Text("Retry"),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            onPressed: () => Navigator.pop(context),
            child: const Text("Go Back"),
          ),
        ]),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.notifications_off, size: 80, color: Colors.grey[400]),
        const SizedBox(height: 20),
        const Text('No Notifications Yet',
            style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text('Your booking notifications will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: _loadNotifications,
            child: const Text('Refresh')),
        const SizedBox(height: 10),
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go to Home',
                style: TextStyle(color: AppColors.primary))),
      ]),
    );
  }

  Widget _buildNotificationCard(BookingNotification notification) {
    final timeText = _relativeTime(notification.createdAt);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: notification.isRead
          ? Colors.white
          : AppColors.primary.withOpacity(0.05),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (notification.bookingId != null) {
            _showBookingDetailsDialog(notification.bookingId!,
                notificationId: notification.notificationId);
          } else {
            if (notification.notificationId != null) {
              _markNotificationRead(notification.notificationId!);
              _showSnack("Marked as read");
            } else {
              _showSnack("No booking details available");
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon Section
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: notification.isRead 
                      ? Colors.grey.shade200 
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  notification.bookingId != null 
                      ? Icons.event_available 
                      : Icons.notifications,
                  color: notification.isRead ? Colors.grey : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Content Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (notification.bookingId != null)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "ID: ${notification.bookingId}",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          timeText,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const Spacer(),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _relativeTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM yyyy').format(dt);
  }

  void _confirmClearAll() {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Mark All as Read'),
            content: const Text(
                'Are you sure you want to mark all notifications as read?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.grey))),
              TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _clearUserNotifications();
                  },
                  child: const Text('Mark All Read',
                      style: TextStyle(color: AppColors.primary))),
            ],
          );
        });
  }
}

/// BookingNotification model
class BookingNotification {
  final int? notificationId;
  final int? bookingId;
  final String title;
  final String message;
  final DateTime? createdAt;
  final bool isRead;

  BookingNotification({
    this.notificationId,
    required this.bookingId,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  factory BookingNotification.fromJson(Map<String, dynamic> json) {
    DateTime? dt;
    if (json['created_at'] != null) {
      try {
        dt = DateTime.parse(json['created_at'].toString());
      } catch (_) {
        dt = null;
      }
    }

    final int? bookingId = (json['booking_id'] is int)
        ? json['booking_id'] as int
        : (json['booking_id'] != null
            ? int.tryParse('${json['booking_id']}')
            : null);

    final int? notificationId = (json['id'] is int)
        ? json['id'] as int
        : (json['id'] != null ? int.tryParse('${json['id']}') : null);

    final String title = (json['title'] != null &&
            (json['title'] as String).isNotEmpty)
        ? json['title'] as String
        : (json['type'] == 'payment_success'
            ? 'Payment Successful'
            : (json['type'] == 'booking_created'
                ? 'Booking Created'
                : 'Notification'));

    final String message =
        json['message'] != null ? json['message'] as String : '';

    final bool isRead = (json['is_read'] == true) || (json['paid'] == true);

    return BookingNotification(
      notificationId: notificationId,
      bookingId: bookingId,
      title: title,
      message: message,
      createdAt: dt,
      isRead: isRead,
    );
  }
}