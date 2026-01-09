import 'package:fintracker/bloc/cubit/app_cubit.dart';
import 'package:fintracker/theme/app_spacing.dart';
import 'package:fintracker/widgets/app/app_scaffold.dart';
import 'package:fintracker/widgets/app/app_text_field.dart';
import 'package:fintracker/widgets/buttons/button.dart';
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
          Icon(Icons.account_balance_wallet, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Chào mừng đến Fintracker',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Chúng tôi nên gọi bạn là gì?',
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: controller,
            label: 'Tên',
            hintText: 'Nhập tên của bạn',
            prefix: const Icon(Icons.account_circle),
          ),
          const Spacer(),
          AppButton(
            label: 'Tiếp tục',
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
