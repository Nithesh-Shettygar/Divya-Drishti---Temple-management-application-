import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:divya_drishti/core/constants/app_colors.dart';
import 'package:divya_drishti/screens/services/apiservices.dart'; // Import AppConfig
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// MODEL: PersonDetail
class PersonDetail {
  String? name;
  String? phone;
  Gender? gender;
  String? age;
  bool isElderOrDisabled;
  String? elderAge;
  bool? wheelchairRequired;

  PersonDetail({
    this.name,
    this.phone,
    this.gender,
    this.age,
    this.isElderOrDisabled = false,
    this.elderAge,
    this.wheelchairRequired,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name ?? '',
      'phone': phone ?? '',
      'gender': gender?.name,
      'age': age ?? '',
      'is_elder_disabled': isElderOrDisabled,
      'elder_age': elderAge ?? '',
      'wheelchair_required': wheelchairRequired,
    };
  }

  @override
  String toString() {
    return 'PersonDetail{name: $name, phone: $phone, gender: $gender, age: $age, isElderOrDisabled: $isElderOrDisabled, elderAge: $elderAge, wheelchairRequired: $wheelchairRequired}';
  }
}

enum Gender { male, female, other }

/// MODEL: SlotAvailability
class SlotAvailability {
  final DateTime date;
  final bool isAvailable;
  final bool isOpened;
  final int availableSlots;
  final int totalSlots;

  SlotAvailability({
    required this.date,
    required this.isAvailable,
    required this.isOpened,
    required this.availableSlots,
    required this.totalSlots,
  });
}

/// DARSHAN BOOKING PAGE (stateful)
class DarshanBookingPage extends StatefulWidget {
  final String title;
  const DarshanBookingPage({super.key, required this.title});

  @override
  State<DarshanBookingPage> createState() => _DarshanBookingPageState();
}

class _DarshanBookingPageState extends State<DarshanBookingPage> {
  DateTime _selectedDate = DateTime.now();
  int _numberOfPersons = 1;
  final List<PersonDetail> _personDetails = [];

  // Time slots
  String? _selectedTimeSlot;
  final List<String> _timeSlots = [
    "06:00 AM – 07:00 AM",
    "07:00 AM – 08:00 AM",
    "08:00 AM – 09:00 AM",
    "09:00 AM – 10:00 AM",
    "05:00 PM – 06:00 PM",
    "06:00 PM – 07:00 PM",
  ];

