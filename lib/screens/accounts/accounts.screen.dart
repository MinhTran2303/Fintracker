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

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: account.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(account.icon, color: account.color, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
          Text(
            CurrencyHelper.format(balance.toDouble()),
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Số dư hiện tại', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _buildChip(
                context,
                icon: Icons.arrow_downward,
                label: 'Thu',
                amount: income,
                background: theme.colorScheme.secondary.withOpacity(0.12),
                iconColor: theme.colorScheme.secondary,
              ),
              _buildChip(
                context,
                icon: Icons.arrow_upward,
                label: 'Chi',
                amount: expense,
                background: theme.colorScheme.tertiary.withOpacity(0.12),
                iconColor: theme.colorScheme.tertiary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            income > expense ? 'Ví này đang tăng trưởng tốt' : 'Chi tiêu tăng so với tháng trước',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required num amount,
    required Color background,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$label: ${CurrencyHelper.format(amount.toDouble())}',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}
