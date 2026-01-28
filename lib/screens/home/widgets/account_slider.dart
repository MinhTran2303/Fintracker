import 'package:fintracker/model/account.model.dart';
import 'package:fintracker/theme/app_radius.dart';
import 'package:fintracker/theme/app_spacing.dart';
import 'package:fintracker/widgets/currency.dart';
import 'package:flutter/material.dart';

class AccountsSlider extends StatefulWidget {
  final List<Account> accounts;
  const AccountsSlider({super.key, required this.accounts});
  @override
  State<StatefulWidget> createState() => _AccountSlider();
}

class _AccountSlider extends State<AccountsSlider> {
  final PageController _pageController = PageController();
  int _selected = 0;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 180,
          child: PageView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.accounts.length,
            controller: _pageController,
            onPageChanged: (int index) {
              setState(() {
                _selected = index;
              });
            },
            itemBuilder: (BuildContext builder, int index) {
              Account account = widget.accounts[index];
              return FractionallySizedBox(
                widthFactor: 1 / _pageController.viewportFraction,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    color: theme.colorScheme.surface,
                    border: Border.all(color: theme.colorScheme.outline.withOpacity(0.6)),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                          ),
                          child: Text(
                            account.name,
                            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        CurrencyText(
                          account.balance ?? 0,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Số dư hiện tại',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  account.holderName,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  account.name,
                                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                              ),
                              child: Icon(account.icon, color: account.color, size: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.accounts.length > 1) const SizedBox(height: AppSpacing.sm),
        if (widget.accounts.length > 1)
          SizedBox(
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.accounts.length, (index) {
                return AnimatedContainer(
                  curve: Curves.ease,
                  height: 6,
                  duration: const Duration(milliseconds: 200),
                  width: _selected == index ? 20 : 6,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(_selected == index ? 1 : 0.5),
                    borderRadius: BorderRadius.circular(60),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
