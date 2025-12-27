import 'package:events_emitter/events_emitter.dart';
import 'package:fintracker/dao/account_dao.dart';
import 'package:fintracker/dao/payment_dao.dart';
import 'package:fintracker/events.dart';
import 'package:fintracker/model/account.model.dart';
import 'package:fintracker/model/category.model.dart';
import 'package:fintracker/model/payment.model.dart';
import 'package:fintracker/screens/payment_form.screen.dart';
import 'package:fintracker/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:fintracker/theme/background.dart';


String greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Chào buổi sáng';
  }
  if (hour < 17) {
    return 'Chào buổi chiều';
  }
  return 'Chào buổi tối';
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PaymentDao _paymentDao = PaymentDao();
  final AccountDao _accountDao = AccountDao();
  EventListener? _accountEventListener;
  EventListener? _categoryEventListener;
  EventListener? _paymentEventListener;
  List<Payment> _payments = [];
  List<Account> _accounts = [];
  double _income = 0;
  double _expense = 0;
  //double _savings = 0;
  DateTimeRange _range = DateTimeRange(
      start: DateTime.now().subtract(Duration(days: DateTime.now().day -1)),
      end: DateTime.now()
  );
  Account? _account;
  Category? _category;

  void openAddPaymentPage(PaymentType type) async {
    Navigator.of(context).push(MaterialPageRoute(builder: (builder)=>PaymentForm(type: type)));
  }

  void handleChooseDateRange() async{
    final selected = await showDateRangePicker(
      context: context,
      initialDateRange: _range,
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    );
    if(selected != null) {
      setState(() {
        _range = selected;
        _fetchTransactions();
      });
    }
  }

  void _fetchTransactions() async {
    List<Payment> trans = await _paymentDao.find(range: _range, category: _category, account:_account);
    double income = 0;
    double expense = 0;
    for (var payment in trans) {
      if(payment.type == PaymentType.credit) income += payment.amount;
      if(payment.type == PaymentType.debit) expense += payment.amount;
    }

    //fetch accounts
    List<Account> accounts = await _accountDao.find(withSummery: true);

    setState(() {
      _payments = trans;
      _income = income;
      _expense = expense;
      _accounts = accounts;
    });
  }


  @override
  void initState() {
    super.initState();
    _fetchTransactions();

    _accountEventListener = globalEvent.on("account_update", (data){
      debugPrint("accounts are changed");
      _fetchTransactions();
    });

    _categoryEventListener = globalEvent.on("category_update", (data){
      debugPrint("categories are changed");
      _fetchTransactions();
    });

    _paymentEventListener = globalEvent.on("payment_update", (data){
      debugPrint("payments are changed");
      _fetchTransactions();
    });
  }

  @override
  void dispose() {
    _accountEventListener?.cancel();
    _categoryEventListener?.cancel();
    _paymentEventListener?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // Calculate monthly data
    final monthlyIncome = _income;
    final monthlyExpense = _expense;
    final netBalance = monthlyIncome - monthlyExpense;

    // Top spending category
    final expenseMap = _payments.where((p) => p.type == PaymentType.debit).fold<Map<String, double>>({}, (map, p) {
      final catName = p.category.name;
      map[catName] = (map[catName] ?? 0) + p.amount;
      return map;
    });
    final topCategory = expenseMap.isNotEmpty ? expenseMap.entries.reduce((a, b) => a.value > b.value ? a : b) : null;

    final theme = Theme.of(context);
    final moneyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = theme.colorScheme.onSurfaceVariant;
    final cardSurface = theme.colorScheme.surface;

    return Scaffold(
      // Keep FAB behavior unchanged
      floatingActionButton: FloatingActionButton(
        onPressed: () => openAddPaymentPage(PaymentType.credit),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: pageBackgroundDecoration(context),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1) Header card (personalized)
                Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(16),
                  color: cardSurface,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Xin chào, Minh', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: primaryTextColor)),
                              const SizedBox(height: 6),
                              Text(DateFormat('EEEE, d MMMM').format(DateTime.now()), style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor)),
                              const SizedBox(height: 6),
                              Text('${_accounts.length} ví', style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor)),
                            ],
                          ),
                        ),
                        CircleAvatar(radius: 26, backgroundColor: theme.colorScheme.primaryContainer, child: Icon(Icons.person, color: theme.colorScheme.onPrimaryContainer)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 2) Main balance card (strong hierarchy)
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(16),
                  color: cardSurface,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: Balance primary - use FittedBox to avoid wrapping and keep visual priority
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Số dư', style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor)),
                              const SizedBox(height: 8),
                              // Scale down if needed to prevent wrapping on small screens
                              LayoutBuilder(builder: (context, constraints) {
                                return FittedBox(
                                  alignment: Alignment.centerLeft,
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    moneyFormat.format(netBalance),
                                    style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800, color: primaryTextColor),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Right: Income / Expense stacked (responsive width to avoid overflow)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final maxW = math.min(160.0, constraints.maxWidth * 0.5);
                            return SizedBox(
                              width: maxW,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.arrow_downward, color: ThemeColors.success, size: 18),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text('Thu nhập', style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor)),
                                            const SizedBox(height: 4),
                                            Text(
                                              moneyFormat.format(monthlyIncome),
                                              style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF22C55E), fontWeight: FontWeight.w700),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.arrow_upward, color: const Color(0xFFF2994A), size: 18),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text('Chi phí', style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor)),
                                            const SizedBox(height: 4),
                                            Text(
                                              moneyFormat.format(monthlyExpense),
                                              style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFFFB923C), fontWeight: FontWeight.w700),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // 3) Monthly summary card (lightweight)
                Material(
                  elevation: 1,
                  borderRadius: BorderRadius.circular(12),
                  color: cardSurface,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: theme.colorScheme.primary, size: 18),
                        const SizedBox(width: 12),
                        Expanded(child: Text('Tổng quan tháng này: ${moneyFormat.format(monthlyIncome)} thu · ${moneyFormat.format(monthlyExpense)} chi', style: theme.textTheme.bodyMedium?.copyWith(color: primaryTextColor))),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 4) Insight card (sentence-based, highlighted)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: const Color(0xFFEEF6FF), borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0, right: 10.0),
                        child: Icon(Icons.lightbulb_outline, color: const Color(0xFF7C3AED), size: 20),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Danh mục chi tiêu cao nhất trong tháng', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: primaryTextColor)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(child: Text(topCategory?.key ?? 'Không có', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: primaryTextColor))),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(netBalance > 0 ? 'Bạn tiết kiệm nhiều hơn trong tháng này' : 'Chi tiêu tăng so với tháng trước', style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 5) Transaction timeline feed header
                Text('Giao dịch gần đây', style: theme.textTheme.titleMedium?.copyWith(color: primaryTextColor)),
                const SizedBox(height: 10),

                // Timeline list (simple column mapping)
                Column(
                  children: _payments.map((p) {
                    final timeText = DateFormat('HH:mm').format(p.datetime);
                    final isExpense = p.type == PaymentType.debit;
                    final dotColor = isExpense ? const Color(0xFFF2994A) : ThemeColors.success;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // left column: time + dot
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
                          // right: transaction card
                          Expanded(
                            child: Material(
                              elevation: 1,
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
                                          Text(p.title.isNotEmpty ? p.title : p.category.name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700, color: primaryTextColor), overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 6),
                                          Text(p.category.name, style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text((isExpense ? '-' : '+') + moneyFormat.format(p.amount), style: theme.textTheme.bodyMedium?.copyWith(color: isExpense ? const Color(0xFFFB923C) : const Color(0xFF22C55E), fontWeight: FontWeight.w800)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
