import 'package:fintracker/dao/account_dao.dart';
import 'package:fintracker/events.dart';
import 'package:fintracker/model/account.model.dart';
import 'package:fintracker/theme/app_spacing.dart';
import 'package:fintracker/widgets/app/app_text_field.dart';
import 'package:fintracker/widgets/app/icon_color_picker.dart';
import 'package:fintracker/widgets/buttons/button.dart';
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
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.account != null ? 'Chỉnh sửa ví' : 'Ví mới',
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      insetPadding: const EdgeInsets.all(20),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Điền thông tin ví để quản lý dòng tiền chính xác hơn.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          color: _account!.color,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(_account!.icon, color: Colors.white),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppTextField(
                          label: 'Tên ví',
                          hintText: 'Tên tài khoản',
                          initialValue: _account!.name,
                          onChanged: (text) => setState(() => _account!.name = text),
                        ),
                      ),
                    ],
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
                  const SizedBox(height: AppSpacing.lg),
                  IconColorPicker(
                    selectedColor: _account!.color,
                    selectedIcon: _account!.icon,
                    onColorChanged: (color) => setState(() => _account!.color = color),
                    onIconChanged: (icon) => setState(() => _account!.icon = icon),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Lưu',
              onPressed: () => onSave(context),
              variant: AppButtonVariant.primary,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
