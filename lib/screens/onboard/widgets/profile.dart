import 'package:SpendingMonitor/bloc/cubit/app_cubit.dart';
import 'package:SpendingMonitor/l10n/app_text.dart';
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.6)),
            ),
            child: Icon(Icons.account_balance_wallet, size: 32, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            tr(context, 'Chào mừng đến Fintracker', 'Welcome to Fintracker'),
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            tr(context, 'Chúng tôi nên gọi bạn là gì?', 'What should we call you?'),
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.6)),
            ),
            child: AppTextField(
              controller: controller,
              label: tr(context, 'Tên', 'Name'),
              hintText: tr(context, 'Nhập tên của bạn', 'Enter your name'),
              prefix: const Icon(Icons.account_circle),
            ),
          ),
          const Spacer(),
          AppButton(
            label: tr(context, 'Tiếp tục', 'Continue'),
            icon: Icons.arrow_forward,
            size: AppButtonSize.large,
            isFullWidth: true,
            onPressed: () {
              if (controller.text.isEmpty) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(tr(context, 'Vui lòng nhập tên', 'Please enter your name'))));
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
