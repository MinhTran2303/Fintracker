import 'package:fintracker/theme/app_radius.dart';
import 'package:flutter/material.dart';

class AppFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const AppFAB({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Icon(icon),
    );
  }
}
