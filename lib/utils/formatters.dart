import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _money = NumberFormat.currency(locale: 'en_PK', symbol: 'Rs. ', decimalDigits: 0);
  static final NumberFormat _money2 = NumberFormat.currency(locale: 'en_PK', symbol: 'Rs. ', decimalDigits: 2);
  static final DateFormat _date = DateFormat('dd MMM yyyy');
  static final DateFormat _shortDate = DateFormat('dd MMM');

  static String amount(dynamic value, {bool decimals = false}) {
    final number = value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '0') ?? 0;
    return decimals ? _money2.format(number) : _money.format(number);
  }

  static String date(dynamic value) {
    if (value == null) return '';
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return value.toString();
    return _date.format(parsed.toLocal());
  }

  static String shortDate(dynamic value) {
    if (value == null) return '';
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return value.toString();
    return _shortDate.format(parsed.toLocal());
  }
}
