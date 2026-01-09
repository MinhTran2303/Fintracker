import 'package:currency_picker/currency_picker.dart';
import 'package:fintracker/bloc/cubit/app_cubit.dart';
import 'package:fintracker/helpers/db.helper.dart';
import 'package:fintracker/theme/app_spacing.dart';
import 'package:fintracker/widgets/app/app_card.dart';
import 'package:fintracker/widgets/app/app_scaffold.dart';
import 'package:fintracker/widgets/app/app_text_field.dart';
import 'package:fintracker/widgets/buttons/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrencyPicWidget extends StatefulWidget {
  const CurrencyPicWidget({super.key});

  @override
  State<StatefulWidget> createState() => _CurrencyPicWidget();
}

class _CurrencyPicWidget extends State<CurrencyPicWidget> {
  final CurrencyService _currencyService = CurrencyService();
  String? _currency;
  String _keyword = '';

  List<Currency> filter() {
    if (_keyword.isEmpty) {
      return _currencyService.getAll();
    }
    return _currencyService
        .getAll()
        .where((element) => element.name.toLowerCase().contains(_keyword.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    AppCubit cubit = context.read<AppCubit>();
    setState(() {
      _currency = cubit.state.currency;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppCubit cubit = context.read<AppCubit>();
    return AppScaffold(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.currency_exchange, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Chọn loại tiền tệ',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Thiết lập đơn vị hiển thị mặc định.',
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            hintText: 'Tìm kiếm',
            prefix: const Icon(Icons.search),
            onChanged: (text) {
              setState(() {
                _keyword = text;
              });
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: List.generate(filter().length, (index) {
                  Currency currency = filter()[index];
                  final isSelected = _currency == currency.code;
                  return SizedBox(
                    width: (MediaQuery.of(context).size.width / 2) - AppSpacing.xl,
                    child: AppCard(
                      onTap: () {
                        setState(() {
                          _currency = currency.code;
                        });
                      },
                      color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                            child: Text(currency.symbol),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            currency.name,
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            currency.code,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Hoàn tất',
            icon: Icons.arrow_forward,
            size: AppButtonSize.large,
            isFullWidth: true,
            onPressed: () {
              if (_currency == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn tiền tệ')));
              } else {
                cubit.updateCurrency(_currency);
                resetDatabase();
              }
            },
          ),
        ],
      ),
    );
  }
}
