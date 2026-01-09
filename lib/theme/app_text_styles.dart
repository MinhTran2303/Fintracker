import 'package:flutter/material.dart';

class AppTextStyles {
  static const TextTheme lightTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, height: 1.1),
    displayMedium: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, height: 1.2),
    displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, height: 1.2),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.3),
    headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.3),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3),
    titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.5),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.5),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.5),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.3),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 1.3),
  );

  static const TextTheme darkTextTheme = lightTextTheme;
}
