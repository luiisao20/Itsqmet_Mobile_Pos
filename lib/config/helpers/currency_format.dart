abstract final class CurrencyFormat {
  static String format(num value) {
    final sign = value < 0 ? '-' : '';
    return '$sign\$${plain(value.abs())}';
  }

  static String plain(num value) => value.toStringAsFixed(2);
}
