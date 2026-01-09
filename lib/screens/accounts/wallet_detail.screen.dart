import 'package:fintracker/model/account.model.dart';
import 'package:fintracker/helpers/currency.helper.dart';
import 'package:fintracker/theme/app_spacing.dart';
import 'package:fintracker/widgets/app/app_card.dart';
import 'package:fintracker/widgets/app/app_scaffold.dart';
import 'package:fintracker/widgets/app/section_header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fintracker/dao/payment_dao.dart';
import 'package:fintracker/model/payment.model.dart';
import 'package:events_emitter/events_emitter.dart';
import 'package:fintracker/events.dart';

class WalletDetailScreen extends StatefulWidget {
  final Account account;
  const WalletDetailScreen({super.key, required this.account});

  @override
  State<WalletDetailScreen> createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends State<WalletDetailScreen> {
  final PaymentDao _paymentDao = PaymentDao();
  EventListener? _paymentListener;
  List<Payment> _payments = [];
  double _income = 0;
  double _expense = 0;
  final Map<String, List<Payment>> _grouped = <String, List<Payment>>{};

  @override
  void initState() {
    super.initState();
    _fetchPayments();
    _paymentListener = globalEvent.on('payment_update', (d) => _fetchPayments());
  }

  @override
  void dispose() {
    _paymentListener?.cancel();
    super.dispose();
  }

  void _fetchPayments() async {
    final payments = await _paymentDao.find(account: widget.account);
    double income = 0;
    double expense = 0;
    for (var p in payments) {
      if (p.type == PaymentType.credit) income += p.amount;
      if (p.type == PaymentType.debit) expense += p.amount;
    }
    final Map<String, List<Payment>> grouped = <String, List<Payment>>{};
    final now = DateTime.now();
    for (var p in payments) {
      final d = p.datetime;
      String label;
      final justDate = DateTime(d.year, d.month, d.day);
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      if (justDate == today) {
        label = 'Hôm nay';
      } else if (justDate == yesterday) {
        label = 'Hôm qua';
      } else {
        label = DateFormat('dd MMM yyyy').format(d);
      }
      grouped.putIfAbsent(label, () => <Payment>[]).add(p);
    }

    setState(() {
      _payments = payments;
      _income = income;
      _expense = expense;
      _grouped
        ..clear()
        ..addAll(grouped);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final net = widget.account.balance ?? 0;

    return AppScaffold(
      appBar: AppBar(
        title: Text(widget.account.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: widget.account.color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.account.icon, color: widget.account.color),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Số dư', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        CurrencyHelper.format(net),
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        widget.account.holderName.isNotEmpty ? widget.account.holderName : '',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_downward, color: theme.colorScheme.secondary, size: 16),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text('Thu nhập', style: theme.textTheme.bodySmall),
                      ),
                      Text(
                        CurrencyHelper.format(_income),
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_upward, color: theme.colorScheme.tertiary, size: 16),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text('Chi phí', style: theme.textTheme.bodySmall),
                      ),
                      Text(
                        CurrencyHelper.format(_expense),
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.tertiary, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: 'Giao dịch'),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _payments.isEmpty
                ? Center(
                    child: Text('Chưa có giao dịch', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  )
                : ListView(
                    children: _grouped.entries.map((entry) {
                      final label = entry.key;
                      final items = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                            child: Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                          ),
                          ...items.map((p) {
                            final timeText = DateFormat('HH:mm').format(p.datetime);
                            final isExpense = p.type == PaymentType.debit;
                            final dotColor = isExpense ? theme.colorScheme.tertiary : theme.colorScheme.secondary;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 72,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(timeText, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                        const SizedBox(height: AppSpacing.sm),
                                        Container(width: 10, height: 10, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: AppCard(
                                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  p.title.isNotEmpty ? p.title : p.category.name,
                                                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                const SizedBox(height: AppSpacing.xs),
                                                Text(
                                                  p.category.name,
                                                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.md),
                                          Text(
                                            CurrencyHelper.format(isExpense ? -p.amount : p.amount),
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: isExpense ? theme.colorScheme.tertiary : theme.colorScheme.secondary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
