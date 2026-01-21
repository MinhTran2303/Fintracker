import 'package:flutter/material.dart';

Decoration pageBackgroundDecoration(BuildContext context) {
  final theme = Theme.of(context);
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        theme.colorScheme.background,
        theme.colorScheme.surfaceVariant.withOpacity(0.6),
      ],
    ),
  );
}
