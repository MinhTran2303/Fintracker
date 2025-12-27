import 'package:events_emitter/events_emitter.dart';
import 'package:fintracker/dao/category_dao.dart';
import 'package:fintracker/events.dart';
import 'package:fintracker/model/category.model.dart';
import 'package:fintracker/theme/colors.dart';
import 'package:fintracker/helpers/currency.helper.dart';
import 'package:fintracker/widgets/dialog/category_form.dialog.dart';
import 'package:fintracker/theme/background.dart';
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

    _categoryEventListener = globalEvent.on("category_update", (data){
      debugPrint("categories are changed");
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
    final isDark = theme.brightness == Brightness.dark;
    final cardSurface = theme.colorScheme.surface;
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = theme.colorScheme.onSurfaceVariant;
    return Scaffold(
        appBar: AppBar(
          title: Text("Ngân sách", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
        ),
        body: Container(
          decoration: pageBackgroundDecoration(context),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: _categories.length,
            itemBuilder: (builder, index) {
              Category category = _categories[index];
              double expenseProgress = (category.expense ?? 0) / (category.budget ?? 0);
              bool hasBudget = category.budget != null && category.budget! > 0;
              bool overBudget = hasBudget && expenseProgress > 1.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: category.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              category.icon,
                              color: category.color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              category.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: primaryTextColor,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
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
                            icon: Icon(
                              Icons.more_vert,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (hasBudget) ...[
                        // Budget Progress
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${CurrencyHelper.format(category.expense ?? 0, locale: 'vi_VN')} / ${CurrencyHelper.format(category.budget ?? 0, locale: 'vi_VN')}",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: secondaryTextColor,
                                ),
                              ),
                            ),
                            Text(
                              "${(expenseProgress * 100).toStringAsFixed(0)}%",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: overBudget ? const Color(0xFFFB923C) : const Color(0xFF22C55E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 8,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: expenseProgress.clamp(0.0, 1.0),
                              backgroundColor: theme.colorScheme.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                overBudget ? const Color(0xFFFB923C) : const Color(0xFF22C55E),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // No Budget
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFFF1F5F9) : theme.colorScheme.surfaceVariant.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Chưa đặt ngân sách",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w500,
                            ),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(context: context, builder: (builder) => const CategoryForm());
          },
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add),
        ),
    );
  }
}
