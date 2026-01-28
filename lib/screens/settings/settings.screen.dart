import 'package:currency_picker/currency_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fintracker/bloc/cubit/app_cubit.dart';
import 'package:fintracker/helpers/db.helper.dart';
import 'package:fintracker/theme/app_spacing.dart';
import 'package:fintracker/widgets/app/app_card.dart';
import 'package:fintracker/widgets/app/app_scaffold.dart';
import 'package:fintracker/widgets/app/app_text_field.dart';
import 'package:fintracker/widgets/app/section_header.dart';
import 'package:fintracker/widgets/buttons/button.dart';
import 'package:fintracker/widgets/dialog/confirm.modal.dart';
import 'package:fintracker/widgets/dialog/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      appBar: AppBar(
        title: Text('Cài đặt', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          const SectionHeader(
            title: 'Hồ sơ',
            subtitle: 'Cá nhân hóa trải nghiệm của bạn',
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: ListTile(
              leading: _SettingsIcon(icon: Icons.person_outline, color: theme.colorScheme.primary),
              title: Text('Tên', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              subtitle: BlocBuilder<AppCubit, AppState>(
                builder: (context, state) {
                  return Text(
                    state.username ?? 'Chưa đặt',
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
                      title: Text('Cập nhật tên', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      content: AppTextField(
                        controller: controller,
                        label: 'Tên',
                        hintText: 'Nhập tên của bạn',
                      ),
                      actions: [
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: 'Hủy',
                                variant: AppButtonVariant.secondary,
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: AppButton(
                                label: 'Lưu',
                                onPressed: () {
                                  if (controller.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Vui lòng nhập tên')),
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
          const SectionHeader(
            title: 'Tiền tệ',
            subtitle: 'Thiết lập đơn vị hiển thị',
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: ListTile(
              leading: _SettingsIcon(icon: Icons.currency_exchange, color: theme.colorScheme.primary),
              title: Text('Tiền tệ', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              subtitle: BlocBuilder<AppCubit, AppState>(
                builder: (context, state) {
                  Currency? currency;
                  try {
                    currency = state.currency == null ? null : CurrencyService().findByCode(state.currency!);
                  } catch (_) {
                    currency = null;
                  }
                  return Text(
                    currency?.name ?? 'Không xác định',
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
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(
            title: 'Sao lưu & khôi phục',
            subtitle: 'Xuất và nhập dữ liệu cục bộ',
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              children: [
                ListTile(
                  leading: _SettingsIcon(icon: Icons.download, color: theme.colorScheme.primary),
                  title: Text('Xuất dữ liệu', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text('Xuất ra tệp', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  onTap: () async {
                    ConfirmModal.showConfirmDialog(
                      context,
                      title: 'Bạn có chắc chắn?',
                      content: const Text('Muốn xuất tất cả dữ liệu ra tệp'),
                      onConfirm: () async {
                        Navigator.of(context).pop();
                        LoadingModal.showLoadingDialog(context, content: const Text('Đang xuất dữ liệu, vui lòng chờ'));
                        await export().then((value) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('Tệp đã được lưu tại $value')));
                        }).catchError((err) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(content: Text('Đã xảy ra lỗi khi xuất dữ liệu')));
                        }).whenComplete(() {
                          Navigator.of(context).pop();
                        });
                      },
                      onCancel: () {
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
                Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.6)),
                ListTile(
                  leading: _SettingsIcon(icon: Icons.upload, color: theme.colorScheme.primary),
                  title: Text('Nhập dữ liệu', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text('Nhập từ tệp sao lưu', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  onTap: () async {
                    try {
                      FilePickerResult? pick;
                      try {
                        pick = await FilePicker.platform.pickFiles(
                          dialogTitle: 'Chọn tệp',
                          allowMultiple: false,
                          allowCompression: false,
                          type: FileType.custom,
                          allowedExtensions: ['json'],
                        );
                      } on Exception catch (e) {
                        debugPrint('FilePicker custom filter failed, falling back to any: $e');
                        pick = await FilePicker.platform.pickFiles(
                          dialogTitle: 'Chọn tệp (mọi định dạng)',
                          allowMultiple: false,
                          allowCompression: false,
                          type: FileType.any,
                        );
                      }

                      if (pick == null || pick.files.isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Vui lòng chọn tệp')));
                        return;
                      }

                      PlatformFile file = pick.files.first;

                      final name = file.name.toLowerCase();
                      if (!name.endsWith('.json')) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Vui lòng chọn tệp .json')));
                        return;
                      }

                      ConfirmModal.showConfirmDialog(
                        context,
                        title: 'Bạn có chắc chắn?',
                        content: const Text(
                          'Tất cả dữ liệu thanh toán, danh mục và tài khoản sẽ bị xóa và thay thế bằng thông tin nhập từ bản sao lưu.',
                        ),
                        onConfirm: () async {
                          Navigator.of(context).pop();
                          LoadingModal.showLoadingDialog(context, content: const Text('Đang nhập dữ liệu, vui lòng chờ'));
                          try {
                            await import(file.path!);
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(content: Text('Đã nhập thành công.')));
                            Navigator.of(context).pop();
                          } catch (err) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(content: Text('Đã xảy ra lỗi khi nhập dữ liệu')));
                            Navigator.of(context).pop();
                          }
                        },
                        onCancel: () {
                          Navigator.of(context).pop();
                        },
                      );
                    } catch (err) {
                      debugPrint('FilePicker error: $err');
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Không thể mở bộ chọn tệp trên thiết bị này')));
                    }
                  },
                ),
              ],
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
