import 'package:SpendingMonitor/theme/app_spacing.dart';
import 'package:SpendingMonitor/l10n/app_text.dart';
import 'package:flutter/material.dart';

String translateCategoryName(BuildContext context, String name) {
  switch (name) {
    case 'Housing':
      return tr(context, 'Nhà ở', 'Housing');
    case 'Transportation':
      return tr(context, 'Di chuyển', 'Transportation');
    case 'Food':
      return tr(context, 'Ăn uống', 'Food');
    case 'Utilities':
      return tr(context, 'Tiện ích', 'Utilities');
    case 'Insurance':
      return tr(context, 'Bảo hiểm', 'Insurance');
    case 'Medical & Healthcare':
      return tr(context, 'Y tế & chăm sóc sức khỏe', 'Medical & Healthcare');
    case 'Saving, Investing, & Debt Payments':
      return tr(context, 'Tiết kiệm, đầu tư & trả nợ', 'Saving, Investing, & Debt Payments');
    case 'Personal Spending':
      return tr(context, 'Chi tiêu cá nhân', 'Personal Spending');
    case 'Recreation & Entertainment':
      return tr(context, 'Giải trí', 'Recreation & Entertainment');
    case 'Miscellaneous':
      return tr(context, 'Khác', 'Miscellaneous');
    default:
      return name;
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: AppSpacing.sm),
            action!,
          ],
        ],
      ),
    );
  }
}
