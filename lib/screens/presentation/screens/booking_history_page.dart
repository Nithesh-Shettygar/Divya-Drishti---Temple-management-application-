// booking_history_page.dart
import 'dart:convert';
import 'package:divya_drishti/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  // default candidates
  final List<String> baseCandidates = [
    "http://10.0.2.2:5000", // Android emulator -> host machine localhost
    "http://127.0.0.1:5000", // iOS simulator / same machine
    // you can add your LAN ip like http://192.168.1.100:5000
  ];

  bool _loading = true;
  bool _refreshing = false;
  String? _error;
  List<dynamic> _history = [];
  String? _userPhone;
  String? _savedBaseUrl; // persisted base url
  String _lastTriedHost = '';

  @override
  void initState() {
    super.initState();
    _loadUserAndHistory();
  }

  Future<void> _loadUserAndHistory() async {
    setState(() {
      _loading = true;
      _error = null;
      _history = [];
    });

    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('user_phone');
    final base = prefs.getString('backend_base_url');
    _savedBaseUrl = base;
    if (phone == null || phone.isEmpty) {
      setState(() {
        _loading = false;
        _error = "No logged-in user found. Please login to see booking history.";
      });
      return;
    }
    _userPhone = phone;

    // Try saved base first, then defaults
    List<String> attempts = [];
    if (_savedBaseUrl != null && _savedBaseUrl!.isNotEmpty) {
      attempts.add(_savedBaseUrl!);
    }
    attempts.addAll(baseCandidates.where((b) => b != _savedBaseUrl));

    await _fetchHistoryTryingHosts(_userPhone!, attempts);
  }

  Future<void> _fetchHistoryTryingHosts(String phone, List<String> hostsToTry) async {
    setState(() => _refreshing = true);

    StringBuffer errors = StringBuffer();
    bool success = false;
    List<dynamic> resultItems = [];
    String successfulHost = '';

    for (final base in hostsToTry) {
      _lastTriedHost = base;
      // First try the user-specific endpoint (if backend supports it)
      try {
        final uriUser = Uri.parse("$base/history/user?phone=$phone");
        final respUser = await http.get(uriUser).timeout(const Duration(seconds: 15));
        if (respUser.statusCode == 200) {
          final Map<String, dynamic> body = jsonDecode(respUser.body);
          resultItems = body['history'] ?? [];
          success = true;
          successfulHost = base;
          break;
        } else {
          // if not 200, we'll attempt the generic history endpoint below
          errors.writeln("Host $base /history/user responded ${respUser.statusCode}");
        }
      } catch (e) {
        errors.writeln("Host $base /history/user error: $e");
      }

      // Try generic /history and filter client-side by person's phone
      try {
        final uriAll = Uri.parse("$base/history");
        final respAll = await http.get(uriAll).timeout(const Duration(seconds: 15));
        if (respAll.statusCode == 200) {
          final Map<String, dynamic> body = jsonDecode(respAll.body);
          final List<dynamic> all = body['history'] ?? [];

          // Filter bookings where any person.phone == user phone
          final List<dynamic> filtered = all.where((b) {
            try {
              final persons = (b['person_details'] as List<dynamic>?);
              if (persons == null) return false;
              for (final p in persons) {
                final pmap = p as Map<String, dynamic>;
                final pphone = (pmap['phone'] ?? '').toString();
                if (pphone.isNotEmpty && pphone == phone) return true;
              }
            } catch (_) {
              // ignore parse errors
            }
            return false;
          }).toList();

          // If filtered non-empty, accept it; otherwise still accept all if user might be the booking owner (no person phone)
          if (filtered.isNotEmpty) {
            resultItems = filtered;
            success = true;
            successfulHost = base;
            break;
          } else {
            // If filtered is empty, there's a chance the backend's bookings don't include person phone or user booked under other phone.
            // In that case accept the full list (so user sees something) but still mark success.
            resultItems = all;
            success = true;
            successfulHost = base;
            break;
          }
        } else {
          errors.writeln("Host $base /history responded ${respAll.statusCode}");
        }
      } catch (e) {
        errors.writeln("Host $base /history error: $e");
      }
    }

    if (!success) {
      final msg = """
Failed to fetch booking history.
Tried hosts: ${hostsToTry.join(', ')}

Errors:
${errors.toString().trim()}

Tips:
• Ensure Flask server is running.
• For Android emulator use 10.0.2.2:5000.
• For real device set Flask host to 0.0.0.0 and use your PC LAN IP, e.g. http://192.168.1.100:5000.
• Make sure AndroidManifest has <uses-permission android:name="android.permission.INTERNET"/> .
""";
      setState(() {
        _error = msg;
        _history = [];
      });
    } else {
      // persist successfulHost to prefs
      try {
        final prefs = await SharedPreferences.getInstance();
        if (successfulHost.isNotEmpty) {
          await prefs.setString('backend_base_url', successfulHost);
        }
      } catch (_) {}

      setState(() {
        _history = resultItems;
        _error = null;
        _savedBaseUrl ??= successfulHost;
      });
    }

    setState(() {
      _loading = false;
      _refreshing = false;
    });
  }

  Future<void> _onRefresh() async {
    if (_userPhone == null) return;
    List<String> hostsToTry = [];
    if (_savedBaseUrl != null && _savedBaseUrl!.isNotEmpty) hostsToTry.add(_savedBaseUrl!);
    hostsToTry.addAll(baseCandidates.where((b) => b != _savedBaseUrl));
    await _fetchHistoryTryingHosts(_userPhone!, hostsToTry);
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return raw;
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd-MM-yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    final dateStr = booking['booking_date'] ?? booking['date'] ?? '';
    final timeSlot = booking['time_slot'] ?? '';
    final persons = booking['persons']?.toString() ?? '';
    final amount = booking['amount']?.toString() ?? '';
    final paid = booking['paid'] == true;
    final List<dynamic> personsList = booking['person_details'] ?? [];
    final bookingRef = booking['payment_ref'] ?? booking['booking_ref'] ?? '';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              Expanded(child: Text("${booking['title'] ?? 'Booking'}")),
              if (bookingRef != null && bookingRef.toString().isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                  child: Text("Ref: $bookingRef", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Date: ${_formatDate(dateStr)}"),
                const SizedBox(height: 6),
                Text("Time: $timeSlot"),
                const SizedBox(height: 6),
                Text("Persons: $persons"),
                const SizedBox(height: 6),
                Text("Amount: ₹$amount  •  ${paid ? 'Paid' : 'Pending'}"),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                const Text("Person Details:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...personsList.map((p) {
                  final name = p['name'] ?? '-';
                  final phone = p['phone'] ?? '-';
                  final elder = (p['is_elder_disabled'] == true || p['is_elder_disabled'] == 1) ? ' (Elder/Disabled)' : '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text("• $name — $phone$elder"),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Close', style: TextStyle(color: AppColors.primary))),
          ],
        );
      },
    );
  }

  // UI to let user set/test a base URL
  Future<void> _openBaseUrlDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final controller = TextEditingController(text: _savedBaseUrl ?? baseCandidates.first);
    String result = '';
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Backend Base URL"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter the backend base URL to test (include http:// and port)"),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: "http://10.0.2.2:5000"),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                result = controller.text.trim();
                Navigator.pop(ctx);
              },
              child: const Text("Test"),
            ),
          ],
        );
      },
    );

    if (result.isEmpty) return;

    // Try the single host provided
    setState(() {
      _loading = true;
      _error = null;
    });

    final uriUser = Uri.parse("$result/history/user?phone=${_userPhone ?? ''}");
    final uriAll = Uri.parse("$result/history");
    String errorMsg = '';
    try {
      // try user-specific first
      final respUser = await http.get(uriUser).timeout(const Duration(seconds: 15));
      if (respUser.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(respUser.body);
        final List<dynamic> items = body['history'] ?? [];
        // Save chosen base to prefs
        await prefs.setString('backend_base_url', result);
        setState(() {
          _savedBaseUrl = result;
          _history = items;
          _error = null;
        });
        _showSavedSnack("Base URL saved and fetch successful: $result");
        return;
      }

      // fallback to /history
      final respAll = await http.get(uriAll).timeout(const Duration(seconds: 15));
      if (respAll.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(respAll.body);
        final List<dynamic> items = body['history'] ?? [];
        // filter by user phone if possible
        final filtered = items.where((b) {
          try {
            final persons = (b['person_details'] as List<dynamic>?);
            if (persons == null) return true; // include if no person list
            for (final p in persons) {
              final pmap = p as Map<String, dynamic>;
              final pphone = (pmap['phone'] ?? '').toString();
              if (pphone.isNotEmpty && pphone == _userPhone) return true;
            }
          } catch (_) {}
          return false;
        }).toList();

        await prefs.setString('backend_base_url', result);
        setState(() {
          _savedBaseUrl = result;
          _history = filtered.isNotEmpty ? filtered : items;
          _error = null;
        });
        _showSavedSnack("Base URL saved and fetch successful: $result");
        return;
      }

      errorMsg = "Server returned ${respAll.statusCode} / ${respUser.statusCode}";
    } catch (e) {
      errorMsg = e.toString();
    } finally {
      setState(() {
        _loading = false;
        _refreshing = false;
      });
    }

    if (errorMsg.isNotEmpty) {
      setState(() {
        _error = "Test failed for $result\n$errorMsg";
      });
    }
  }

  void _showSavedSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: AppColors.primary),
    );
  }

  Widget _buildList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[700]),
              const SizedBox(height: 12),
              const Text("Error fetching history:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SelectableText(_error!, textAlign: TextAlign.left),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: _loadUserAndHistory,
                child: const Text('Retry'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: _openBaseUrlDialog,
                child: const Text('Set / Test Base URL'),
              ),
            ],
          ),
        ),
      );
    }

    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_edu, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            const Text('No booking history found', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: _onRefresh,
              child: const Text('Refresh'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              onPressed: _openBaseUrlDialog,
              child: const Text('Set / Test Base URL'),
            ),
            const SizedBox(height: 10),
            if (_lastTriedHost.isNotEmpty) Text("Last tried host: $_lastTriedHost", style: const TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _history.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = _history[index] as Map<String, dynamic>;
          final dateStr = item['booking_date'] ?? item['date'] ?? '';
          final timeSlot = item['time_slot'] ?? '';
          final amount = item['amount']?.toString() ?? '';
          final paid = item['paid'] == true;
          final bookingRef = item['payment_ref'] ?? item['booking_ref'] ?? '';
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              title: Row(
                children: [
                  Expanded(child: Text(item['title'] ?? 'Booking', style: const TextStyle(fontWeight: FontWeight.bold))),
                  if (bookingRef != null && bookingRef.toString().isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                      child: Text("Ref: $bookingRef", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    )
                ],
              ),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 6),
                Text("${_formatDate(dateStr)}  •  $timeSlot"),
                const SizedBox(height: 6),
                Text("Amount: ₹$amount  •  ${paid ? 'Paid' : 'Pending'}"),
              ]),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () => _showBookingDetails(item),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text('Booking History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openBaseUrlDialog,
            tooltip: "Set / Test Backend Base URL",
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          child: _buildList(),
        ),
      ),
    );
  }
}
