import 'package:SpendingMonitor/dao/category_dao.dart';
import 'package:SpendingMonitor/events.dart';
import 'package:SpendingMonitor/l10n/app_text.dart';
import 'package:SpendingMonitor/model/category.model.dart';
import 'package:SpendingMonitor/theme/app_spacing.dart';
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
  Category _category = Category(name: '', iconCode: Icons.wallet_outlined.codePoint, colorValue: Colors.pink.value);

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _category = widget.category ?? Category(name: '', iconCode: Icons.wallet_outlined.codePoint, colorValue: Colors.pink.value);
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
    final isEditing = widget.category != null;

    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: _category.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _category.color.withOpacity(0.3)),
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
                        isEditing ? tr(context, 'Chỉnh sửa danh mục', 'Edit category') : tr(context, 'Danh mục mới', 'New category'),
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        tr(context, 'Tối giản, hiện đại và dễ dùng.', 'Minimal, modern and easy to use.'),
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.35),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                tr(
                  context,
                  _category.name.isEmpty ? 'Xem trước: Danh mục mới' : 'Xem trước: ${_category.name}',
                  _category.name.isEmpty ? 'Preview: New category' : 'Preview: ${_category.name}',
                ),
                style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionContainer(
              child: Column(
                children: [
                  AppTextField(
                    label: tr(context, 'Tên danh mục', 'Category name'),
                    hintText: tr(context, 'Ví dụ: Ăn uống, Mua sắm...', 'Example: Food, Shopping...'),
                    initialValue: _category.name,
                    onChanged: (text) => setState(() => _category.name = text),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: tr(context, 'Ngân sách', 'Budget'),
                    hintText: tr(context, 'Để trống nếu chưa đặt', 'Leave blank if no budget yet'),
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
            _SectionContainer(
              child: IconColorPicker(
                selectedColor: _category.color,
                selectedIcon: _category.icon,
                onColorChanged: (color) => setState(() => _category.color = color),
                onIconChanged: (icon) => setState(() => _category.icon = icon),
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      actions: [
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: tr(context, 'Hủy', 'Cancel'),
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppButton(
                label: tr(context, 'Lưu', 'Save'),
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

class _SectionContainer extends StatelessWidget {
  final Widget child;

  const _SectionContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.18)),
      ),
      child: child,
    );
  }
}
