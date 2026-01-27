import 'package:fintracker/model/payment.model.dart';
import 'package:fintracker/helpers/currency.helper.dart';
import 'package:fintracker/theme/app_radius.dart';
import 'package:fintracker/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentListItem extends StatelessWidget {
  final Payment payment;
  final VoidCallback onTap;
  const PaymentListItem({super.key, required this.payment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCredit = payment.type == PaymentType.credit;
    final category = payment.category;
    final amountText = CurrencyHelper.format(isCredit ? payment.amount : -payment.amount);
    final subtitleText = "${category.name} • ${DateFormat("dd MMM yyyy, HH:mm").format(payment.datetime)}";

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                color: theme.colorScheme.surfaceVariant,
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.4)),
              ),
              child: Icon(category.icon, size: 18, color: category.color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.title.isNotEmpty ? payment.title : category.name,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitleText,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              amountText,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: isCredit ? theme.colorScheme.secondary : theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
