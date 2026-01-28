import 'package:events_emitter/events_emitter.dart';
import 'package:SpendingMonitor/dao/category_dao.dart';
import 'package:SpendingMonitor/events.dart';
import 'package:SpendingMonitor/model/category.model.dart';
import 'package:SpendingMonitor/helpers/currency.helper.dart';
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
        title: Text('Ngân sách', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      floatingActionButton: AppFAB(
        onPressed: () {
          showDialog(context: context, builder: (builder) => const CategoryForm());
        },
      ),
      body: _categories.isEmpty
          ? Center(
              child: EmptyStateWidget(
                title: 'Chưa có danh mục',
                description: 'Tạo danh mục để theo dõi ngân sách của bạn.',
                ctaLabel: 'Tạo danh mục',
                onCta: () {
                  showDialog(context: context, builder: (builder) => const CategoryForm());
                },
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tổng ngân sách', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        CurrencyHelper.format(totalBudget.toDouble()),
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _BudgetStat(
                              label: 'Đã chi',
                              value: CurrencyHelper.format(totalExpense.toDouble()),
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _BudgetStat(
                              label: 'Còn lại',
                              value: CurrencyHelper.format((totalBudget - totalExpense).toDouble()),
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  title: 'Danh mục chi tiêu',
                  subtitle: '${_categories.length} danh mục',
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (builder, index) {
                      Category category = _categories[index];
                      double expenseProgress = (category.expense ?? 0) / (category.budget ?? 0);
                      bool hasBudget = category.budget != null && category.budget! > 0;
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
                                    child: Text(
                                      category.name,
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
                                                title: const Text('Chỉnh sửa'),
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${CurrencyHelper.format(category.expense ?? 0, locale: 'vi_VN')} / ${CurrencyHelper.format(category.budget ?? 0, locale: 'vi_VN')}",
                                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
                                    'Chưa đặt ngân sách',
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

class _BudgetStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BudgetStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
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
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
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
