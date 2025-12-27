import 'package:events_emitter/events_emitter.dart';
import 'package:fintracker/dao/account_dao.dart';
import 'package:fintracker/events.dart';
import 'package:fintracker/model/account.model.dart';
import 'package:fintracker/theme/background.dart';
import 'package:fintracker/helpers/currency.helper.dart';
import 'package:fintracker/widgets/dialog/account_form.dialog.dart';
import 'package:fintracker/widgets/dialog/confirm.modal.dart';
import 'package:flutter/material.dart';
import 'package:fintracker/screens/accounts/wallet_detail.screen.dart';

String maskAccount(String value, [int lastLength = 4]) {
  if (value.length < lastLength) return value;
  final maskedLength = value.length - lastLength;
  return value
      .substring(0, maskedLength)
      .replaceAll(RegExp(r'\S'), 'X') +
      value.substring(maskedLength);
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
    // Use colorScheme tokens for text to ensure proper contrast in light/dark themes
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ví tiền',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: primaryTextColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryTextColor),
      ),
      body: Container(
        decoration: pageBackgroundDecoration(context),
        child: _accounts.isEmpty
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Chưa có tài khoản nào',
              style: theme.textTheme.titleMedium?.copyWith(
                color: secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
            : ListView.builder(
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: _accounts.length,
          itemBuilder: (context, index) {
            final account = _accounts[index];

            // keep logic unchanged; provide safe fallbacks
            final name = account.name.isNotEmpty ? account.name : 'Không tên';
            final balance = account.balance ?? 0;
            final income = account.income ?? 0;
            final expense = account.expense ?? 0;

            return _AccountCard(
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
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AccountForm(),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Account card extracted to keep UI tidy and responsive
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
    final cardSurface = theme.colorScheme.surface;
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = theme.colorScheme.onSurfaceVariant;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardSurface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 0.10),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withAlpha((0.2 * 255).round()),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        account.icon,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                      ),
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
              const SizedBox(height: 12),
              Text(
                CurrencyHelper.format((balance).toDouble()),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: primaryTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                'Số dư hiện tại',
                style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip(
                    context,
                    icon: Icons.arrow_downward,
                    label: 'Thu',
                    amount: income,
                    background: const Color(0xFFE6F9EE),
                    iconColor: const Color(0xFF22C55E),
                    amountColor: const Color(0xFF22C55E),
                    labelColor: secondaryTextColor,
                  ),
                  _buildChip(
                    context,
                    icon: Icons.arrow_upward,
                    label: 'Chi',
                    amount: expense,
                    background: const Color(0xFFFFF3EB),
                    iconColor: const Color(0xFFFB923C),
                    amountColor: const Color(0xFFFB923C),
                    labelColor: secondaryTextColor,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                income > expense ? 'Ví này đang tăng trưởng tốt' : 'Chi tiêu tăng so với tháng trước',
                style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor, fontStyle: FontStyle.italic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context,
      {required IconData icon,
      required String label,
      required num amount,
      required Color background,
      required Color iconColor,
      Color? amountColor,
      Color? labelColor}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    '$label:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: labelColor ?? theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    CurrencyHelper.format((amount).toDouble()),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: amountColor ?? iconColor,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
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
}
