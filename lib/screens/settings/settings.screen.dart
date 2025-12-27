import 'package:currency_picker/currency_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fintracker/bloc/cubit/app_cubit.dart';
import 'package:fintracker/helpers/color.helper.dart';
import 'package:fintracker/helpers/db.helper.dart';
import 'package:fintracker/widgets/buttons/button.dart';
import 'package:fintracker/widgets/dialog/confirm.modal.dart';
import 'package:fintracker/widgets/dialog/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:fintracker/theme/background.dart';
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardSurface = theme.colorScheme.surface;
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = theme.colorScheme.onSurfaceVariant;
    return Scaffold(
      appBar: AppBar(
        title: Text("Cài đặt", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: primaryTextColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: pageBackgroundDecoration(context),
        child: ListView(
          children: [
            // Profile Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Hồ sơ",
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            // Profile tile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Material(
                color: cardSurface,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  leading: Icon(Icons.person_outline, color: theme.colorScheme.onPrimary),
                  title: Text(
                    "Tên",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: primaryTextColor,
                    ),
                  ),
                  subtitle: BlocBuilder<AppCubit, AppState>(
                    builder: (context, state) {
                      return Text(
                        state.username ?? "Chưa đặt",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: secondaryTextColor,
                        ),
                      );
                    },
                  ),
                  trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        TextEditingController controller = TextEditingController(text: context.read<AppCubit>().state.username);
                        return AlertDialog(
                          title: Text(
                            "Hồ sơ",
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: primaryTextColor),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Chúng tôi nên gọi bạn là gì?",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: primaryTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: controller,
                                decoration: InputDecoration(
                                  labelText: "Tên",
                                  hintText: "Nhập tên của bạn",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("Hủy"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (controller.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Vui lòng nhập tên")),
                                  );
                                } else {
                                  context.read<AppCubit>().updateUsername(controller.text);
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text("Lưu"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),

            // Currency Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Tiền tệ",
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            // Currency tile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Material(
                color: cardSurface,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  leading: Icon(Icons.currency_exchange, color: theme.colorScheme.onPrimary),
                  title: Text(
                    "Tiền tệ",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: primaryTextColor,
                    ),
                  ),
                  subtitle: BlocBuilder<AppCubit, AppState>(
                    builder: (context, state) {
                      Currency? currency;
                      try {
                        currency = state.currency == null ? null : CurrencyService().findByCode(state.currency!);
                      } catch (_) {
                        currency = null;
                      }
                      return Text(
                        currency?.name ?? "Không xác định",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: secondaryTextColor,
                        ),
                      );
                    },
                  ),
                  trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
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
            ),
            Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),

            // Backup Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sao lưu",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Xuất và khôi phục dữ liệu cục bộ",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            // Export tile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Material(
                color: cardSurface,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  leading: Icon(Icons.download, color: theme.colorScheme.onPrimary),
                  title: Text(
                    "Xuất dữ liệu",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: primaryTextColor,
                    ),
                  ),
                  subtitle: Text(
                    "Xuất ra tệp",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                  trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                  onTap: () async {
                    ConfirmModal.showConfirmDialog(
                      context,
                      title: "Bạn có chắc chắn?",
                      content: const Text("Muốn xuất tất cả dữ liệu ra tệp"),
                      onConfirm: () async {
                        Navigator.of(context).pop();
                        LoadingModal.showLoadingDialog(context, content: const Text("Đang xuất dữ liệu, vui lòng chờ"));
                        await export().then((value) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tệp đã được lưu tại $value")));
                        }).catchError((err) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xảy ra lỗi khi xuất dữ liệu")));
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
              ),
            ),
            // Import tile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Material(
                color: cardSurface,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  leading: Icon(Icons.upload, color: theme.colorScheme.onPrimary),
                  title: Text(
                    "Nhập dữ liệu",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: primaryTextColor,
                    ),
                  ),
                  subtitle: Text(
                    "Nhập từ tệp sao lưu",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                  trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                  onTap: () async {
                    // Robust file picking: try custom json filter first, if unsupported fall back to any
                    try {
                      FilePickerResult? pick;
                      try {
                        pick = await FilePicker.platform.pickFiles(
                          dialogTitle: "Chọn tệp",
                          allowMultiple: false,
                          allowCompression: false,
                          type: FileType.custom,
                          allowedExtensions: ["json"],
                        );
                      } on Exception catch (e) {
                        // Some platforms may not support custom filters. Fallback to any.
                        debugPrint('FilePicker custom filter failed, falling back to any: $e');
                        pick = await FilePicker.platform.pickFiles(
                          dialogTitle: "Chọn tệp (mọi định dạng)",
                          allowMultiple: false,
                          allowCompression: false,
                          type: FileType.any,
                        );
                      }

                      if (pick == null || pick.files.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn tệp")));
                        return;
                      }

                      PlatformFile file = pick.files.first;

                      // Validate extension if available
                      final name = file.name.toLowerCase();
                      if (!name.endsWith('.json')) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn tệp .json")));
                        return;
                      }

                      ConfirmModal.showConfirmDialog(
                        context,
                        title: "Bạn có chắc chắn?",
                        content: const Text("Tất cả dữ liệu thanh toán, danh mục và tài khoản sẽ bị xóa và thay thế bằng thông tin nhập từ bản sao lưu."),
                        onConfirm: () async {
                          Navigator.of(context).pop();
                          LoadingModal.showLoadingDialog(context, content: const Text("Đang nhập dữ liệu, vui lòng chờ"));
                          try {
                            await import(file.path!);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã nhập thành công.")));
                            Navigator.of(context).pop();
                          } catch (err) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xảy ra lỗi khi nhập dữ liệu")));
                            Navigator.of(context).pop();
                          }
                        },
                        onCancel: () {
                          Navigator.of(context).pop();
                        },
                      );
                    } catch (err) {
                      debugPrint('FilePicker error: $err');
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Không thể mở bộ chọn tệp trên thiết bị này")));
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
