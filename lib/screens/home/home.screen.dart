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
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(greeting(), style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        const SizedBox(height: AppSpacing.xs),
                        Text('Xin chào, $username', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          DateFormat('EEEE, d MMMM').format(DateTime.now()),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person, color: theme.colorScheme.onPrimaryContainer),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    title: 'Thêm thu nhập',
                    subtitle: 'Ghi nhận khoản thu',
                    icon: Icons.add_circle,
                    color: theme.colorScheme.secondary,
                    onTap: () => openAddPaymentPage(PaymentType.credit),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _QuickActionCard(
                    title: 'Thêm chi tiêu',
                    subtitle: 'Cập nhật khoản chi',
                    icon: Icons.remove_circle,
                    color: theme.colorScheme.tertiary,
                    onTap: () => openAddPaymentPage(PaymentType.debit),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(
              title: 'Tổng quan tháng này',
              subtitle: '${_accounts.length} ví đang hoạt động',
              action: TextButton(
                onPressed: handleChooseDateRange,
                child: const Text('Chọn kỳ'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 520;
                return GridView.count(
                  crossAxisCount: isWide ? 3 : 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isWide ? 1.6 : 1.2,
                  children: [
                    StatCard(
                      title: 'Số dư',
                      value: moneyFormat.format(netBalance),
                      icon: Icons.account_balance_wallet,
                      accentColor: theme.colorScheme.primary,
                      caption: netBalance >= 0 ? 'Bạn đang tiết kiệm tốt' : 'Cần tối ưu chi tiêu',
                    ),
                    StatCard(
                      title: 'Thu nhập',
                      value: moneyFormat.format(monthlyIncome),
                      icon: Icons.arrow_downward,
                      accentColor: theme.colorScheme.secondary,
                      caption: 'Tổng thu trong kỳ',
                    ),
                    StatCard(
                      title: 'Chi tiêu',
                      value: moneyFormat.format(monthlyExpense),
                      icon: Icons.arrow_upward,
                      accentColor: theme.colorScheme.tertiary,
                      caption: 'Tổng chi trong kỳ',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.calendar_today, color: theme.colorScheme.primary, size: 18),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tổng quan tháng này', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${moneyFormat.format(monthlyIncome)} thu · ${moneyFormat.format(monthlyExpense)} chi',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: handleChooseDateRange,
                    child: const Text('Chi tiết'),
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
                      color: theme.colorScheme.tertiary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
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

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
