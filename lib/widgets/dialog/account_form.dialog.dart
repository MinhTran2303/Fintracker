import 'package:SpendingMonitor/dao/account_dao.dart';
import 'package:SpendingMonitor/events.dart';
import 'package:SpendingMonitor/model/account.model.dart';
import 'package:SpendingMonitor/theme/app_spacing.dart';
import 'package:SpendingMonitor/widgets/app/app_card.dart';
import 'package:SpendingMonitor/widgets/app/app_text_field.dart';
import 'package:SpendingMonitor/widgets/app/icon_color_picker.dart';
import 'package:SpendingMonitor/widgets/buttons/button.dart';
import 'package:flutter/material.dart';

typedef Callback = void Function();

class AccountForm extends StatefulWidget {
  final Account? account;
  final Callback? onSave;

  const AccountForm({super.key, this.account, this.onSave});

  @override
  State<StatefulWidget> createState() => _AccountForm();
}

class _AccountForm extends State<AccountForm> {
  final AccountDao _accountDao = AccountDao();
  Account? _account;

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _account = Account(
        id: widget.account!.id,
        name: widget.account!.name,
        holderName: widget.account!.holderName,
        accountNumber: widget.account!.accountNumber,
        icon: widget.account!.icon,
        color: widget.account!.color,
      );
    } else {
      _account = Account(
        name: '',
        holderName: '',
        accountNumber: '',
        icon: Icons.account_circle,
        color: Colors.grey,
      );
    }
  }

  void onSave(BuildContext context) async {
    await _accountDao.upsert(_account!);
    if (widget.onSave != null) {
      widget.onSave!();
    }
    Navigator.pop(context);
    globalEvent.emit('account_update');
  }

  @override
  Widget build(BuildContext context) {
    if (_account == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final theme = Theme.of(context);

    return AlertDialog(
      scrollable: true,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(20),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(_account!.icon, color: _account!.color, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.account != null ? 'Chỉnh sửa ví' : 'Ví mới',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Thiết lập thông tin ví để theo dõi số dư.',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Column(
                children: [
                  AppTextField(
                    label: 'Tên ví',
                    hintText: 'Tên tài khoản',
                    initialValue: _account!.name,
                    onChanged: (text) => setState(() => _account!.name = text),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Tên chủ',
                    hintText: 'Nhập tên chủ tài khoản',
                    initialValue: _account!.holderName,
                    onChanged: (text) => setState(() => _account!.holderName = text),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Số tài khoản',
                    hintText: 'Nhập số tài khoản',
                    initialValue: _account!.accountNumber,
                    onChanged: (text) => setState(() => _account!.accountNumber = text),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            IconColorPicker(
              selectedColor: _account!.color,
              selectedIcon: _account!.icon,
              onColorChanged: (color) => setState(() => _account!.color = color),
              onIconChanged: (icon) => setState(() => _account!.icon = icon),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Hủy',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: 'Lưu',
                    onPressed: () => onSave(context),
                    variant: AppButtonVariant.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
