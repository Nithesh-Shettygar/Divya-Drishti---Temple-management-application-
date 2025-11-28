import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF800000);
  static const Color secondary = Color(0xFFFF9933);
  static const Color yellow = Color(0xFFFFD700);
  static const Color bg = Color(0xFFFFEBC6);

  // Gradient Colors
  static const Color gradientStart = Color(0xFFFFC601);
  static const Color gradientMiddle = Color(0xFFFFA501);
  static const Color gradientEnd = Color(0xFFEC6801);
  static const Color gradientDark = Color(0xFFCF4100);

  // Gradient getters for easy usage
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [gradientStart, gradientMiddle, gradientEnd, gradientDark],
        stops: [0.0, 0.2, 0.3, 0.4],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      );

  static LinearGradient get darkGradient => const LinearGradient(
        colors: [gradientMiddle, gradientEnd, gradientDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Optional: You can also add semantic names for better readability
  static const Color maroon = primary;
  static const Color orange = secondary;
  static const Color gold = yellow;
}