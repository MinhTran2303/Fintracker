import 'package:SpendingMonitor/theme/app_spacing.dart';
import 'package:flutter/material.dart';

String translateCategoryName(String name) {
  const translations = {
    'Housing': 'Nhà ở',
    'Transportation': 'Di chuyển',
    'Food': 'Ăn uống',
    'Utilities': 'Tiện ích',
    'Insurance': 'Bảo hiểm',
    'Medical & Healthcare': 'Y tế & chăm sóc sức khỏe',
    'Saving, Investing, & Debt Payments': 'Tiết kiệm, đầu tư & trả nợ',
    'Personal Spending': 'Chi tiêu cá nhân',
    'Recreation & Entertainment': 'Giải trí',
    'Miscellaneous': 'Khác',
  };

  return translations[name] ?? name;
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
