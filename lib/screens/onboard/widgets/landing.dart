import 'package:fintracker/theme/app_spacing.dart';
import 'package:fintracker/widgets/app/app_scaffold.dart';
import 'package:fintracker/widgets/buttons/button.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  final VoidCallback onGetStarted;
  const LandingPage({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return AppScaffold(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fintracker',
            style: theme.textTheme.displaySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Quản lý tài chính cá nhân một cách tinh gọn',
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          _FeatureRow(text: 'Theo dõi thu chi nhanh chóng mỗi ngày.'),
          const SizedBox(height: AppSpacing.sm),
          _FeatureRow(text: 'Giữ ngân sách luôn trong tầm kiểm soát.'),
          const SizedBox(height: AppSpacing.sm),
          _FeatureRow(text: 'Tổng quan rõ ràng với biểu đồ và thống kê.'),
          const Spacer(),
          Text(
            '*Ứng dụng đang ở giai đoạn beta, UI có thể thay đổi.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Bắt đầu',
            onPressed: onGetStarted,
            size: AppButtonSize.large,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  const _FeatureRow({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(Icons.check_circle, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}
