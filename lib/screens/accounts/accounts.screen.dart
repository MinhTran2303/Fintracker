import 'package:events_emitter/events_emitter.dart';
import 'package:fintracker/dao/account_dao.dart';
import 'package:fintracker/events.dart';
import 'package:fintracker/model/account.model.dart';
import 'package:fintracker/helpers/currency.helper.dart';
import 'package:fintracker/theme/app_spacing.dart';
import 'package:fintracker/widgets/app/app_card.dart';
import 'package:fintracker/widgets/app/app_fab.dart';
import 'package:fintracker/widgets/app/app_scaffold.dart';
import 'package:fintracker/widgets/app/empty_state_widget.dart';
import 'package:fintracker/widgets/app/section_header.dart';
import 'package:fintracker/widgets/dialog/account_form.dialog.dart';
import 'package:fintracker/widgets/dialog/confirm.modal.dart';
import 'package:flutter/material.dart';
import 'package:fintracker/screens/accounts/wallet_detail.screen.dart';

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
        title: Text('Ví tiền', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      floatingActionButton: AppFAB(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AccountForm(),
          );
        },
      ),
      body: _accounts.isEmpty
          ? Center(
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
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Tổng tài sản',
                            style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${_accounts.length} ví',
                              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        CurrencyHelper.format(totalBalance.toDouble()),
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryTile(
                              label: 'Thu vào',
                              amount: totalIncome,
                              icon: Icons.south_east,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _SummaryTile(
                              label: 'Chi ra',
                              amount: totalExpense,
                              icon: Icons.north_east,
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
                  title: 'Danh sách ví',
                  subtitle: '${_accounts.length} tài khoản đang hoạt động',
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: ListView.builder(
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

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: account.color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(account.icon, color: account.color, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Số dư hiện tại',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Text(
                balanceValue,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: balanceTone),
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
              Expanded(
                child: _buildMetric(
                  context,
                  icon: Icons.arrow_downward,
                  label: 'Thu vào',
                  amount: incomeValue,
                  background: theme.colorScheme.secondary.withOpacity(0.12),
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
                  background: theme.colorScheme.tertiary.withOpacity(0.12),
                  iconColor: theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
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

class _SummaryTile extends StatelessWidget {
  final String label;
  final num amount;
  final IconData icon;
  final Color color;

  const _SummaryTile({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  CurrencyHelper.format(amount.toDouble()),
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
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
