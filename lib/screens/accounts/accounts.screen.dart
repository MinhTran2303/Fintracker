import 'package:events_emitter/events_emitter.dart';
import 'package:SpendingMonitor/dao/account_dao.dart';
import 'package:SpendingMonitor/events.dart';
import 'package:SpendingMonitor/model/account.model.dart';
import 'package:SpendingMonitor/helpers/currency.helper.dart';
import 'package:SpendingMonitor/theme/app_spacing.dart';
import 'package:SpendingMonitor/widgets/app/app_card.dart';
import 'package:SpendingMonitor/widgets/app/app_fab.dart';
import 'package:SpendingMonitor/widgets/app/app_scaffold.dart';
import 'package:SpendingMonitor/widgets/app/empty_state_widget.dart';
import 'package:SpendingMonitor/widgets/app/section_header.dart';
import 'package:SpendingMonitor/widgets/dialog/account_form.dialog.dart';
import 'package:SpendingMonitor/widgets/dialog/confirm.modal.dart';
import 'package:flutter/material.dart';
import 'package:SpendingMonitor/screens/accounts/wallet_detail.screen.dart';

String maskAccount(String value, [int lastLength = 4]) {
  if (value.length < lastLength) return value;
  final maskedLength = value.length - lastLength;
  return value.substring(0, maskedLength).replaceAll(RegExp(r'\S'), 'X') + value.substring(maskedLength);
}

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final AccountDao _accountDao = AccountDao();
  EventListener? _accountEventListener;
  List<Account> _accounts = [];

  Future<void> loadData() async {
    final accounts = await _accountDao.find(withSummery: true);
    if (!mounted) return;
    setState(() {
      _accounts = accounts;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();

    _accountEventListener = globalEvent.on('account_update', (_) {
      loadData();
    });
  }

  @override
  void dispose() {
    _accountEventListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalBalance = _accounts.fold<num>(0, (sum, account) => sum + (account.balance ?? 0));
    final totalIncome = _accounts.fold<num>(0, (sum, account) => sum + (account.income ?? 0));
    final totalExpense = _accounts.fold<num>(0, (sum, account) => sum + (account.expense ?? 0));

    return AppScaffold(
      appBar: AppBar(
        title: Text('Tổng quan ví', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
      ),
      padding: EdgeInsets.zero,
      floatingActionButton: AppFAB(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AccountForm(),
          );
        },
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.25),
                          blurRadius: 30,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onPrimary.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_outlined,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onPrimary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${_accounts.length} ví đang hoạt động',
                                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Tổng tài sản',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimary.withOpacity(0.8)),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          CurrencyHelper.format(totalBalance.toDouble()),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            _SummaryPill(
                              label: 'Thu vào',
                              value: CurrencyHelper.format(totalIncome.toDouble()),
                              icon: Icons.south_east,
                              background: theme.colorScheme.onPrimary.withOpacity(0.18),
                              foreground: theme.colorScheme.onPrimary,
                            ),
                            _SummaryPill(
                              label: 'Chi ra',
                              value: CurrencyHelper.format(totalExpense.toDouble()),
                              icon: Icons.north_east,
                              background: theme.colorScheme.onPrimary.withOpacity(0.18),
                              foreground: theme.colorScheme.onPrimary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Theo dõi chi tiêu theo ví để nhận báo cáo chính xác hơn.',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SectionHeader(
                    title: 'Danh sách ví',
                    subtitle: _accounts.isEmpty
                        ? 'Chưa có tài khoản nào'
                        : '${_accounts.length} tài khoản đang hoạt động',
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
          if (_accounts.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: EmptyStateWidget(
                  title: 'Chưa có tài khoản',
                  description: 'Tạo ví đầu tiên để bắt đầu theo dõi tài chính.',
                  ctaLabel: 'Tạo ví mới',
                  onCta: () {
                    showDialog(
                      context: context,
                      builder: (_) => AccountForm(),
                    );
                  },
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
              sliver: SliverList.builder(
                itemCount: _accounts.length,
                itemBuilder: (context, index) {
                  final account = _accounts[index];

                  final name = account.name.isNotEmpty ? account.name : 'Không tên';
                  final balance = account.balance ?? 0;
                  final income = account.income ?? 0;
                  final expense = account.expense ?? 0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _AccountCard(
                      account: account,
                      name: name,
                      balance: balance,
                      income: income,
                      expense: expense,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WalletDetailScreen(account: account),
                          ),
                        );
                      },
                      onEdit: () {
                        showDialog(
                          context: context,
                          builder: (_) => AccountForm(account: account),
                        );
                      },
                      onDelete: () async {
                        if (account.id == null) return;
                        ConfirmModal.showConfirmDialog(
                          context,
                          title: 'Xóa tài khoản?',
                          content: const Text('Mọi giao dịch liên quan sẽ bị xóa'),
                          onConfirm: () async {
                            Navigator.pop(context);
                            await _accountDao.delete(account.id!);
                            globalEvent.emit('account_update');
                          },
                          onCancel: () {
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final Account account;
  final String name;
  final num balance;
  final num income;
  final num expense;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _AccountCard({
    required this.account,
    required this.name,
    required this.balance,
    required this.income,
    required this.expense,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final balanceValue = CurrencyHelper.format(balance.toDouble());
    final incomeValue = CurrencyHelper.format(income.toDouble());
    final expenseValue = CurrencyHelper.format(expense.toDouble());
    final balanceTone = balance >= 0 ? theme.colorScheme.primary : theme.colorScheme.error;
    final accountNumber =
        account.accountNumber.isNotEmpty ? maskAccount(account.accountNumber) : 'Chưa có số tài khoản';
    final holderName = account.holderName.isNotEmpty ? account.holderName : 'Chủ ví chưa cập nhật';

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: account.color.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(account.icon, color: account.color, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (account.isDefault ?? false)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Mặc định',
                              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      holderName,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      accountNumber,
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<int>(
                onSelected: (value) async {
                  if (value == 1) {
                    if (onEdit != null) onEdit!();
                  } else if (value == 2) {
                    if (onDelete != null) onDelete!();
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 1, child: Text('Chỉnh sửa')),
                  PopupMenuItem(value: 2, child: Text('Xóa')),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                'Số dư hiện tại',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const Spacer(),
              Text(
                balanceValue,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: balanceTone),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: theme.colorScheme.outline.withOpacity(0.4)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  context,
                  icon: Icons.arrow_downward,
                  label: 'Thu vào',
                  amount: incomeValue,
                  background: theme.colorScheme.surfaceVariant,
                  iconColor: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildMetric(
                  context,
                  icon: Icons.arrow_upward,
                  label: 'Chi ra',
                  amount: expenseValue,
                  background: theme.colorScheme.surfaceVariant,
                  iconColor: theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  income >= expense ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: income >= expense ? theme.colorScheme.secondary : theme.colorScheme.error,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    income >= expense ? 'Ví này đang tăng trưởng tốt' : 'Chi tiêu tăng so với tháng trước',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String amount,
    required Color background,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: AppSpacing.xs),
              Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            amount,
            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color background;
  final Color foreground;

  const _SummaryPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: foreground),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            value,
            style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: foreground),
          ),
        ],
      ),
    );
  }
}
