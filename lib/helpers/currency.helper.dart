import 'package:intl/intl.dart';

class CurrencyHelper {
  static String format(
      double amount, {
        String? symbol = '₫',
        String? name = 'VND',
        String locale = 'vi_VN',
      }) {
    // Use NumberFormat.currency to ensure correct grouping for Vietnamese locale
    final nf = NumberFormat.currency(locale: locale, symbol: '$symbol', decimalDigits: 0);
    return nf.format(amount);
  }
}
