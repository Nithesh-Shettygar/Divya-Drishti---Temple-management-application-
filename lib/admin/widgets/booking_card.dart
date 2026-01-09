import 'package:divya_drishti/admin/models/booking_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;
  final VoidCallback onUpdateStatus;
  final VoidCallback onDelete;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onTap,
    required this.onUpdateStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: booking.paid ? Colors.green[50] : Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      booking.paid ? Icons.check_circle : Icons.pending,
                      color: booking.paid ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.bookingRef,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      booking.paid ? 'PAID' : 'PENDING',
                      style: TextStyle(
                        color: booking.paid ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    backgroundColor: booking.paid ? Colors.green : Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoItem(
                    icon: Icons.calendar_today,
                    text: DateFormat('MMM d, yyyy').format(booking.bookingDate),
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    icon: Icons.access_time,
                    text: booking.timeSlot,
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    icon: Icons.people,
                    text: '${booking.persons} persons',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoItem(
                    icon: Icons.attach_money,
                    text: '₹${booking.amount}',
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    icon: Icons.person,
                    text: booking.personDetails.isNotEmpty
                        ? booking.personDetails.first.name ?? 'No name'
                        : 'No persons',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onUpdateStatus,
                      icon: Icon(
                        booking.paid ? Icons.pending : Icons.payment,
                        size: 16,
                      ),
                      label: Text(
                        booking.paid ? 'Mark Pending' : 'Mark Paid',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                      label: const Text(
                        'Delete',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}