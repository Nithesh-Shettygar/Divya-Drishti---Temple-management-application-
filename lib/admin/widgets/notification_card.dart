// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:divya_drishti_admin/models/notification_model.dart';

// class NotificationCard extends StatelessWidget {
//   final Notification notification;
//   final VoidCallback onTap;
//   final VoidCallback onDelete;

//   const NotificationCard({
//     super.key,
//     required this.notification,
//     required this.onTap,
//     required this.onDelete,
//   });

//   Color _getTypeColor(String type) {
//     switch (type) {
//       case 'booking_created':
//         return Colors.green;
//       case 'payment_success':
//         return Colors.blue;
//       case 'general':
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }

//   IconData _getTypeIcon(String type) {
//     switch (type) {
//       case 'booking_created':
//         return Icons.calendar_today;
//       case 'payment_success':
//         return Icons.payment;
//       case 'general':
//         return Icons.notifications;
//       default:
//         return Icons.info;
//     }
//   }

//   String _getTypeLabel(String type) {
//     switch (type) {
//       case 'booking_created':
//         return 'Booking';
//       case 'payment_success':
//         return 'Payment';
//       case 'general':
//         return 'General';
//       default:
//         return type;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final typeColor = _getTypeColor(notification.type);
//     final typeIcon = _getTypeIcon(notification.type);

//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Container(
//         decoration: BoxDecoration(
//           border: notification.isRead
//               ? null
//               : Border(
//                   left: BorderSide(
//                     color: typeColor,
//                     width: 4,
//                   ),
//                 ),
//         ),
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(12),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     CircleAvatar(
//                       backgroundColor: typeColor.withOpacity(0.1),
//                       radius: 20,
//                       child: Icon(typeIcon, color: typeColor, size: 16),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             notification.title,
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: notification.isRead ? Colors.black : Colors.blue[900],
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             _getTypeLabel(notification.type),
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: typeColor,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     if (!notification.isRead)
//                       Container(
//                         width: 8,
//                         height: 8,
//                         decoration: BoxDecoration(
//                           color: Colors.red,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   notification.message,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: Colors.grey[700],
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Icon(Icons.access_time, size: 14, color: Colors.grey),
//                     const SizedBox(width: 4),
//                     Text(
//                       DateFormat('MMM d, yyyy - hh:mm a').format(notification.createdAt),
//                       style: TextStyle(fontSize: 12, color: Colors.grey),
//                     ),
//                     const Spacer(),
//                     if (notification.bookingId != null)
//                       Chip(
//                         label: Text('Booking #${notification.bookingId}'),
//                         backgroundColor: Colors.blue[50],
//                         labelStyle: const TextStyle(fontSize: 10),
//                       ),
//                     const SizedBox(width: 8),
//                     IconButton(
//                       icon: const Icon(Icons.delete, size: 18, color: Colors.red),
//                       onPressed: onDelete,
//                       padding: EdgeInsets.zero,
//                       constraints: const BoxConstraints(),
//                       tooltip: 'Delete notification',
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }