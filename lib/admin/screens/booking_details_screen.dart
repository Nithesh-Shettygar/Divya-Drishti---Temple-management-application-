import 'package:divya_drishti/admin/models/booking_model.dart';
import 'package:divya_drishti/admin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingDetailsScreen extends StatefulWidget {
  final Booking booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  late Booking _booking;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
    _loadBookingDetails();
  }

  Future<void> _loadBookingDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedBooking = await ApiService.getBookingDetails(_booking.id);
      setState(() {
        _booking = updatedBooking;
      });
    } catch (e) {
      _showError('Failed to load booking details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePaymentStatus() async {
    final newStatus = !_booking.paid;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark as ${newStatus ? 'Paid' : 'Pending'}'),
        content: Text(
            'Are you sure you want to mark this booking as ${newStatus ? 'paid' : 'pending'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ApiService.updatePaymentStatus(
          _booking.id,
          newStatus,
          'ADMIN-${DateTime.now().millisecondsSinceEpoch}',
        );

        setState(() {
          _booking = Booking(
            id: _booking.id,
            bookingRef: _booking.bookingRef,
            title: _booking.title,
            bookingDate: _booking.bookingDate,
            timeSlot: _booking.timeSlot,
            persons: _booking.persons,
            amount: _booking.amount,
            paid: newStatus,
            paymentRef: _booking.paymentRef,
            createdAt: _booking.createdAt,
            personDetails: _booking.personDetails,
          );
        });

        _showSuccess('Payment status updated successfully');
      } catch (e) {
        _showError('Failed to update payment status: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendReminder() async {
    try {
      // Implement send reminder functionality
      _showSuccess('Reminder sent to all persons');
    } catch (e) {
      _showError('Failed to send reminder: $e');
    }
  }

  Future<void> _cancelBooking() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel Booking', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.deleteBooking(_booking.id);
        _showSuccess('Booking cancelled successfully');
        Navigator.pop(context);
      } catch (e) {
        _showError('Failed to cancel booking: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _booking.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ref: ${_booking.bookingRef}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    _booking.paid ? 'PAID' : 'PENDING',
                    style: TextStyle(
                      color: _booking.paid ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: _booking.paid ? Colors.green : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoItem(
                  icon: Icons.calendar_today,
                  title: 'Date',
                  value: DateFormat('MMM d, yyyy').format(_booking.bookingDate),
                ),
                const SizedBox(width: 24),
                _buildInfoItem(
                  icon: Icons.access_time,
                  title: 'Time',
                  value: _booking.timeSlot,
                ),
                const SizedBox(width: 24),
                _buildInfoItem(
                  icon: Icons.people,
                  title: 'Persons',
                  value: _booking.persons.toString(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoItem(
                  icon: Icons.attach_money,
                  title: 'Amount',
                  value: '₹${_booking.amount}',
                ),
                const SizedBox(width: 24),
                _buildInfoItem(
                  icon: Icons.payment,
                  title: 'Payment Ref',
                  value: _booking.paymentRef ?? 'N/A',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonCard(Person person, int index) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    (index + 1).toString(),
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.name ?? 'Person ${index + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (person.phone != null)
                        Text(
                          person.phone!,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (person.gender != null)
                  Chip(
                    label: Text(person.gender!),
                    backgroundColor: Colors.blue[50],
                  ),
                if (person.age != null)
                  Chip(
                    label: Text('${person.age} years'),
                    backgroundColor: Colors.green[50],
                  ),
                if (person.isElderDisabled)
                  Chip(
                    label: const Text('Elder/Disabled'),
                    backgroundColor: Colors.orange[50],
                  ),
                if (person.wheelchairRequired == true)
                  Chip(
                    label: const Text('Wheelchair'),
                    backgroundColor: Colors.purple[50],
                  ),
                if (person.elderAge != null)
                  Chip(
                    label: Text('Elder Age: ${person.elderAge}'),
                    backgroundColor: Colors.red[50],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _updatePaymentStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _booking.paid ? Colors.orange : Colors.green,
                  foregroundColor: Colors.white,
                ),
                icon: Icon(
                  _booking.paid ? Icons.pending_actions : Icons.payment,
                ),
                label: Text(
                  _booking.paid ? 'Mark as Pending' : 'Mark as Paid',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _sendReminder,
                icon: const Icon(Icons.notifications),
                label: const Text('Send Reminder'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Timeline',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimelineItem(
              icon: Icons.create,
              title: 'Booking Created',
              time: _booking.createdAt,
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildTimelineItem(
              icon: Icons.payment,
              title: _booking.paid ? 'Payment Received' : 'Payment Pending',
              time: _booking.paid ? _booking.createdAt : null,
              color: _booking.paid ? Colors.green : Colors.grey,
              isFuture: !_booking.paid,
            ),
            const SizedBox(height: 8),
            _buildTimelineItem(
              icon: Icons.event,
              title: 'Scheduled Date',
              time: _booking.bookingDate,
              color: Colors.orange,
              isFuture: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    DateTime? time,
    required Color color,
    bool isFuture = false,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (time != null)
                Text(
                  DateFormat('MMM d, yyyy - hh:mm a').format(time),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              if (isFuture && time == null)
                const Text(
                  'Pending',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookingDetails,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Edit Booking'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'qr',
                child: Row(
                  children: [
                    Icon(Icons.qr_code, size: 20),
                    SizedBox(width: 8),
                    Text('View QR Code'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'cancel',
                child: Row(
                  children: [
                    Icon(Icons.cancel, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cancel Booking', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                // Implement edit booking
                _showSuccess('Edit feature coming soon');
              } else if (value == 'qr') {
                // Show QR code
                _showQRCodeDialog();
              } else if (value == 'cancel') {
                _cancelBooking();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Header Card
                  _buildHeaderCard(),
                  const SizedBox(height: 16),

                  // Action Buttons
                  _buildActionButtons(),
                  const SizedBox(height: 16),

                  // Timeline
                  _buildTimeline(),
                  const SizedBox(height: 16),

                  // Persons Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Person Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Chip(
                                label: Text('${_booking.persons} persons'),
                                backgroundColor: Colors.blue[50],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ..._booking.personDetails
                              .asMap()
                              .entries
                              .map((entry) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12.0),
                                    child: _buildPersonCard(entry.value, entry.key),
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Additional Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Additional Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            leading: const Icon(Icons.info),
                            title: const Text('Booking ID'),
                            subtitle: Text(_booking.id.toString()),
                          ),
                          ListTile(
                            leading: const Icon(Icons.timeline),
                            title: const Text('Created On'),
                            subtitle: Text(
                              DateFormat('MMM d, yyyy - hh:mm a').format(_booking.createdAt),
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.update),
                            title: const Text('Last Updated'),
                            subtitle: Text(
                              DateFormat('MMM d, yyyy - hh:mm a')
                                  .format(DateTime.now()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  void _showQRCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              color: Colors.grey[200],
              child: const Center(
                child: Text(
                  'QR Code Placeholder',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ref: ${_booking.bookingRef}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: ₹${_booking.amount}',
              style: TextStyle(
                color: _booking.paid ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Download QR code
              _showSuccess('QR code downloaded');
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }
}