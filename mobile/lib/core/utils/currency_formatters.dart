import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: 'Rs ',
    decimalDigits: 2,
  );

  static String format(num amount, {String symbol = 'Rs '}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static String formatPkr(num amount) {
    return 'Rs ${amount.toStringAsFixed(2)}';
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
  }

  static String formatShortDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }
}

typedef CurrencyFormatters = CurrencyFormatter;
