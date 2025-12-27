import 'package:fintracker/model/account.model.dart';
import 'package:fintracker/widgets/currency.dart';
import 'package:fintracker/helpers/currency.helper.dart';
import 'package:flutter/material.dart';
import 'package:fintracker/theme/colors.dart';
import 'package:intl/intl.dart';
import 'package:fintracker/dao/payment_dao.dart';
import 'package:fintracker/model/payment.model.dart';
import 'package:events_emitter/events_emitter.dart';
import 'package:fintracker/events.dart';
import 'package:fintracker/theme/background.dart';

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
  // grouped payments by date label
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
    // group by date label (Today/Yesterday/Date)
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
    final isDark = theme.brightness == Brightness.dark;
    final cardSurface = theme.colorScheme.surface;
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = theme.colorScheme.onSurfaceVariant;
    final net = widget.account.balance ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: primaryTextColor)),
        elevation: 1,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: pageBackgroundDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
            // Hero balance card with subtle accent strip
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(14),
              color: cardSurface,
              child: Row(
                children: [
                  // accent strip (brand primary)
                  Container(width: 6, height: 88, decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)))),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      child: Row(
                        children: [
                          CircleAvatar(radius: 26, backgroundColor: widget.account.color.withAlpha((0.12 * 255).round()), child: Icon(widget.account.icon, color: widget.account.color)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Số dư', style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor)),
                                const SizedBox(height: 6),
                                Text(CurrencyHelper.format(net), style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: primaryTextColor)),
                                const SizedBox(height: 6),
                                Text(widget.account.holderName.isNotEmpty ? widget.account.holderName : '', style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Compact summary chips (horizontal) - ensure labels are single-line and compact
            Row(
              children: [
                Expanded(
                  child: Material(
                    elevation: 0.8,
                    borderRadius: BorderRadius.circular(10),
                    color: cardSurface,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_downward, color: const Color(0xFF22C55E), size: 16),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text('Thu nhập', style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
                          ),
                          const SizedBox(width: 8),
                          Text(CurrencyHelper.format(_income), style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF22C55E), fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Material(
                    elevation: 0.8,
                    borderRadius: BorderRadius.circular(10),
                    color: cardSurface,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_upward, color: const Color(0xFFFB923C), size: 16),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text('Chi phí', style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
                          ),
                          const SizedBox(width: 8),
                          Text(CurrencyHelper.format(_expense), style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFFFB923C), fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text('Giao dịch', style: theme.textTheme.titleMedium?.copyWith(color: primaryTextColor)),
            const SizedBox(height: 10),

            // Transaction timeline feed grouped by date
            Expanded(
              child: _payments.isEmpty
                  ? Center(child: Text('Chưa có giao dịch', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)))
                  : ListView(
                      children: _grouped.entries.map((entry) {
                        final label = entry.key;
                        final items = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: primaryTextColor)),
                            ),
                            ...items.map((p) {
                              final timeText = DateFormat('HH:mm').format(p.datetime);
                              final isExpense = p.type == PaymentType.debit;
                              final dotColor = isExpense ? const Color(0xFFF2994A) : ThemeColors.success;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 72,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(timeText, style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor)),
                                          const SizedBox(height: 8),
                                          Container(width: 10, height: 10, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Material(
                                        elevation: 0.6,
                                        borderRadius: BorderRadius.circular(12),
                                        color: cardSurface,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(p.title.isNotEmpty ? p.title : p.category.name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700, color: primaryTextColor), overflow: TextOverflow.ellipsis, maxLines: 1, softWrap: false),
                                                    const SizedBox(height: 6),
                                                    Text(p.category.name, style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor), maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(CurrencyHelper.format(isExpense ? -p.amount : p.amount), style: theme.textTheme.bodyMedium?.copyWith(color: isExpense ? const Color(0xFFFB923C) : const Color(0xFF22C55E), fontWeight: FontWeight.w800)),
                                            ],
                                          ),
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
      ),
    ),
    );
  }
}
