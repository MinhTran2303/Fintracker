import 'package:currency_picker/currency_picker.dart';
import 'package:SpendingMonitor/bloc/cubit/app_cubit.dart';
import 'package:SpendingMonitor/theme/app_spacing.dart';
import 'package:SpendingMonitor/widgets/app/app_card.dart';
import 'package:SpendingMonitor/widgets/app/app_scaffold.dart';
import 'package:SpendingMonitor/widgets/app/app_text_field.dart';
import 'package:SpendingMonitor/widgets/app/section_header.dart';
import 'package:SpendingMonitor/widgets/buttons/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  bool get _isEnglish => context.watch<AppCubit>().state.languageCode == 'en';

  String _t(String vi, String en) => _isEnglish ? en : vi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      appBar: AppBar(
        title: Text(_t('Cài đặt', 'Settings'), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          SectionHeader(
            title: _t('Hồ sơ', 'Profile'),
            subtitle: _t('Cá nhân hóa trải nghiệm của bạn', 'Personalize your experience'),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: ListTile(
              leading: _SettingsIcon(icon: Icons.person_outline, color: theme.colorScheme.primary),
              title: Text(_t('Tên', 'Name'), style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              subtitle: BlocBuilder<AppCubit, AppState>(
                builder: (context, state) {
                  return Text(
                    state.username ?? _t('Chưa đặt', 'Not set'),
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  );
                },
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurfaceVariant),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController controller =
                        TextEditingController(text: context.read<AppCubit>().state.username);
                    return AlertDialog(
                      title: Text(_t('Cập nhật tên', 'Update name'), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      content: AppTextField(
                        controller: controller,
                        label: _t('Tên', 'Name'),
                        hintText: _t('Nhập tên của bạn', 'Enter your name'),
                      ),
                      actions: [
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: _t('Hủy', 'Cancel'),
                                variant: AppButtonVariant.secondary,
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: AppButton(
                                label: _t('Lưu', 'Save'),
                                onPressed: () {
                                  if (controller.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(_t('Vui lòng nhập tên', 'Please enter your name'))),
                                    );
                                  } else {
                                    context.read<AppCubit>().updateUsername(controller.text);
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(
            title: _t('Ngôn ngữ', 'Language'),
            subtitle: _t('Chọn ngôn ngữ hiển thị', 'Choose display language'),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: ListTile(
              leading: _SettingsIcon(icon: Icons.language, color: theme.colorScheme.primary),
              title: Text(_t('Ngôn ngữ', 'Language'), style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              subtitle: BlocBuilder<AppCubit, AppState>(
                builder: (context, state) {
                  return Text(
                    state.languageCode == 'en' ? 'English' : 'Tiếng Việt',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  );
                },
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurfaceVariant),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    final selected = context.watch<AppCubit>().state.languageCode;
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RadioListTile<String>(
                            value: 'vi',
                            groupValue: selected,
                            title: Text(_t('Tiếng Việt', 'Vietnamese')),
                            onChanged: (value) {
                              if (value != null) {
                                context.read<AppCubit>().updateLanguageCode(value);
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                          RadioListTile<String>(
                            value: 'en',
                            groupValue: selected,
                            title: const Text('English'),
                            onChanged: (value) {
                              if (value != null) {
                                context.read<AppCubit>().updateLanguageCode(value);
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(
            title: _t('Tiền tệ', 'Currency'),
            subtitle: _t('Thiết lập đơn vị hiển thị', 'Set display unit'),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: ListTile(
              leading: _SettingsIcon(icon: Icons.currency_exchange, color: theme.colorScheme.primary),
              title: Text(_t('Tiền tệ', 'Currency'), style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              subtitle: BlocBuilder<AppCubit, AppState>(
                builder: (context, state) {
                  Currency? currency;
                  try {
                    currency = state.currency == null ? null : CurrencyService().findByCode(state.currency!);
                  } catch (_) {
                    currency = null;
                  }
                  return Text(
                    currency?.name ?? _t('Không xác định', 'Unknown'),
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  );
                },
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurfaceVariant),
              onTap: () {
                showCurrencyPicker(
                  context: context,
                  onSelect: (Currency currency) {
                    context.read<AppCubit>().updateCurrency(currency.code);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SettingsIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
