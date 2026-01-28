import 'package:SpendingMonitor/theme/app_spacing.dart';
import 'package:SpendingMonitor/widgets/buttons/button.dart';
import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String description;
  final String ctaLabel;
  final VoidCallback onCta;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.description,
    required this.ctaLabel,
    required this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.savings_outlined, size: 52, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: AppSpacing.lg),
        Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: ctaLabel,
          onPressed: onCta,
          variant: AppButtonVariant.primary,
          isFullWidth: true,
        ),
      ],
    );
  }
}
