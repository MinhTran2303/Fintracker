import 'package:SpendingMonitor/dao/category_dao.dart';
import 'package:SpendingMonitor/events.dart';
import 'package:SpendingMonitor/model/category.model.dart';
import 'package:SpendingMonitor/theme/app_spacing.dart';
import 'package:SpendingMonitor/widgets/app/app_card.dart';
import 'package:SpendingMonitor/widgets/app/app_text_field.dart';
import 'package:SpendingMonitor/widgets/app/icon_color_picker.dart';
import 'package:SpendingMonitor/widgets/buttons/button.dart';
import 'package:SpendingMonitor/widgets/currency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef Callback = void Function();

class CategoryForm extends StatefulWidget {
  final Category? category;
  final Callback? onSave;

  const CategoryForm({super.key, this.category, this.onSave});

  @override
  State<StatefulWidget> createState() => _CategoryForm();
}

class _CategoryForm extends State<CategoryForm> {
  final CategoryDao _categoryDao = CategoryDao();
  Category _category = Category(name: '', icon: Icons.wallet_outlined, color: Colors.pink);

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _category = widget.category ?? Category(name: '', icon: Icons.wallet_outlined, color: Colors.pink);
    }
  }

  void onSave(BuildContext context) async {
    await _categoryDao.upsert(_category);
    if (widget.onSave != null) {
      widget.onSave!();
    }
    Navigator.pop(context);
    globalEvent.emit('category_update');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                  child: Icon(_category.icon, color: _category.color, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.category != null ? 'Chỉnh sửa danh mục' : 'Danh mục mới',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Tạo nhóm chi tiêu để quản lý ngân sách.',
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
                    label: 'Tên danh mục',
                    hintText: 'Nhập tên danh mục',
                    initialValue: _category.name,
                    onChanged: (text) => setState(() => _category.name = text),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Ngân sách',
                    hintText: 'Nhập ngân sách',
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
                    ],
                    initialValue: _category.budget == null ? '' : _category.budget.toString(),
                    prefix: CurrencyText(null),
                    onChanged: (text) {
                      setState(() {
                        _category.budget = double.parse(text.isEmpty ? '0' : text);
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            IconColorPicker(
              selectedColor: _category.color,
              selectedIcon: _category.icon,
              onColorChanged: (color) => setState(() => _category.color = color),
              onIconChanged: (icon) => setState(() => _category.icon = icon),
            ),
          ],
        ),
      ),
      actions: [
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
    );
  }
}