  // Mocked availability
  final List<SlotAvailability> _slotAvailability = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _personDetails.add(PersonDetail());
    _initializeSlotAvailability();
  }

  void _initializeSlotAvailability() {
    final now = DateTime.now();
    
    _slotAvailability.clear();
    for (int i = 0; i < 60; i++) {
      final date = now.add(Duration(days: i));
      
      // All slots available for today and all upcoming days
      bool isOpened = true;
      bool isAvailable = true;
      int totalSlots = 100;
      int availableSlots = 100; // Always 100 slots available
      
      _slotAvailability.add(SlotAvailability(
        date: date,
        isAvailable: isAvailable,
        isOpened: isOpened,
        availableSlots: availableSlots,
        totalSlots: totalSlots,
      ));
    }
  }

  SlotAvailability? _getSlotAvailability(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _slotAvailability.firstWhere(
      (slot) =>
          DateTime(slot.date.year, slot.date.month, slot.date.day) ==
          normalizedDate,
      orElse: () => SlotAvailability(
          date: date, isAvailable: false, isOpened: false, availableSlots: 0, totalSlots: 0),
    );
  }

  String _formatDateForBackend(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  // Ping root endpoint to ensure server reachable
  Future<bool> _pingServer() async {
    final uri = Uri.parse('${AppConfig.baseUrl}/');
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 6));
      return resp.statusCode == 200 || resp.statusCode == 404;
    } on TimeoutException {
      return false;
    } on SocketException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Robust booking submission:
  /// - pings server before POST
  /// - extended timeout
  /// - one retry on timeout
  Future<void> _submitBookingFlow() async {
    // Basic validations
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please select a time slot"),
          backgroundColor: Colors.red));
      return;
    }
    for (int i = 0; i < _numberOfPersons; i++) {
      if (_personDetails.length <= i ||
          (_personDetails[i].name?.trim().isEmpty ?? true)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Please enter name for Person ${i + 1}"),
            backgroundColor: Colors.red));
        return;
      }
      if (_personDetails[i].isElderOrDisabled &&
          _personDetails[i].wheelchairRequired == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text("Please specify wheelchair requirement for elder/disabled persons"),
            backgroundColor: Colors.red));
        return;
      }
    }

    setState(() => _loading = true);

    // Ping server
    final pingOk = await _pingServer();
    if (!pingOk) {
      setState(() => _loading = false);
      final suggestion = "Ensure backend is running at ${AppConfig.baseUrl}";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cannot reach backend. $suggestion"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

     final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('user_id');
  
  if (userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("User not logged in"), backgroundColor: Colors.red)
    );
    return;
  }
  
  final personsPayload = _personDetails.take(_numberOfPersons).map((p) => p.toMap()).toList();
  final payload = {
    "title": widget.title,
    "date": _formatDateForBackend(_selectedDate),
    "time_slot": _selectedTimeSlot,
    "persons": _numberOfPersons,
    "amount": 100 * _numberOfPersons,
    "person_details": personsPayload,
    "user_id": userId,  // Add user_id
  };
  

    final uri = Uri.parse('${AppConfig.baseUrl}/book');

    Future<http.Response> _postBooking() {
      return http
          .post(uri,
              body: jsonEncode(payload), headers: {"Content-Type": "application/json"})
          .timeout(const Duration(seconds: 25));
    }

    int attempt = 0;
    const int maxAttempts = 2;

    try {
      while (attempt < maxAttempts) {
        attempt++;
        try {
          final resp = await _postBooking();
          if (resp.statusCode == 200 || resp.statusCode == 201) {
            final body = jsonDecode(resp.body);
            final bookingId = body['booking_id'] ?? body['booking']?['id'];
            if (bookingId == null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Booking created but server did not return id"),
                  backgroundColor: Colors.orange));
              return;
            }

            // Fetch canonical booking from backend to ensure server-side fields (booking_ref/payment_ref) are present
            final bookingObj = await _fetchBooking(bookingId);
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QRPage(
                  bookingId:
                      bookingObj != null ? (bookingObj['id'] as int?) : (bookingId is int ? bookingId : int.tryParse('$bookingId')),
                  amount: bookingObj != null ? (bookingObj['amount'] ?? (100 * _numberOfPersons)) : (100 * _numberOfPersons),
                  bookingRef: bookingObj != null ? (bookingObj['booking_ref'] ?? bookingObj['payment_ref']) : null,
                ),
              ),
            );
            return;
          } else {
            final error = resp.body.isNotEmpty ? resp.body : 'Status ${resp.statusCode}';
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Booking failed: $error"), backgroundColor: Colors.red));
            return;
          }
        } on TimeoutException {
          if (attempt < maxAttempts) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Server slow — retrying..."),
                backgroundColor: Colors.orange));
            await Future.delayed(const Duration(milliseconds: 500));
            continue;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Server timeout. Try again later."),
                backgroundColor: Colors.red));
            return;
          }
        } on SocketException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Network error: ${e.message}"),
              backgroundColor: Colors.red));
          return;
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Error creating booking: $e"),
              backgroundColor: Colors.red));
          return;
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<Map<String, dynamic>?> _fetchBooking(dynamic bookingId) async {
    try {
      final id = bookingId is int ? bookingId : int.tryParse('$bookingId');
      if (id == null) return null;
      final uri = Uri.parse('${AppConfig.baseUrl}/booking/$id');
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        return body['booking'] as Map<String, dynamic>?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // UI BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 16,
                left: 16,
                right: 16),
            child: Row(children: [
              IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white)),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(widget.title,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white))),
            ]),
          ),
          // Main content
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius:
                      BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  color: Colors.white),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildCalendarView(),
                  const SizedBox(height: 16),
                  _buildTimeSlots(),
                  const SizedBox(height: 24),
                  _buildNumberOfPersons(),
                  const SizedBox(height: 24),
                  _buildPersonDetails(),
                  const SizedBox(height: 24),
                  _loading ? const Center(child: CircularProgressIndicator()) : _buildBookButton(),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Calendar & date helpers
  Widget _buildCalendarView() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Select Date", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      _buildMonthHeader(),
      const SizedBox(height: 16),
      _buildCalendarGrid(),
      const SizedBox(height: 16),
      _buildLegend(),
    ]);
  }

  Widget _buildMonthHeader() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(onPressed: _previousMonth, icon: Icon(Icons.chevron_left, color: AppColors.primary)),
      Text(_getMonthYearText(_selectedDate), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      IconButton(onPressed: _nextMonth, icon: Icon(Icons.chevron_right, color: AppColors.primary)),
    ]);
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;

    List<Widget> dayWidgets = [];
    for (int i = 1; i < firstWeekday; i++) dayWidgets.add(const SizedBox());
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final currentDate = DateTime(_selectedDate.year, _selectedDate.month, day);
      final slot = _getSlotAvailability(currentDate);
      dayWidgets.add(_buildDayCell(currentDate, slot!, day));
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        _buildWeekdayHeader('S'),
        _buildWeekdayHeader('M'),
        _buildWeekdayHeader('T'),
        _buildWeekdayHeader('W'),
        _buildWeekdayHeader('T'),
        _buildWeekdayHeader('F'),
        _buildWeekdayHeader('S'),
        ...dayWidgets,
      ],
    );
  }

  Widget _buildWeekdayHeader(String day) {
    return Center(child: Text(day, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)));
  }

  Widget _buildDayCell(DateTime date, SlotAvailability slot, int day) {
    bool isSelected = _isSameDay(date, _selectedDate);
    bool isToday = _isSameDay(date, DateTime.now());
    
    // Disable past dates
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final isPastDate = dateOnly.isBefore(today);

    Color backgroundColor = isSelected ? AppColors.primary : Colors.white;
    Color textColor = isSelected ? Colors.white : (isPastDate ? Colors.grey : Colors.black);
    
    // Always show available slots for today and future dates
    String statusText = isPastDate ? 'Past' : '${slot.availableSlots} left';

    return GestureDetector(
      onTap: isPastDate ? null : () => _selectDateFromCalendar(date),
      child: Container(
        decoration: BoxDecoration(
          color: isPastDate ? Colors.grey.shade100 : backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isToday ? AppColors.primary : Colors.grey.shade300,
            width: isToday ? 2 : 1,
          ),
          boxShadow: [
            if (!isSelected && !isPastDate)
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 8,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(AppColors.primary, 'Available'),
        _buildLegendItem(Colors.white, 'Selectable', hasBorder: true),
        _buildLegendItem(Colors.grey.shade100, 'Past Date'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text, {bool hasBorder = false}) {
    return Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2), border: hasBorder ? Border.all(color: AppColors.primary, width: 2) : null)),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 12)),
    ]);
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  String _getMonthYearText(DateTime date) => '${_getMonthName(date.month)} ${date.year}';

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  void _previousMonth() => setState(() => _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1));
  void _nextMonth() => setState(() => _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1));
  void _selectDateFromCalendar(DateTime d) => setState(() {
        _selectedDate = d;
        _selectedTimeSlot = null;
      });

  // Time slot chips
  Widget _buildTimeSlots() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Select Time Slot", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Wrap(spacing: 10, runSpacing: 10, children: _timeSlots.map((slot) {
        final isSelected = _selectedTimeSlot == slot;
        return ChoiceChip(
          label: Text(slot),
          selected: isSelected,
          selectedColor: AppColors.primary,
          backgroundColor: Colors.grey.shade200,
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
          onSelected: (_) => setState(() => _selectedTimeSlot = slot),
        );
      }).toList())
    ]);
  }

  // Number of persons
  Widget _buildNumberOfPersons() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Number of Persons", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Row(children: [
        IconButton(onPressed: _numberOfPersons > 1 ? _decrementPersons : null, icon: Icon(Icons.remove_circle_outline, color: _numberOfPersons > 1 ? AppColors.primary : Colors.grey)),
        Text('$_numberOfPersons', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(onPressed: _incrementPersons, icon: Icon(Icons.add_circle_outline, color: AppColors.primary)),
      ]),
    ]);
  }

  void _incrementPersons() {
    if (_numberOfPersons < 6) {
      setState(() => _numberOfPersons++);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Maximum 6 persons allowed"), backgroundColor: Colors.red));
    }
  }

  void _decrementPersons() => setState(() {
        if (_numberOfPersons > 1) _numberOfPersons--;
      });

  // Person detail cards
  Widget _buildPersonDetails() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Person Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _numberOfPersons, itemBuilder: (context, index) => _buildPersonDetailCard(index)),
    ]);
  }

  Widget _buildPersonDetailCard(int index) {
    while (_personDetails.length <= index) _personDetails.add(PersonDetail());
    final p = _personDetails[index];

    return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Person ${index + 1}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      TextFormField(decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)), onChanged: (v) => p.name = v),
      const SizedBox(height: 12),
      TextFormField(decoration: const InputDecoration(labelText: "Phone Number", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone, onChanged: (v) => p.phone = v),
      const SizedBox(height: 12),
      DropdownButtonFormField<Gender>(decoration: const InputDecoration(labelText: "Gender", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline)), value: p.gender, items: Gender.values.map((g) => DropdownMenuItem(value: g, child: Text(_getGenderText(g)))).toList(), onChanged: (nv) => setState(() => p.gender = nv)),
      const SizedBox(height: 12),
      TextFormField(decoration: const InputDecoration(labelText: "Age", border: OutlineInputBorder(), prefixIcon: Icon(Icons.cake)), keyboardType: TextInputType.number, onChanged: (v) => p.age = v),
      const SizedBox(height: 16),
      _buildElderDisabledSection(index),
    ])));
  }

  Widget _buildElderDisabledSection(int index) {
    final p = _personDetails[index];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Checkbox(value: p.isElderOrDisabled, onChanged: (val) => setState(() {
          p.isElderOrDisabled = val ?? false;
          if (!p.isElderOrDisabled) p.wheelchairRequired = null;
        })),
        const Text("Elderly or Disabled Person", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ]),
      if (p.isElderOrDisabled) ...[
        const SizedBox(height: 12),
        TextFormField(decoration: const InputDecoration(labelText: "Age (if elderly)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.elderly), hintText: "Enter age if applicable"), keyboardType: TextInputType.number, onChanged: (v) => p.elderAge = v),
        const SizedBox(height: 12),
        const Text("Wheelchair Requirement", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: RadioListTile<bool>(title: const Text("Yes"), value: true, groupValue: p.wheelchairRequired, onChanged: (val) => setState(() => p.wheelchairRequired = val))),
          Expanded(child: RadioListTile<bool>(title: const Text("No"), value: false, groupValue: p.wheelchairRequired, onChanged: (val) => setState(() => p.wheelchairRequired = val))),
        ]),
      ],
    ]);
  }

  String _getGenderText(Gender? g) {
    switch (g) {
      case Gender.male:
        return "Male";
      case Gender.female:
        return "Female";
      case Gender.other:
        return "Other";
      default:
        return "Select Gender";
    }
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitBookingFlow,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
        ),
        child: const Text(
          "Book Now",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

/// QRPage: shows QR for payment and allows dev-simulated scan & pay
class QRPage extends StatefulWidget {
  final int? bookingId;
  final int amount;
  final String? bookingRef;

  const QRPage({super.key, required this.bookingId, required this.amount, this.bookingRef});

  @override
  State<QRPage> createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  bool _loading = true;
  Map<String, dynamic>? _qrPayload;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQrPayload();
  }

  Future<void> _loadQrPayload() async {
    if (widget.bookingId == null) {
      setState(() {
        _error = "Invalid booking id";
        _loading = false;
      });
      return;
    }

    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/booking/${widget.bookingId}/qr');
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(resp.body);
        setState(() {
          _qrPayload = (body['qr_payload'] as Map<String, dynamic>?);
          _loading = false;
        });
      } else {
        setState(() {
          _error = "Failed to fetch QR payload (${resp.statusCode})";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error loading QR: $e";
        _loading = false;
      });
    }
  }

  Future<void> _simulateScanAndPay() async {
    if (_qrPayload == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("QR not ready"), backgroundColor: Colors.red));
      return;
    }
    setState(() => _loading = true);
    try {
      final payload = {"booking_id": _qrPayload!['booking_id'], "amount": _qrPayload!['amount'], "payment_ref": _qrPayload!['payment_ref']};
      final uri = Uri.parse('${AppConfig.baseUrl}/payment');
      final resp = await http.post(uri, body: jsonEncode(payload), headers: {"Content-Type": "application/json"}).timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment marked paid (dev)"), backgroundColor: Colors.green));
        if (mounted) {
          Navigator.of(context).pop(); // close QR page
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment failed: ${resp.body}"), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error completing payment: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingRefText = widget.bookingRef != null ? "Ref: ${widget.bookingRef}" : "";
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment QR"), 
        backgroundColor: AppColors.primary
      ), 
      body: _loading ? const Center(child: CircularProgressIndicator()) : _error != null ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red))) : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Text("Scan this QR at the payment counter", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (bookingRefText.isNotEmpty) Text(bookingRefText, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 20),
          if (_qrPayload != null) ...[
            Center(child: QrImageView(data: jsonEncode(_qrPayload), version: QrVersions.auto, size: 220.0)),
            const SizedBox(height: 20),
            Text("Booking: ${_qrPayload!['booking_id']}  •  Amount: ₹${_qrPayload!['amount']}"),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), 
              onPressed: _simulateScanAndPay, 
              child: const Text("Simulate Scan & Complete Payment (dev)")
            ),
            const SizedBox(height: 12),
            const Text("In production the payment terminal scans the QR and calls the backend /payment endpoint."),
          ],
        ]),
      )
    );
  }
}

