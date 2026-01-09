import 'package:divya_drishti/admin/models/booking_model.dart';
import 'package:divya_drishti/admin/models/user_model.dart';
import 'package:divya_drishti/admin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Booking> _bookings = [];
  List<User> _users = [];
  bool _isLoading = false;
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final [bookings, users] = await Future.wait([
        ApiService.getAllBookings(),
        ApiService.getAllUsers(),
      ]);

      setState(() {
        _bookings = (bookings as List).cast<Booking>();
        _users = (users as List).cast<User>();
      });
    } catch (e) {
      _showError('Failed to load data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _dateRange,
    );

    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  Map<String, dynamic> _calculateStats() {
    final filteredBookings = _bookings.where((booking) {
      return booking.createdAt.isAfter(_dateRange.start) &&
          booking.createdAt.isBefore(_dateRange.end.add(const Duration(days: 1)));
    }).toList();

    final totalBookings = filteredBookings.length;
    final totalRevenue = filteredBookings.fold(0, (sum, b) => sum + b.amount);
    final paidBookings = filteredBookings.where((b) => b.paid).length;
    final pendingBookings = filteredBookings.where((b) => !b.paid).length;
    final totalUsers = _users.length;

    // Calculate daily data for chart
    final dailyData = <Map<String, dynamic>>[];
    final daysDifference = _dateRange.end.difference(_dateRange.start).inDays;

    for (int i = 0; i <= daysDifference; i++) {
      final date = _dateRange.start.add(Duration(days: i));
      final dateStr = DateFormat('MMM d').format(date);

      final dayBookings = filteredBookings.where((b) {
        return b.createdAt.day == date.day &&
            b.createdAt.month == date.month &&
            b.createdAt.year == date.year;
      }).toList();

      final dayRevenue = dayBookings.fold(0, (sum, b) => sum + b.amount);

      dailyData.add({
        'date': dateStr,
        'bookings': dayBookings.length,
        'revenue': dayRevenue,
        'dateObj': date,
      });
    }

    // Calculate bookings by time slot
    final timeSlots = <String, int>{};
    for (final booking in filteredBookings) {
      timeSlots[booking.timeSlot] = (timeSlots[booking.timeSlot] ?? 0) + 1;
    }

    // Calculate bookings by status
    final statusData = [
      {'status': 'Paid', 'count': paidBookings, 'color': Colors.green},
      {'status': 'Pending', 'count': pendingBookings, 'color': Colors.orange},
    ];

    return {
      'totalBookings': totalBookings,
      'totalRevenue': totalRevenue,
      'paidBookings': paidBookings,
      'pendingBookings': pendingBookings,
      'totalUsers': totalUsers,
      'dailyData': dailyData,
      'timeSlots': timeSlots.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
      'statusData': statusData,
      'avgBookingValue': totalBookings > 0 ? totalRevenue / totalBookings : 0,
      'conversionRate': totalBookings > 0 ? (paidBookings / totalBookings) * 100 : 0,
    };
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date Range',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${DateFormat('MMM d, yyyy').format(_dateRange.start)} - ${DateFormat('MMM d, yyyy').format(_dateRange.end)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _selectDateRange,
              icon: const Icon(Icons.edit),
              tooltip: 'Change date range',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(Map<String, dynamic> stats) {
    final dailyData = stats['dailyData'] as List<Map<String, dynamic>>;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Revenue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelRotation: 45,
                ),
                series: <CartesianSeries>[
                  ColumnSeries<Map<String, dynamic>, String>(
                    dataSource: dailyData,
                    xValueMapper: (data, _) => data['date'],
                    yValueMapper: (data, _) => data['revenue'],
                    name: 'Revenue',
                    color: Colors.blue,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsChart(Map<String, dynamic> stats) {
    final dailyData = stats['dailyData'] as List<Map<String, dynamic>>;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Bookings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelRotation: 45,
                ),
                series: <CartesianSeries>[
                  LineSeries<Map<String, dynamic>, String>(
                    dataSource: dailyData,
                    xValueMapper: (data, _) => data['date'],
                    yValueMapper: (data, _) => data['bookings'],
                    name: 'Bookings',
                    color: Colors.green,
                    markerSettings: const MarkerSettings(isVisible: true),
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotChart(Map<String, dynamic> stats) {
    final timeSlots = stats['timeSlots'] as List<MapEntry<String, int>>;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Popular Time Slots',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                series: <CartesianSeries>[
                  BarSeries<MapEntry<String, int>, String>(
                    dataSource: timeSlots.take(5).toList(),
                    xValueMapper: (data, _) => data.key,
                    yValueMapper: (data, _) => data.value,
                    name: 'Bookings',
                    color: Colors.orange,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPieChart(Map<String, dynamic> stats) {
    final statusData = stats['statusData'] as List<Map<String, dynamic>>;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SfCircularChart(
                legend: Legend(isVisible: true),
                series: <CircularSeries>[
                  PieSeries<Map<String, dynamic>, String>(
                    dataSource: statusData,
                    xValueMapper: (data, _) => data['status'],
                    yValueMapper: (data, _) => data['count'],
                    pointColorMapper: (data, _) => data['color'] as Color,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCards(Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          title: 'Total Revenue',
          value: '₹${stats['totalRevenue']}',
          icon: Icons.attach_money,
          color: Colors.green,
          subtitle: 'From ${stats['totalBookings']} bookings',
        ),
        _buildStatCard(
          title: 'Total Bookings',
          value: stats['totalBookings'].toString(),
          icon: Icons.calendar_today,
          color: Colors.blue,
          subtitle: '${stats['paidBookings']} paid, ${stats['pendingBookings']} pending',
        ),
        _buildStatCard(
          title: 'Total Users',
          value: stats['totalUsers'].toString(),
          icon: Icons.people,
          color: Colors.purple,
          subtitle: 'Registered users',
        ),
        _buildStatCard(
          title: 'Conversion Rate',
          value: '${stats['conversionRate'].toStringAsFixed(1)}%',
          icon: Icons.trending_up,
          color: Colors.orange,
          subtitle: 'Paid vs Total bookings',
        ),
        _buildStatCard(
          title: 'Avg Booking Value',
          value: '₹${stats['avgBookingValue'].toStringAsFixed(0)}',
          icon: Icons.analytics,
          color: Colors.teal,
          subtitle: 'Average per booking',
        ),
        _buildStatCard(
          title: 'Time Period',
          value: '${_dateRange.end.difference(_dateRange.start).inDays} days',
          icon: Icons.timeline,
          color: Colors.red,
          subtitle: 'Selected range',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Export statistics
              _showSuccess('Export feature coming soon');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range Selector
                  _buildDateRangeSelector(),
                  const SizedBox(height: 16),

                  // Top Stats Cards
                  _buildTopCards(stats),
                  const SizedBox(height: 24),

                  // Charts Section
                  const Text(
                    'Analytics & Insights',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Revenue Chart
                  _buildRevenueChart(stats),
                  const SizedBox(height: 16),

                  // Bookings Chart
                  _buildBookingsChart(stats),
                  const SizedBox(height: 16),

                  // Two column charts
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeSlotChart(stats),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatusPieChart(stats),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Insights Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Key Insights',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInsightItem(
                            icon: Icons.trending_up,
                            title: 'Peak Booking Time',
                            value: stats['timeSlots'].isNotEmpty
                                ? (stats['timeSlots'] as List).first.key
                                : 'No data',
                            color: Colors.green,
                          ),
                          _buildInsightItem(
                            icon: Icons.attach_money,
                            title: 'Highest Revenue Day',
                            value: stats['dailyData'].isNotEmpty
                                ? (stats['dailyData'] as List)
                                    .reduce((a, b) => a['revenue'] > b['revenue'] ? a : b)['date']
                                : 'No data',
                            color: Colors.blue,
                          ),
                          _buildInsightItem(
                            icon: Icons.people,
                            title: 'New Users Growth',
                            value: '+${_calculateNewUsers(stats)} this period',
                            color: Colors.purple,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  int _calculateNewUsers(Map<String, dynamic> stats) {
    final newUsers = _users.where((user) {
      return user.createdAt.isAfter(_dateRange.start) &&
          user.createdAt.isBefore(_dateRange.end.add(const Duration(days: 1)));
    }).length;
    return newUsers;
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(value),
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
}