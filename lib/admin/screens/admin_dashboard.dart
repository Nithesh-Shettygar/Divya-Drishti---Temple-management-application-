import 'package:divya_drishti/admin/screens/bookings_management_screen.dart';
import 'package:divya_drishti/admin/screens/notifications_management_screen.dart';
import 'package:divya_drishti/admin/screens/statistics_screen.dart';
import 'package:divya_drishti/admin/screens/users_management_screen.dart';
import 'package:divya_drishti/admin/widgets/admin_drawer.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  // Don't initialize _pages in initState, use late initialization instead
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Initialize with placeholders, will be replaced in didChangeDependencies
    _pages = [
      Container(), // Placeholder for dashboard
      const UsersManagementScreen(),
      const BookingsManagementScreen(),
      const StatisticsScreen(),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Now we can safely access context and theme
    _pages = [
      _buildDashboardHome(),
      const UsersManagementScreen(),
      const BookingsManagementScreen(),
      const StatisticsScreen(),
    ];
    // Force rebuild if needed
    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildDashboardHome() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, Admin',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Divya Drishti Admin Panel',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    // Refresh data
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Stats Cards
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  icon: Icons.people,
                  title: 'Total Users',
                  value: '0',
                  color: Colors.blue,
                  onTap: () {
                    _selectedIndex = 1;
                    setState(() {});
                  },
                ),
                _buildStatCard(
                  icon: Icons.calendar_today,
                  title: 'Total Bookings',
                  value: '0',
                  color: Colors.green,
                  onTap: () {
                    _selectedIndex = 2;
                    setState(() {});
                  },
                ),
                _buildStatCard(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  value: '0',
                  color: Colors.orange,
                  onTap: () {
                    // _selectedIndex = 3;
                    // setState(() {});
                  },
                ),
                _buildStatCard(
                  icon: Icons.analytics,
                  title: 'Statistics',
                  value: 'View',
                  color: Colors.purple,
                  onTap: () {
                    _selectedIndex = 3;
                    setState(() {});
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text('Add User'),
                  onPressed: () {
                    _selectedIndex = 1;
                    setState(() {});
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.search, size: 18),
                  label: const Text('Find Booking'),
                  onPressed: () {
                    _selectedIndex = 2;
                    setState(() {});
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.send, size: 18),
                  label: const Text('Send Notification'),
                  onPressed: () {
                    // Implement send notification
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.qr_code, size: 18),
                  label: const Text('Generate QR'),
                  onPressed: () {
                    // Implement QR generation
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Divya Drishti Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}