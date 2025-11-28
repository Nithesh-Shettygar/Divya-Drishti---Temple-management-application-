import 'dart:async';
import 'package:flutter/material.dart';
import 'package:divya_drishti/screens/presentation/auth/login_page.dart';
import 'package:divya_drishti/screens/presentation/screens/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

/// Simple AuthService that talks to backend to validate stored phone.
/// You can move this to a separate file later.
class AuthService {
  // Change this to your backend base URL if not localhost/emulator
  static const String baseUrl = "http://10.0.2.2:5000"; // Android emulator -> host machine
  // For real devices replace with your machine IP: http://192.168.x.y:5000

  /// Validate the phone exists on server (GET /profile/<phone>)
  /// Returns true if server returns 200 and user exists.
  static Future<bool> validatePhoneWithServer(String phone) async {
    try {
      final uri = Uri.parse("$baseUrl/profile/$phone");
      final resp = await http.get(uri).timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        // Optionally parse user object: final data = jsonDecode(resp.body);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // Network error / timeout — caller can decide what to do (we fallback to local)
      // print("AuthService.validatePhoneWithServer error: $e");
      throw e;
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Divya Drishti',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const LaunchDecider(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// This widget shows the splash screen while deciding whether to show Home or Login.
class LaunchDecider extends StatefulWidget {
  const LaunchDecider({super.key});

  @override
  State<LaunchDecider> createState() => _LaunchDeciderState();
}

class _LaunchDeciderState extends State<LaunchDecider> {
  bool _loading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    // Show splash for at least 800ms for polish.
    final minDelay = Future.delayed(const Duration(milliseconds: 800));

    bool localHasPhone = false;
    String? phone;
    try {
      final prefs = await SharedPreferences.getInstance();
      localHasPhone = prefs.containsKey('user_phone');
      phone = prefs.getString('user_phone');
    } catch (e) {
      // If SharedPreferences fails for any reason, treat as not logged in.
      localHasPhone = false;
    }

    if (localHasPhone && phone != null) {
      // Try validating with backend. If backend fails (timeout/network),
      // we'll fallback to local value (so dev experience is smooth).
      try {
        final valid = await AuthService.validatePhoneWithServer(phone);
        _isLoggedIn = valid;
      } catch (_) {
        // If server unreachable, we choose to accept the local pref as logged in.
        // This improves offline/dev experience. Change behavior if you want strict validation.
        _isLoggedIn = true;
      }
    } else {
      _isLoggedIn = false;
    }

    await minDelay; // ensure minimum splash time
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SplashScreen();
    }
    return _isLoggedIn ? HomePage() : LoginPage();
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A5ACD), // Use your app's primary color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // App Logo/Icon
            const Icon(
              Icons.visibility, // Eye icon for Divya Drishti
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            // App Name
            const Text(
              'Divya Drishti',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            // Tagline
            const Text(
              'Your Spiritual Journey',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 30),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
