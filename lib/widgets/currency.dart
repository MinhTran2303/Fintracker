import 'package:currency_picker/currency_picker.dart';
import 'package:SpendingMonitor/bloc/cubit/app_cubit.dart';
import 'package:SpendingMonitor/helpers/currency.helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrencyText extends StatelessWidget{
  final double? amount;
  final TextStyle? style;
  final TextOverflow? overflow;
  final CurrencyService currencyService = CurrencyService();

  CurrencyText(this.amount, {super.key , this.style, this. overflow});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(builder: (context, state){
      // state.currency can be null during startup/onboarding; provide safe fallback
      Currency? currency;
      try {
        currency = state.currency == null ? null : currencyService.findByCode(state.currency!);
      } catch (_) {
        currency = null;
      }
      final symbol = currency?.symbol ?? '₫';
      // Force Vietnamese locale formatting for consistent grouping and symbol placement
      final formatted = amount == null ? '$symbol ' : CurrencyHelper.format(amount!, name: currency?.code ?? 'VND', symbol: symbol, locale: 'vi_VN');
      return Text(formatted, style: style, overflow: overflow,);
    });
  }
}
