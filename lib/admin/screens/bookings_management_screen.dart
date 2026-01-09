import 'package:divya_drishti/admin/models/booking_model.dart';
import 'package:divya_drishti/admin/screens/booking_details_screen.dart';
import 'package:divya_drishti/admin/services/api_service.dart';
import 'package:divya_drishti/admin/widgets/booking_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class BookingsManagementScreen extends StatefulWidget {
  const BookingsManagementScreen({super.key});

  @override
  State<BookingsManagementScreen> createState() =>
      _BookingsManagementScreenState();
}

class _BookingsManagementScreenState extends State<BookingsManagementScreen> {
  List<Booking> _bookings = [];
  List<Booking> _filteredBookings = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, paid, pending
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookings = await ApiService.getAllBookings();
      setState(() {
        _bookings = bookings;
        _applyFilters();
      });
    } catch (e) {
      _showError('Failed to load bookings: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredBookings = _bookings.where((booking) {
        // Search filter
        final matchesSearch = _searchQuery.isEmpty ||
            booking.bookingRef
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            booking.title.toLowerCase().contains(_searchQuery.toLowerCase());

        // Status filter
        final matchesStatus = _filterStatus == 'all' ||
            (_filterStatus == 'paid' && booking.paid) ||
            (_filterStatus == 'pending' && !booking.paid);

        // Date filter
        final matchesDate = _selectedDate == null ||
            DateFormat('yyyy-MM-dd').format(booking.bookingDate) ==
                DateFormat('yyyy-MM-dd').format(_selectedDate!);

        return matchesSearch && matchesStatus && matchesDate;
      }).toList();
    });
  }

  void _filterBySearch(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _filterByStatus(String status) {
    setState(() {
      _filterStatus = status;
      _applyFilters();
    });
  }

  void _filterByDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _applyFilters();
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
      _applyFilters();
    });
  }

  Future<void> _updatePaymentStatus(Booking booking) async {
    try {
      await ApiService.updatePaymentStatus(
        booking.id,
        !booking.paid,
        'ADMIN-${DateTime.now().millisecondsSinceEpoch}',
      );
      _showSuccess(
          'Payment status updated to ${!booking.paid ? 'Paid' : 'Pending'}');
      _loadBookings();
    } catch (e) {
      _showError('Failed to update payment status: $e');
    }
  }

  Future<void> _deleteBooking(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Booking'),
        content: Text(
            'Are you sure you want to delete booking ${booking.bookingRef}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.deleteBooking(booking.id);
        setState(() {
          _bookings.removeWhere((b) => b.id == booking.id);
          _applyFilters();
        });
        _showSuccess('Booking deleted successfully');
      } catch (e) {
        _showError('Failed to delete booking: $e');
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

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            selected: _filterStatus == 'all',
            label: const Text('All'),
            onSelected: (_) => _filterByStatus('all'),
          ),
          const SizedBox(width: 8),
          FilterChip(
            selected: _filterStatus == 'paid',
            label: const Text('Paid'),
            selectedColor: Colors.green[100],
            onSelected: (_) => _filterByStatus('paid'),
          ),
          const SizedBox(width: 8),
          FilterChip(
            selected: _filterStatus == 'pending',
            label: const Text('Pending'),
            selectedColor: Colors.orange[100],
            onSelected: (_) => _filterByStatus('pending'),
          ),
          const SizedBox(width: 8),
          FilterChip(
            selected: _selectedDate != null,
            label: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4),
                Text(
                  _selectedDate != null
                      ? DateFormat('MMM d').format(_selectedDate!)
                      : 'Pick Date',
                ),
                if (_selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: _clearDateFilter,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            onSelected: (_) => _filterByDate(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _filteredBookings.fold(
        0, (sum, booking) => sum + booking.amount);
    final paidAmount = _filteredBookings
        .where((b) => b.paid)
        .fold(0, (sum, booking) => sum + booking.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookings,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Text('Clear All Bookings (Dev)'),
              ),
            ],
            onSelected: (value) async {
              if (value == 'clear_all') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Bookings'),
                    content: const Text(
                        'This will delete ALL bookings. Are you sure?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Clear All',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  try {
                    await ApiService.clearAllBookings();
                    _showSuccess('All bookings cleared');
                    _loadBookings();
                  } catch (e) {
                    _showError('Failed to clear bookings: $e');
                  }
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterBySearch,
              decoration: InputDecoration(
                labelText: 'Search bookings...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildFilterChips(),
          ),

          // Stats Cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('Total Bookings',
                            style: TextStyle(color: Colors.grey)),
                        Text(
                          _filteredBookings.length.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Total Amount',
                            style: TextStyle(color: Colors.grey)),
                        Text(
                          '₹$totalAmount',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Paid Amount',
                            style: TextStyle(color: Colors.grey)),
                        Text(
                          '₹$paidAmount',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bookings List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _filteredBookings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty &&
                                      _filterStatus == 'all' &&
                                      _selectedDate == null
                                  ? 'No bookings found'
                                  : 'No bookings match your filters',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadBookings,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: _filteredBookings.length,
                          itemBuilder: (context, index) {
                            final booking = _filteredBookings[index];
                            return BookingCard(
                              booking: booking,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BookingDetailsScreen(booking: booking),
                                  ),
                                );
                              },
                              onUpdateStatus: () =>
                                  _updatePaymentStatus(booking),
                              onDelete: () => _deleteBooking(booking),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new booking
          _showAddBookingDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddBookingDialog() {
    // Implement add booking dialog
    _showSuccess('Add booking functionality to be implemented');
  }
}