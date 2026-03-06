import 'package:events_emitter/events_emitter.dart';
import 'package:SpendingMonitor/dao/category_dao.dart';
import 'package:SpendingMonitor/events.dart';
import 'package:SpendingMonitor/model/category.model.dart';
import 'package:SpendingMonitor/helpers/currency.helper.dart';
import 'package:SpendingMonitor/l10n/app_text.dart';
import 'package:SpendingMonitor/theme/app_spacing.dart';
import 'package:SpendingMonitor/widgets/app/app_card.dart';
import 'package:SpendingMonitor/widgets/app/app_fab.dart';
import 'package:SpendingMonitor/widgets/app/app_scaffold.dart';
import 'package:SpendingMonitor/widgets/app/empty_state_widget.dart';
import 'package:SpendingMonitor/widgets/app/section_header.dart';
import 'package:SpendingMonitor/widgets/dialog/category_form.dialog.dart';
import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryDao _categoryDao = CategoryDao();
  EventListener? _categoryEventListener;
  List<Category> _categories = [];

  void loadData() async {
    List<Category> categories = await _categoryDao.find();
    setState(() {
      _categories = categories;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();

    _categoryEventListener = globalEvent.on('category_update', (data) {
      debugPrint('categories are changed');
      loadData();
    });
  }

  @override
  void dispose() {
    _categoryEventListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalBudget = _categories.fold<num>(0, (sum, category) => sum + (category.budget ?? 0));
    final totalExpense = _categories.fold<num>(0, (sum, category) => sum + (category.expense ?? 0));
    return AppScaffold(
      appBar: AppBar(
        title: Text(tr(context, 'Ngân sách', 'Budget'), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      floatingActionButton: AppFAB(
        onPressed: () {
          showDialog(context: context, builder: (builder) => const CategoryForm());
        },
      ),
      body: _categories.isEmpty
          ? Center(
              child: EmptyStateWidget(
                title: tr(context, 'Chưa có danh mục', 'No categories yet'),
                description: tr(context, 'Tạo danh mục để theo dõi ngân sách của bạn.', 'Create categories to track your budget.'),
                ctaLabel: tr(context, 'Tạo danh mục', 'Create category'),
                onCta: () {
                  showDialog(context: context, builder: (builder) => const CategoryForm());
                },
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tr(context, 'Tổng ngân sách', 'Total budget'), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              CurrencyHelper.format(totalBudget.toDouble()),
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          children: [
                            _BudgetMiniStat(
                              label: tr(context, 'Đã chi', 'Spent'),
                              value: CurrencyHelper.format(totalExpense.toDouble()),
                              color: theme.colorScheme.tertiary,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _BudgetMiniStat(
                              label: tr(context, 'Còn lại', 'Remaining'),
                              value: CurrencyHelper.format((totalBudget - totalExpense).toDouble()),
                              color: theme.colorScheme.secondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SectionHeader(
                  title: tr(context, 'Danh mục chi tiêu', 'Spending categories'),
                  subtitle: tr(context, '${_categories.length} danh mục', '${_categories.length} categories'),
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (builder, index) {
                      Category category = _categories[index];
                      bool hasBudget = category.budget != null && category.budget! > 0;
                      final budgetValue = (category.budget ?? 0).toDouble();
                      final expenseValue = (category.expense ?? 0).toDouble();
                      final remainingValue = (budgetValue - expenseValue).clamp(0, double.infinity).toDouble();
                      double expenseProgress = hasBudget ? (expenseValue / budgetValue) : 0;
                      bool overBudget = hasBudget && expenseProgress > 1.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppSpacing.sm),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceVariant,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                                    ),
                                    child: Icon(
                                      category.icon,
                                      color: category.color,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          translateCategoryName(context, category.name),
                                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          tr(context, 'Theo dõi chi tiêu', 'Track spending'),
                                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) => Container(
                                          padding: const EdgeInsets.all(AppSpacing.md),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: Icon(Icons.edit, color: theme.colorScheme.primary),
                                                title: Text(tr(context, 'Chỉnh sửa', 'Edit')),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  showDialog(context: context, builder: (builder) => CategoryForm(category: category));
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              if (hasBudget) ...[
                                Wrap(
                                  spacing: AppSpacing.sm,
                                  runSpacing: AppSpacing.sm,
                                  children: [
                                    _CategoryTag(
                                      label: overBudget ? tr(context, 'Vượt ngân sách', 'Over budget') : tr(context, 'Trong ngân sách', 'On track'),
                                      backgroundColor: overBudget
                                          ? theme.colorScheme.errorContainer
                                          : theme.colorScheme.secondaryContainer,
                                      textColor: overBudget ? theme.colorScheme.onErrorContainer : theme.colorScheme.onSecondaryContainer,
                                    ),
                                    _CategoryTag(
                                      label: tr(context, 'Ngân sách: ${CurrencyHelper.format(budgetValue)}', 'Budget: ${CurrencyHelper.format(budgetValue)}'),
                                      backgroundColor: theme.colorScheme.surfaceVariant,
                                      textColor: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _CategoryMetricTile(
                                        label: tr(context, 'Đã chi', 'Spent'),
                                        value: CurrencyHelper.format(expenseValue),
                                        highlightColor: theme.colorScheme.tertiary,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: _CategoryMetricTile(
                                        label: tr(context, 'Còn lại', 'Remaining'),
                                        value: CurrencyHelper.format(remainingValue),
                                        highlightColor: theme.colorScheme.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        tr(
                                          context,
                                          'Mức sử dụng ngân sách',
                                          'Budget usage',
                                        ),
                                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                      ),
                                    ),
                                    Text(
                                      "${(expenseProgress * 100).toStringAsFixed(0)}%",
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: overBudget ? theme.colorScheme.error : theme.colorScheme.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    minHeight: 8,
                                    value: expenseProgress.clamp(0.0, 1.0),
                                    backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.7),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      overBudget ? theme.colorScheme.error : theme.colorScheme.secondary,
                                    ),
                                  ),
                                ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    tr(context, 'Chưa đặt ngân sách', 'No budget set'),
                                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                  ),
                                ),
                              ],
                            ],
                          ),
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

class _BudgetMiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BudgetMiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
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

class _CategoryTag extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _CategoryTag({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CategoryMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color highlightColor;

  const _CategoryMetricTile({
    required this.label,
    required this.value,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: highlightColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
