// notification_page.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:divya_drishti/core/constants/app_colors.dart';
import 'package:divya_drishti/screens/services/apiservices.dart'; // Import AppConfig
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
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
      // Use AppConfig.baseUrl to build the URL
      final uri = Uri.parse('${AppConfig.baseUrl}/notifications?limit=50');
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      
      if (resp.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(resp.body);
        final List<dynamic> items = body['notifications'] ?? [];
        final list = items.map((e) {
          try {
            return BookingNotification.fromJson(e as Map<String, dynamic>);
          } catch (err) {
            // fallback safe parse
            final map = e as Map<String, dynamic>;
            return BookingNotification(
              notificationId: map['id'] is int ? map['id'] as int : (map['id'] != null ? int.tryParse('${map['id']}') : null),
              bookingId: (map['booking_id'] is int) ? map['booking_id'] as int : (map['booking_id'] != null ? int.tryParse('${map['booking_id']}') : null),
              title: map['title'] ?? 'Booking',
              message: map['message'] ?? '',
              createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
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

  Future<void> _clearAllNotifications() async {
    // Developer endpoint to clear bookings. Remove/change for production.
    final uri = Uri.parse('${AppConfig.baseUrl}/dev/clear-bookings');
    try {
      final resp = await http.post(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        _showSnack("All notifications cleared");
        await _loadNotifications();
      } else {
        _showSnack("Failed to clear notifications (${resp.statusCode})");
      }
    } catch (e) {
      _showSnack("Error clearing notifications: $e");
    }
  }

  Future<void> _markNotificationRead(int? notificationId) async {
    if (notificationId == null) return;
    final uri = Uri.parse('${AppConfig.baseUrl}/notifications/$notificationId/read');
    try {
      final resp = await http.put(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        // optimistically update local state
        setState(() {
          final idx = _notifications.indexWhere((n) => n.notificationId == notificationId);
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
      } else {
        // ignore non-200 for now
      }
    } catch (e) {
      // ignore network error on mark-read; it's not critical
    }
  }

  Future<void> _showBookingDetailsDialog(int bookingId, {int? notificationId}) async {
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
        if (!mounted) return;

        // mark notification read (if provided)
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
            final bookingRef = booking['payment_ref'] ?? booking['booking_ref'] ?? '';
            final List<dynamic> personsList = booking['person_details'] ?? [];

            return AlertDialog(
              title: Row(
                children: [
                  Expanded(child: Text("${booking['title'] ?? 'Booking'}")),
                  if (bookingRef != null && bookingRef.toString().isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text("Ref: $bookingRef", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Date: $formattedDate"),
                    const SizedBox(height: 6),
                    Text("Time: $timeSlot"),
                    const SizedBox(height: 6),
                    Text("Persons: $persons"),
                    const SizedBox(height: 6),
                    Text("Amount: ₹$amount  •  ${paid ? 'Paid' : 'Pending'}"),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text("Person Details:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...personsList.map((p) {
                      final name = p['name'] ?? '-';
                      final phone = p['phone'] ?? '-';
                      final elder = (p['is_elder_disabled'] == true || p['is_elder_disabled'] == 1) ? ' (Elder/Disabled)' : '';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text("• $name — $phone$elder"),
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Close', style: TextStyle(color: AppColors.primary))),
              ],
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.primary));
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
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  const SizedBox(width: 10),
                  const Text('Notifications', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.white), onPressed: _confirmClearAll),
                ],
              ),
            ),

            // Body
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? _errorWidget()
                        : RefreshIndicator(
                            onRefresh: _onRefresh,
                            child: _notifications.isEmpty ? _emptyState() : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _notifications.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
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
          Text("Error", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[700])),
          const SizedBox(height: 8),
          Text(_errorMessage ?? "Unknown error", textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: _loadNotifications,
            child: const Text("Retry"),
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
        const Text('No Notifications', style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        const Text('You\'re all caught up!', style: TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 24),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), onPressed: _loadNotifications, child: const Text('Reload'))
      ]),
    );
  }

  Widget _buildNotificationCard(BookingNotification notification) {
    final timeText = _relativeTime(notification.createdAt);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: notification.isRead ? Colors.white : AppColors.primary.withOpacity(0.05),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(25)), child: Icon(Icons.event_available, color: AppColors.primary, size: 24)),
        title: Row(children: [
          Expanded(child: Text(notification.title, style: TextStyle(fontSize: 16, fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold, color: Colors.black87))),
          if (notification.bookingId != null)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
              child: Text("ID: ${notification.bookingId}", style: const TextStyle(fontSize: 12, color: Colors.black54)),
            )
        ]),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 4),
          Text(notification.message, style: TextStyle(fontSize: 14, color: Colors.grey[700]), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Text(timeText, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ]),
        trailing: !notification.isRead ? Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)) : null,
        onTap: () {
          if (notification.bookingId != null) {
            _showBookingDetailsDialog(notification.bookingId!, notificationId: notification.notificationId);
          } else {
            // If no booking id, still attempt to mark notification read if we have id
            if (notification.notificationId != null) {
              _markNotificationRead(notification.notificationId);
              _showSnack("Marked as read");
            } else {
              _showSnack("No booking details available");
            }
          }
        },
      ),
    );
  }

  String _relativeTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minute(s) ago';
    if (diff.inHours < 24) return '${diff.inHours} hour(s) ago';
    if (diff.inDays < 7) return '${diff.inDays} day(s) ago';
    return DateFormat('dd-MM-yyyy').format(dt);
  }

  void _confirmClearAll() {
    showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () { Navigator.pop(ctx); _clearAllNotifications(); }, child: const Text('Clear All', style: TextStyle(color: Colors.red))),
        ],
      );
    });
  }
}

/// BookingNotification model now contains notificationId (notifications.id)
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
        // MySQL sometimes returns 'YYYY-MM-DD HH:MM:SS' which DateTime.parse handles; fallback is null
        dt = null;
      }
    }

    // Prefer booking_id column for the booking reference
    final int? bookingId = (json['booking_id'] is int)
        ? json['booking_id'] as int
        : (json['booking_id'] != null ? int.tryParse('${json['booking_id']}') : null);

    final int? notificationId = (json['id'] is int) ? json['id'] as int : (json['id'] != null ? int.tryParse('${json['id']}') : null);

    final String title = (json['title'] != null && (json['title'] as String).isNotEmpty)
        ? json['title'] as String
        : (json['type'] == 'payment_success' ? 'Payment Successful' : 'Notification');

    final String message = json['message'] != null ? json['message'] as String : '';

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