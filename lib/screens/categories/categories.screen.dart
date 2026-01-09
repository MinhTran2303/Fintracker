import 'package:events_emitter/events_emitter.dart';
import 'package:fintracker/dao/category_dao.dart';
import 'package:fintracker/events.dart';
import 'package:fintracker/model/category.model.dart';
import 'package:fintracker/helpers/currency.helper.dart';
import 'package:fintracker/theme/app_spacing.dart';
import 'package:fintracker/widgets/app/app_card.dart';
import 'package:fintracker/widgets/app/app_fab.dart';
import 'package:fintracker/widgets/app/app_scaffold.dart';
import 'package:fintracker/widgets/app/empty_state_widget.dart';
import 'package:fintracker/widgets/app/section_header.dart';
import 'package:fintracker/widgets/dialog/category_form.dialog.dart';
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
    return AppScaffold(
      appBar: AppBar(
        title: Text('Ngân sách', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
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
                                      color: category.color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
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
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
                                    backgroundColor: theme.colorScheme.surfaceVariant,
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
