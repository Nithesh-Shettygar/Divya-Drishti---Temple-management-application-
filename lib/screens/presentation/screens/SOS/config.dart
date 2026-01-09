// lib/config.dart
import 'package:firebase_core/firebase_core.dart';

class AppConfig {
  static FirebaseOptions firebaseOptions = const FirebaseOptions(
    apiKey: "AIzaSyCGywKLif1-CeAu65g8IeX1iMjZZ4h7NyQ",
    appId: "1:384054093086:android:98ad480dece48f0d64950f",
    messagingSenderId: "384054093086",
    projectId: "temple-2cc76",
    // 🔥 VERY IMPORTANT — Realtime DB URL
    databaseURL: "https://temple-2cc76-default-rtdb.firebaseio.com",
  );
}