/// PaymentPage (kept for alternate flows)
class PaymentPage extends StatefulWidget {
  final int? bookingId;
  final String title;
  final DateTime date;
  final String timeSlot;
  final int persons;
  final List<Map<String, dynamic>> personDetails;
  final int amount;

  const PaymentPage({super.key, required this.bookingId, required this.title, required this.date, required this.timeSlot, required this.persons, required this.personDetails, required this.amount});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _processing = false;

  Future<void> _completePayment() async {
    if (widget.bookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid booking id"), backgroundColor: Colors.red));
      return;
    }
    setState(() => _processing = true);
    try {
      final payload = {"booking_id": widget.bookingId, "amount": widget.amount, "payment_ref": "DEV-${DateTime.now().millisecondsSinceEpoch}"};
      final uri = Uri.parse('${AppConfig.baseUrl}/payment');
      final resp = await http.post(uri, body: jsonEncode(payload), headers: {"Content-Type": "application/json"}).timeout(const Duration(seconds: 25));
      if (resp.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment successful"), backgroundColor: Colors.green));
        if (mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      } else {
        final err = resp.body.isNotEmpty ? resp.body : 'Status ${resp.statusCode}';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment failed: $err"), backgroundColor: Colors.red));
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment timeout. Please try again."), backgroundColor: Colors.red));
    } on SocketException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Network error: ${e.message}"), backgroundColor: Colors.red));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  String _formatDate(DateTime d) => "${d.day.toString().padLeft(2,'0')}-${d.month.toString().padLeft(2,'0')}-${d.year}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"), 
        backgroundColor: AppColors.primary
      ), 
      body: Padding(
        padding: const EdgeInsets.all(16), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Text("Darshan: ${widget.title}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Date: ${_formatDate(widget.date)}"),
            const SizedBox(height: 6),
            Text("Time Slot: ${widget.timeSlot}"),
            const SizedBox(height: 6),
            Text("Persons: ${widget.persons}"),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text("Amount to Pay: ₹${widget.amount}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            _processing ? const Center(child: CircularProgressIndicator()) : SizedBox(
              width: double.infinity, 
              height: 55, 
              child: ElevatedButton(
                onPressed: _completePayment, 
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), 
                child: Text("Pay ₹${widget.amount}", style: const TextStyle(fontSize: 18))
              )
            ),
          ]
        )
      )
    );
  }
}