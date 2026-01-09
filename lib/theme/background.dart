import 'package:flutter/material.dart';

Decoration pageBackgroundDecoration(BuildContext context) {
  final theme = Theme.of(context);
  return BoxDecoration(
    color: theme.colorScheme.background,
  );
}
