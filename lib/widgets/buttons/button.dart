import 'package:fintracker/theme/app_radius.dart';
import 'package:fintracker/theme/app_spacing.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary }

enum AppButtonSize {
  small,
  normal,
  large,
}

class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.normal,
    this.isFullWidth = false,
  });

  double get _height {
    switch (size) {
      case AppButtonSize.small:
        return 40;
      case AppButtonSize.large:
        return 56;
      case AppButtonSize.normal:
      default:
        return 48;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = variant == AppButtonVariant.primary
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.primary;
    final background = variant == AppButtonVariant.primary
        ? theme.colorScheme.primary
        : Colors.transparent;
    final borderSide = variant == AppButtonVariant.primary
        ? BorderSide.none
        : BorderSide(color: theme.colorScheme.primary, width: 1.4);

    final labelStyle = theme.textTheme.labelLarge?.copyWith(color: foreground);

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            label,
            style: labelStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _height,
      child: variant == AppButtonVariant.primary
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: background,
                foregroundColor: foreground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              onPressed: onPressed,
              child: content,
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: foreground,
                side: borderSide,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              onPressed: onPressed,
              child: content,
            ),
    );
  }
}
