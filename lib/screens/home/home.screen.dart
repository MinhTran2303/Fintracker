import 'package:events_emitter/events_emitter.dart';
import 'package:fintracker/bloc/cubit/app_cubit.dart';
import 'package:fintracker/dao/account_dao.dart';
import 'package:fintracker/dao/payment_dao.dart';
import 'package:fintracker/events.dart';
import 'package:fintracker/model/account.model.dart';
import 'package:fintracker/model/category.model.dart';
import 'package:fintracker/model/payment.model.dart';
import 'package:fintracker/screens/home/widgets/payment_list_item.dart';
import 'package:fintracker/screens/payment_form.screen.dart';
import 'package:fintracker/theme/app_spacing.dart';
import 'package:fintracker/widgets/app/app_card.dart';
import 'package:fintracker/widgets/app/app_fab.dart';
import 'package:fintracker/widgets/app/app_scaffold.dart';
import 'package:fintracker/widgets/app/empty_state_widget.dart';
import 'package:fintracker/widgets/app/section_header.dart';
import 'package:fintracker/widgets/app/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
  DateTimeRange _range = DateTimeRange(
    start: DateTime.now().subtract(Duration(days: DateTime.now().day - 1)),
    end: DateTime.now(),
  );
  Account? _account;
  Category? _category;

  void openAddPaymentPage(PaymentType type) async {
    Navigator.of(context).push(MaterialPageRoute(builder: (builder) => PaymentForm(type: type)));
  }

  void handleChooseDateRange() async {
    final selected = await showDateRangePicker(
      context: context,
      initialDateRange: _range,
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      setState(() {
        _range = selected;
        _fetchTransactions();
      });
    }
  }

  void _fetchTransactions() async {
    List<Payment> trans = await _paymentDao.find(range: _range, category: _category, account: _account);
    double income = 0;
    double expense = 0;
    for (var payment in trans) {
      if (payment.type == PaymentType.credit) income += payment.amount;
      if (payment.type == PaymentType.debit) expense += payment.amount;
    }

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

    _accountEventListener = globalEvent.on('account_update', (data) {
      debugPrint('accounts are changed');
      _fetchTransactions();
    });

    _categoryEventListener = globalEvent.on('category_update', (data) {
      debugPrint('categories are changed');
      _fetchTransactions();
    });

    _paymentEventListener = globalEvent.on('payment_update', (data) {
      debugPrint('payments are changed');
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
    final theme = Theme.of(context);
    final moneyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final monthlyIncome = _income;
    final monthlyExpense = _expense;
    final netBalance = monthlyIncome - monthlyExpense;

    final expenseMap = _payments.where((p) => p.type == PaymentType.debit).fold<Map<String, double>>({}, (map, p) {
      final catName = p.category.name;
      map[catName] = (map[catName] ?? 0) + p.amount;
      return map;
    });
    final topCategory = expenseMap.isNotEmpty ? expenseMap.entries.reduce((a, b) => a.value > b.value ? a : b) : null;

    final username = context.read<AppCubit>().state.username ?? 'Bạn';

    return AppScaffold(
      padding: const EdgeInsets.all(AppSpacing.lg),
      floatingActionButton: AppFAB(
        onPressed: () => openAddPaymentPage(PaymentType.credit),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting(), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Xin chào, $username', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        DateFormat('EEEE, d MMMM').format(DateTime.now()),
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.outline.withOpacity(0.6)),
                  ),
                  child: Icon(Icons.person, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Tổng quan', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      const Spacer(),
                      TextButton(
                        onPressed: handleChooseDateRange,
                        child: const Text('Chọn kỳ'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    moneyFormat.format(netBalance),
                    style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    netBalance >= 0 ? 'Số dư ròng tháng này' : 'Số dư ròng đang âm',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryPill(
                          label: 'Thu nhập',
                          value: moneyFormat.format(monthlyIncome),
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _SummaryPill(
                          label: 'Chi tiêu',
                          value: moneyFormat.format(monthlyExpense),
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(
              title: 'Danh mục chi tiêu cao nhất',
              subtitle: topCategory == null ? 'Chưa có dữ liệu' : 'Dựa trên kỳ đã chọn',
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                    ),
                    child: Icon(Icons.trending_up, color: theme.colorScheme.tertiary, size: 18),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topCategory?.key ?? 'Không có dữ liệu',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          topCategory == null
                              ? 'Hãy thêm giao dịch để xem phân tích.'
                              : 'Chiếm ${moneyFormat.format(topCategory!.value)} trong kỳ.',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(title: 'Giao dịch gần đây'),
            const SizedBox(height: AppSpacing.md),
            if (_payments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: EmptyStateWidget(
                  title: 'Chưa có giao dịch',
                  description: 'Bắt đầu thêm giao dịch để theo dõi dòng tiền của bạn.',
                  ctaLabel: 'Thêm giao dịch',
                  onCta: () => openAddPaymentPage(PaymentType.credit),
                ),
              )
            else
              Column(
                children: _payments.map((payment) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: PaymentListItem(
                      payment: payment,
                      onTap: () {},
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
