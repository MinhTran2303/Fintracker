import 'package:SpendingMonitor/widgets/buttons/button.dart';
import 'package:flutter/material.dart';

class ConfirmModal extends StatelessWidget {
  final String title;
  final Widget content;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  const ConfirmModal({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.onCancel,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      insetPadding: const EdgeInsets.all(20),
      content: content,
      actions: [
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Hủy',
                onPressed: onCancel,
                variant: AppButtonVariant.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: 'Xác nhận',
                onPressed: onConfirm,
                variant: AppButtonVariant.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static showConfirmDialog(
    BuildContext context, {
    required String title,
    required Widget content,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmModal(
          title: title,
          content: content,
          onConfirm: onConfirm,
          onCancel: onCancel,
        );
      },
    );
  }
}
