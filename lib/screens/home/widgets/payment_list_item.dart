import 'package:fintracker/model/payment.model.dart';
import 'package:fintracker/helpers/currency.helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/colors.dart';

class PaymentListItem extends StatelessWidget{
  final Payment payment;
  final VoidCallback onTap;
  const PaymentListItem({super.key, required this.payment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCredit = payment.type == PaymentType.credit;
    // model fields are non-nullable; use directly
    final category = payment.category;
    final catColor = category.color;
    final catIcon = category.icon;
    final catName = category.name;
    final datetime = payment.datetime;

    final amountText = CurrencyHelper.format(isCredit ? payment.amount : -payment.amount);
    final subtitleText = "$catName • ${DateFormat("dd MMM yyyy, HH:mm").format(datetime)}";

    return ListTile(
      onTap: onTap,
      leading: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: catColor.withAlpha((0.1 * 255).round()),
        ),
        child: Icon(
          catIcon,
          size: 16,
          color: catColor,
        ),
      ),
      title: Text(
        amountText,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: isCredit ? ThemeColors.success : ThemeColors.error,
        ),
      ),
      subtitle: Text(
        subtitleText,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

}