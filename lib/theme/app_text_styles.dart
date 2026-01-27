import 'package:flutter/material.dart';

class AppTextStyles {
  static const TextTheme lightTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.w600, height: 1.1),
    displayMedium: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, height: 1.2),
    displaySmall: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, height: 1.2),
    headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.3),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.35),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.35),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
    bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.5),
    bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.55),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.55),
    labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.4),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.4),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 1.3),
  );

  static const TextTheme darkTextTheme = lightTextTheme;
}
