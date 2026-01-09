import 'dart:convert';
import 'package:divya_drishti/core/constants/app_colors.dart';
import 'package:divya_drishti/screens/presentation/screens/home/darshan_booking.dart';
import 'package:divya_drishti/screens/services/apiservices.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserBookingsPage extends StatefulWidget {
  const UserBookingsPage({super.key});

  @override
  State<UserBookingsPage> createState() => _UserBookingsPageState();
}

class _UserBookingsPageState extends State<UserBookingsPage> {
  List<dynamic> _bookings = [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserBookings();
  }

  Future<void> _loadUserBookings() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final userPhone = prefs.getString('user_phone');

      if (userId == null && userPhone == null) {
        setState(() {
          _loading = false;
          _errorMessage = "User not logged in";
        });
        return;
      }

      String apiUrl;
      if (userId != null) {
        apiUrl = '${AppConfig.baseUrl}/bookings/user/$userId';
      } else {
        apiUrl = '${AppConfig.baseUrl}/bookings/user/phone/$userPhone';
      }

      final uri = Uri.parse(apiUrl);
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          _bookings = data['bookings'] ?? [];
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _errorMessage = "Failed to load bookings: ${resp.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = "Error loading bookings: $e";
      });
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: AppColors.primary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 20),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loadUserBookings,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _bookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_note,
                              size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 20),
                          const Text(
                            'No Bookings Yet',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Your bookings will appear here',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            child: const Text('Book Now'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadUserBookings,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _bookings.length,
                        itemBuilder: (context, index) {
                          final booking = _bookings[index];
                          return _buildBookingCard(booking);
                        },
                      ),
                    ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final isPaid = booking['paid'] == true;
    final bookingRef = booking['booking_ref'] ?? '';
    final date = _formatDate(booking['booking_date'] ?? '');
    final timeSlot = booking['time_slot'] ?? '';
    final persons = booking['persons']?.toString() ?? '0';
    final amount = booking['amount']?.toString() ?? '0';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking['title'] ?? 'Booking',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isPaid ? Colors.green[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isPaid ? Colors.green : Colors.orange,
                    ),
                  ),
                  child: Text(
                    isPaid ? 'Paid ✓' : 'Pending',
                    style: TextStyle(
                      color: isPaid ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.calendar_today, 'Date', date),
            _buildDetailRow(Icons.access_time, 'Time', timeSlot),
            _buildDetailRow(Icons.people, 'Persons', persons),
            _buildDetailRow(Icons.payments, 'Amount', '₹$amount'),
            if (bookingRef.isNotEmpty)
              _buildDetailRow(Icons.receipt, 'Reference', bookingRef),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showBookingDetails(booking);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                    ),
                    child: Text(
                      'View Details',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (!isPaid)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _navigateToPayment(booking);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text(
                        'Pay Now',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
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
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    final persons = booking['person_details'] as List? ?? [];
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(booking['title'] ?? 'Booking Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow(Icons.calendar_today, 'Date',
                    _formatDate(booking['booking_date'] ?? '')),
                _buildDetailRow(Icons.access_time, 'Time',
                    booking['time_slot'] ?? ''),
                _buildDetailRow(Icons.people, 'Persons',
                    booking['persons']?.toString() ?? '0'),
                _buildDetailRow(Icons.payments, 'Amount',
                    '₹${booking['amount'] ?? '0'}'),
                _buildDetailRow(Icons.receipt, 'Status',
                    booking['paid'] == true ? 'Paid' : 'Pending'),
                if (booking['booking_ref'] != null)
                  _buildDetailRow(Icons.receipt, 'Reference',
                      booking['booking_ref'] ?? ''),
                
                const SizedBox(height: 16),
                const Text(
                  'Person Details:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...persons.map((person) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person['name'] ?? 'No Name',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text('Phone: ${person['phone'] ?? 'N/A'}'),
                        Text('Age: ${person['age'] ?? 'N/A'}'),
                        Text('Gender: ${person['gender'] ?? 'N/A'}'),
                        if (person['is_elder_disabled'] == true)
                          const Text('Elder/Disabled: Yes'),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToPayment(Map<String, dynamic> booking) {
    // Navigate to payment page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          bookingId: booking['id'],
          title: booking['title'] ?? '',
          date: DateTime.parse(booking['booking_date'] ?? DateTime.now().toString()),
          timeSlot: booking['time_slot'] ?? '',
          persons: booking['persons'] ?? 0,
          personDetails: (booking['person_details'] as List?)?.cast<Map<String, dynamic>>() ?? [],
          amount: booking['amount'] ?? 0,
        ),
      ),
    );
  }
}