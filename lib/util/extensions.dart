import 'package:budget_for_retirement/util/mutable_simulator_arg.dart';
import 'package:intl/intl.dart';

extension CompactCurrency on double {
  String asCompactDollars() {
    return NumberFormat.compactCurrency(
      locale: 'en_US',
      symbol: '\$',
    ).format(this);
  }
}

/// Eg. 1 => '1st', 2 => '2nd', 3 => '3rd', 4 => '4th', etc.
String ith({required int place}) {
  String suffix;
  if (place == 1 || place > 20 && place % 10 == 1) {
    suffix = 'st';
  } else if (place == 2 || place > 20 && place % 10 == 2) {
    suffix = 'nd';
  } else if (place == 3 || place > 20 && place % 10 == 3) {
    suffix = 'rd';
  } else {
    suffix = 'th';
  }
  return '$place$suffix';
}

extension ToPI on num {
  Percent get percent => Percent(toDouble());
  Dollars get kiloDollars => Dollars(toDouble() * 1000);
}
