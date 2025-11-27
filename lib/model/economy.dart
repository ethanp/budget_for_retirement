import 'package:budget_for_retirement/util/extensions.dart';
import 'package:budget_for_retirement/util/mutable_simulator_arg.dart';

class Economy {
  const Economy({
    required this.effectiveIncomeTaxRate,
    required this.debtApr,
    required this.investmentReturns,
    required this.inflationRate,
  });

  final Percent effectiveIncomeTaxRate;
  final Percent debtApr;
  final Percent investmentReturns;
  final Percent inflationRate;

  /// This is true for married filing jointly in 2022 up to ~$500K.
  /// See: https://www.nerdwallet.com/article/taxes/capital-gains-tax-rates
  static Percent longTermCapitalGainsTaxRate = 15.percent;
}
