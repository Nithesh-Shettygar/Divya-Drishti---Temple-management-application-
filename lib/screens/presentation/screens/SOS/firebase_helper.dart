import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseHelper {
  static final db = FirebaseDatabase.instance.ref("sos_logs");

  /// Get stored user details
  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "name": prefs.getString('user_name') ?? 'Unknown User',
      "phone": prefs.getString('user_phone') ?? 'Unknown Phone',
      "gender": prefs.getString('user_gender') ?? 'Not specified',
      "address": prefs.getString('user_address') ?? 'Not specified',
    };
  }

  /// Send static location to Firebase
  static Future<void> sendLocationWithStatic({
    required double lat,
    required double lon,
  }) async {
    try {
      final userData = await getUserData();
      final timestamp = DateTime.now();

      await db.push().set({
        "name": userData['name'],
        "phone": userData['phone'],
        "gender": userData['gender'],
        "address": userData['address'],
        "latitude": lat,
        "longitude": lon,
        "date": "${timestamp.year}-${timestamp.month}-${timestamp.day}",
        "time": "${timestamp.hour}:${timestamp.minute}:${timestamp.second}",
        "full_timestamp": timestamp.toIso8601String(),
        "status": "PENDING",
      });

      
    } catch (e) {
      
      rethrow;
    }
  }

  /// Original method (keep it for reference)
  static Future<void> sendCurrentLocation() async {
    // Keep your original implementation but add error handling
  
    await sendLocationWithStatic(lat: 23.224363, lon: 72.507734);
  }
}