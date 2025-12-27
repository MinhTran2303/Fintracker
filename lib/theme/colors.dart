import 'package:flutter/material.dart';

class ThemeColors{
  static const MaterialColor success = MaterialColor(_successPrimaryValue, <int, Color>{
    50: Color(0xFFE8F5E8),
    100: Color(0xFFC8E6C9),
    200: Color(0xFFA5D6A7),
    300: Color(0xFF81C784),
    400: Color(0xFF66BB6A),
    500: Color(_successPrimaryValue),
    600: Color(0xFF43A047),
    700: Color(0xFF388E3C),
    800: Color(0xFF2E7D32),
    900: Color(0xFF1B5E20),
  });
  static const int _successPrimaryValue = 0xFF4CAF50;

  static const MaterialColor successAccent = MaterialColor(_successAccentValue, <int, Color>{
    100: Color(0xFF80FF80),
    200: Color(_successAccentValue),
    400: Color(0xFF2AFF2A),
    700: Color(0xFF1AFF1A),
  });
  static const int _successAccentValue = 0xFF43FF43;

  static const MaterialColor info = MaterialColor(_infoPrimaryValue, <int, Color>{
    50: Color(0xFFE1EFFA),
    100: Color(0xFFB3D7F3),
    200: Color(0xFF81BCEB),
    300: Color(0xFF4EA1E2),
    400: Color(0xFF288CDC),
    500: Color(_infoPrimaryValue),
    600: Color(0xFF0270D1),
    700: Color(0xFF0165CC),
    800: Color(0xFF015BC6),
    900: Color(0xFF0148BC),
  });
  static const int _infoPrimaryValue = 0xFF0278D6;

  static const MaterialColor infoAccent = MaterialColor(_infoAccentValue, <int, Color>{
    100: Color(0xFF90C9FF),
    200: Color(_infoAccentValue),
    400: Color(0xFF3A9FFF),
    700: Color(0xFF2A98FF),
  });
  static const int _infoAccentValue = 0xFF53ACFF;

  static const MaterialColor warning = MaterialColor(_warningPrimaryValue, <int, Color>{
    50: Color(0xFFFDF2E0),
    100: Color(0xFFFADEB3),
    200: Color(0xFFF6C980),
    300: Color(0xFFF2B34D),
    400: Color(0xFFF0A226),
    500: Color(_warningPrimaryValue),
    600: Color(0xFFEB8A00),
    700: Color(0xFFE87F00),
    800: Color(0xFFE57500),
    900: Color(0xFFE06300),
  });
  static const int _warningPrimaryValue = 0xFFED9200;

  static const MaterialColor warningAccent = MaterialColor(_warningAccentValue, <int, Color>{
    100: Color(0xFFFFF6F4),
    200: Color(_warningAccentValue),
    400: Color(0xFFFFB19D),
    700: Color(0xFFFFA58E),
  });
  static const int _warningAccentValue = 0xFFFFC5B6;

  static const MaterialColor error = MaterialColor(_errorPrimaryValue, <int, Color>{
    50: Color(0xFFFFF3E0),
    100: Color(0xFFFFE0B2),
    200: Color(0xFFFFCC80),
    300: Color(0xFFFFB74D),
    400: Color(0xFFFFA726),
    500: Color(_errorPrimaryValue),
    600: Color(0xFFFB8C00),
    700: Color(0xFFF57C00),
    800: Color(0xFFEF6C00),
    900: Color(0xFFE65100),
  });
  static const int _errorPrimaryValue = 0xFFFF9800;

  static const MaterialColor errorAccent = MaterialColor(_errorAccentValue, <int, Color>{
    100: Color(0xFFFFBFC8),
    200: Color(_errorAccentValue),
    400: Color(0xFFFF687E),
    700: Color(0xFFFF5971),
  });
  static const int _errorAccentValue = 0xFFFF8294;
  static const MaterialColor primary = MaterialColor(_primaryPrimaryValue, <int, Color>{
    50: Color(0xFFF3E5F5),
    100: Color(0xFFE1BEE7),
    200: Color(0xFFCE93D8),
    300: Color(0xFFBA68C8),
    400: Color(0xFFAB47BC),
    500: Color(_primaryPrimaryValue),
    600: Color(0xFF7B1FA2),
    700: Color(0xFF6A1B9A),
    800: Color(0xFF4A148C),
    900: Color(0xFF38006B),
  });
  // MyWallet VN brand purple: #6C4AB6
  static const int _primaryPrimaryValue = 0xFF6C4AB6;

  static const MaterialColor primaryAccent = MaterialColor(_primaryAccentValue, <int, Color>{
    100: Color(0xFFE1BEE7),
    200: Color(_primaryAccentValue),
    400: Color(0xFFAB47BC),
    700: Color(0xFF8E24AA),
  });
  static const int _primaryAccentValue = 0xFFBA68C8;
}