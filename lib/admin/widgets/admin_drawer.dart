import 'package:flutter/material.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2196F3),
                  Color(0xFF1976D2),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 36,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Divya Drishti Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Administrator Panel',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          _buildDrawerItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () {
              Navigator.pop(context);
              // Navigate to dashboard
            },
          ),
          _buildDrawerItem(
            icon: Icons.people,
            title: 'Users',
            onTap: () {
              Navigator.pop(context);
              // Navigate to users
            },
          ),
          _buildDrawerItem(
            icon: Icons.calendar_today,
            title: 'Bookings',
            onTap: () {
              Navigator.pop(context);
              // Navigate to bookings
            },
          ),
          _buildDrawerItem(
            icon: Icons.notifications,
            title: 'Notifications',
            badgeCount: 3,
            onTap: () {
              Navigator.pop(context);
              // Navigate to notifications
            },
          ),
          _buildDrawerItem(
            icon: Icons.analytics,
            title: 'Statistics',
            onTap: () {
              Navigator.pop(context);
              // Navigate to statistics
            },
          ),

          const Divider(),

          // System Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'System',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings
            },
          ),
          _buildDrawerItem(
            icon: Icons.help,
            title: 'Help & Support',
            onTap: () {
              Navigator.pop(context);
              // Navigate to help
            },
          ),
          _buildDrawerItem(
            icon: Icons.info,
            title: 'About',
            onTap: () {
              Navigator.pop(context);
              // Show about dialog
            },
          ),

          const Divider(),

          // Logout
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            color: Colors.red,
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to login
            },
          ),

          // Version
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    int? badgeCount,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Colors.blue,
      ),
      title: Text(title),
      trailing: badgeCount != null
          ? CircleAvatar(
              radius: 12,
              backgroundColor: Colors.red,
              child: Text(
                badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}