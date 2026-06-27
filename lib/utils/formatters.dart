import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat money = NumberFormat.currency(
    locale: 'en_PK',
    symbol: 'Rs. ',
    decimalDigits: 0,
  );

  static String amount(dynamic value) {
    final n = double.tryParse(value?.toString() ?? '0') ?? 0;
    return money.format(n);
  }

  static String shortDate(dynamic value) {
    if (value == null) return '';
    final dt = DateTime.tryParse(value.toString());
    if (dt == null) return value.toString();
    return DateFormat('dd MMM yyyy').format(dt.toLocal());
  }
}
