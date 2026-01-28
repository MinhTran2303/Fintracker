import 'package:SpendingMonitor/bloc/cubit/app_cubit.dart';
import 'package:SpendingMonitor/theme/app_spacing.dart';
import 'package:SpendingMonitor/widgets/app/app_scaffold.dart';
import 'package:SpendingMonitor/widgets/app/app_text_field.dart';
import 'package:SpendingMonitor/widgets/buttons/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileWidget extends StatelessWidget {
  final VoidCallback onGetStarted;
  const ProfileWidget({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppCubit cubit = context.read<AppCubit>();
    TextEditingController controller = TextEditingController(text: cubit.state.username);
    return AppScaffold(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.lg),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Bước 1 / 2',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.15),
                  theme.colorScheme.secondary.withOpacity(0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thiết lập hồ sơ',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Tạo dấu ấn cá nhân để Fintracker gợi ý và theo dõi dễ hơn.',
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 96,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.4)),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.auto_graph_rounded,
                            size: 36,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Container(
                        height: 96,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.4)),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.savings_outlined,
                            size: 36,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Tên hiển thị',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller: controller,
            label: 'Tên',
            hintText: 'Nhập tên của bạn',
            prefix: const Icon(Icons.account_circle),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Bạn có thể chỉnh sửa tên sau trong phần cài đặt.',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Hoàn tất bước này',
            icon: Icons.arrow_forward,
            size: AppButtonSize.large,
            isFullWidth: true,
            onPressed: () {
              if (controller.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên')));
              } else {
                cubit.updateUsername(controller.text).then((value) {
                  onGetStarted();
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
