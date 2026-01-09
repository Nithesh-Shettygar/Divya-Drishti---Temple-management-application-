// import 'package:divya_drishti/admin/widgets/notification_card.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';


// class NotificationsManagementScreen extends StatefulWidget {
//   const NotificationsManagementScreen({super.key});

//   @override
//   State<NotificationsManagementScreen> createState() =>
//       _NotificationsManagementScreenState();
// }

// class _NotificationsManagementScreenState
//     extends State<NotificationsManagementScreen> {
//   List<Notification> _notifications = [];
//   List<Notification> _filteredNotifications = [];
//   bool _isLoading = false;
//   String _searchQuery = '';
//   String _filterType = 'all'; // all, general, booking_created, payment_success
//   bool _showUnreadOnly = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadNotifications();
//   }

//   Future<void> _loadNotifications() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final notifications = await ApiService.getNotifications();
//       setState(() {
//         _notifications = notifications;
//         _applyFilters();
//       });
//     } catch (e) {
//       _showError('Failed to load notifications: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _applyFilters() {
//     setState(() {
//       _filteredNotifications = _notifications.where((notification) {
//         // Search filter
//         final matchesSearch = _searchQuery.isEmpty ||
//             notification.title
//                 .toLowerCase()
//                 .contains(_searchQuery.toLowerCase()) ||
//             notification.message
//                 .toLowerCase()
//                 .contains(_searchQuery.toLowerCase());

//         // Type filter
//         final matchesType =
//             _filterType == 'all' || notification.type == _filterType;

//         // Read status filter
//         final matchesReadStatus = !_showUnreadOnly || !notification.isRead;

//         return matchesSearch && matchesType && matchesReadStatus;
//       }).toList();
//     });
//   }

//   Future<void> _markAsRead(int notificationId) async {
//     try {
//       await ApiService.markNotificationAsRead(notificationId);
//       _showSuccess('Notification marked as read');
//       _loadNotifications(); // Reload to update status
//     } catch (e) {
//       _showError('Failed to mark notification as read: $e');
//     }
//   }

//   Future<void> _markAllAsRead() async {
//     final unreadNotifications =
//         _notifications.where((n) => !n.isRead).toList();

//     if (unreadNotifications.isEmpty) {
//       _showInfo('No unread notifications');
//       return;
//     }

//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Mark All as Read'),
//         content: Text(
//             'Mark all ${unreadNotifications.length} unread notifications as read?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Mark All'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         // Mark each unread notification
//         for (final notification in unreadNotifications) {
//           await ApiService.markNotificationAsRead(notification.id);
//         }

//         _showSuccess(
//             '${unreadNotifications.length} notifications marked as read');
//         _loadNotifications();
//       } catch (e) {
//         _showError('Failed to mark notifications as read: $e');
//       }
//     }
//   }

//   Future<void> _deleteNotification(Notification notification) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Notification'),
//         content: const Text('Are you sure you want to delete this notification?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       try {
//         // Note: You'll need to add delete notification endpoint
//         // await ApiService.deleteNotification(notification.id);
//         setState(() {
//           _notifications.removeWhere((n) => n.id == notification.id);
//           _applyFilters();
//         });
//         _showSuccess('Notification deleted');
//       } catch (e) {
//         _showError('Failed to delete notification: $e');
//       }
//     }
//   }

//   void _clearAllNotifications() async {
//     if (_notifications.isEmpty) {
//       _showInfo('No notifications to clear');
//       return;
//     }

//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Clear All Notifications'),
//         content: const Text('This will delete ALL notifications. Are you sure?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Clear All', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       try {
//         // Note: You'll need to add clear notifications endpoint
//         setState(() {
//           _notifications.clear();
//           _filteredNotifications.clear();
//         });
//         _showSuccess('All notifications cleared');
//       } catch (e) {
//         _showError('Failed to clear notifications: $e');
//       }
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   void _showSuccess(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }

//   void _showInfo(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//       ),
//     );
//   }

