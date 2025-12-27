import 'package:flutter/material.dart';

Decoration pageBackgroundDecoration(BuildContext context) {
  final theme = Theme.of(context);

  // Use a soft dark gradient for page backgrounds across the app.
  // Cards and surfaces should still use theme.colorScheme.surface so they remain light.
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF0F1724), // very dark blue-gray
        const Color(0xFF1E293B), // dark slate
      ],
    ),
  );
}