//   Widget _buildFilterChips() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: [
//           FilterChip(
//             selected: _filterType == 'all',
//             label: const Text('All Types'),
//             onSelected: (_) {
//               setState(() {
//                 _filterType = 'all';
//                 _applyFilters();
//               });
//             },
//           ),
//           const SizedBox(width: 8),
//           FilterChip(
//             selected: _filterType == 'general',
//             label: const Text('General'),
//             selectedColor: Colors.blue[100],
//             onSelected: (_) {
//               setState(() {
//                 _filterType = 'general';
//                 _applyFilters();
//               });
//             },
//           ),
//           const SizedBox(width: 8),
//           FilterChip(
//             selected: _filterType == 'booking_created',
//             label: const Text('Booking Created'),
//             selectedColor: Colors.green[100],
//             onSelected: (_) {
//               setState(() {
//                 _filterType = 'booking_created';
//                 _applyFilters();
//               });
//             },
//           ),
//           const SizedBox(width: 8),
//           FilterChip(
//             selected: _filterType == 'payment_success',
//             label: const Text('Payment Success'),
//             selectedColor: Colors.purple[100],
//             onSelected: (_) {
//               setState(() {
//                 _filterType = 'payment_success';
//                 _applyFilters();
//               });
//             },
//           ),
//           const SizedBox(width: 8),
//           FilterChip(
//             selected: _showUnreadOnly,
//             label: Row(
//               children: [
//                 Icon(
//                   Icons.notifications,
//                   size: 16,
//                   color: _showUnreadOnly ? Colors.red : null,
//                 ),
//                 const SizedBox(width: 4),
//                 const Text('Unread Only'),
//               ],
//             ),
//             selectedColor: Colors.red[100],
//             onSelected: (_) {
//               setState(() {
//                 _showUnreadOnly = !_showUnreadOnly;
//                 _applyFilters();
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatsCard() {
//     final totalNotifications = _notifications.length;
//     final unreadCount = _notifications.where((n) => !n.isRead).length;
//     final today = DateTime.now();
//     final todayNotifications = _notifications
//         .where((n) => n.createdAt.day == today.day && n.createdAt.month == today.month && n.createdAt.year == today.year)
//         .length;

//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildStatItem(
//               icon: Icons.notifications,
//               value: totalNotifications.toString(),
//               label: 'Total',
//               color: Colors.blue,
//             ),
//             _buildStatItem(
//               icon: Icons.notifications_active,
//               value: unreadCount.toString(),
//               label: 'Unread',
//               color: Colors.red,
//             ),
//             _buildStatItem(
//               icon: Icons.today,
//               value: todayNotifications.toString(),
//               label: 'Today',
//               color: Colors.green,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatItem({
//     required IconData icon,
//     required String value,
//     required String label,
//     required Color color,
//   }) {
//     return Column(
//       children: [
//         CircleAvatar(
//           backgroundColor: color.withOpacity(0.1),
//           child: Icon(icon, color: color, size: 20),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 12,
//             color: Colors.grey,
//           ),
//         ),
//       ],
//     );
//   }

//   void _sendNotificationDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Send Notification'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 decoration: const InputDecoration(
//                   labelText: 'Title',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 maxLines: 3,
//                 decoration: const InputDecoration(
//                   labelText: 'Message',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(
//                   labelText: 'Type',
//                   border: OutlineInputBorder(),
//                 ),
//                 items: const [
//                   DropdownMenuItem(
//                     value: 'general',
//                     child: Text('General'),
//                   ),
//                   DropdownMenuItem(
//                     value: 'booking_created',
//                     child: Text('Booking Created'),
//                   ),
//                   DropdownMenuItem(
//                     value: 'payment_success',
//                     child: Text('Payment Success'),
//                   ),
//                 ],
//                 onChanged: (_) {},
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // Implement send notification
//               _showSuccess('Notification sent successfully');
//               Navigator.pop(context);
//             },
//             child: const Text('Send'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifications Management'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadNotifications,
//           ),
//           IconButton(
//             icon: const Icon(Icons.mark_email_read),
//             onPressed: _markAllAsRead,
//             tooltip: 'Mark all as read',
//           ),
//           PopupMenuButton(
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: 'send',
//                 child: Row(
//                   children: [
//                     Icon(Icons.send, size: 20),
//                     SizedBox(width: 8),
//                     Text('Send Notification'),
//                   ],
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 'clear_all',
//                 child: Row(
//                   children: [
//                     Icon(Icons.delete_sweep, size: 20, color: Colors.red),
//                     SizedBox(width: 8),
//                     Text('Clear All', style: TextStyle(color: Colors.red)),
//                   ],
//                 ),
//               ),
//             ],
//             onSelected: (value) {
//               if (value == 'send') {
//                 _sendNotificationDialog();
//               } else if (value == 'clear_all') {
//                 _clearAllNotifications();
//               }
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               onChanged: (value) {
//                 setState(() {
//                   _searchQuery = value;
//                   _applyFilters();
//                 });
//               },
//               decoration: InputDecoration(
//                 labelText: 'Search notifications...',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[100],
//               ),
//             ),
//           ),

//           // Stats Card
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: _buildStatsCard(),
//           ),

//           // Filter Chips
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: _buildFilterChips(),
//           ),

//           // Notifications List
//           Expanded(
//             child: _isLoading
//                 ? const Center(
//                     child: CircularProgressIndicator(),
//                   )
//                 : _filteredNotifications.isEmpty
//                     ? Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               _showUnreadOnly
//                                   ? Icons.notifications_off
//                                   : Icons.notifications_none,
//                               size: 80,
//                               color: Colors.grey,
//                             ),
//                             const SizedBox(height: 16),
//                             Text(
//                               _searchQuery.isEmpty &&
//                                       _filterType == 'all' &&
//                                       !_showUnreadOnly
//                                   ? 'No notifications'
//                                   : 'No notifications match your filters',
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     : RefreshIndicator(
//                         onRefresh: _loadNotifications,
//                         child: ListView.builder(
//                           padding: const EdgeInsets.only(bottom: 80),
//                           itemCount: _filteredNotifications.length,
//                           itemBuilder: (context, index) {
//                             final notification = _filteredNotifications[index];
//                             return NotificationCard(
//                               notification: notification,
//                               onTap: () => _markAsRead(notification.id),
//                               onDelete: () => _deleteNotification(notification),
//                             );
//                           },
//                         ),
//                       ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _sendNotificationDialog,
//         child: const Icon(Icons.add_comment),
//       ),
//     );
//   }
// }