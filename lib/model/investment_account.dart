import 'package:budget_for_retirement/util/extensions.dart';
import 'package:budget_for_retirement/util/mutable_simulator_arg.dart';
import 'package:flutter/cupertino.dart';

import 'economy.dart';

abstract class InvestmentAccount {
  InvestmentAccount({required this.grossValue});

  /// Gross value is pre-tax.
  double grossValue;

  bool get isEmpty => grossValue <= 0;

  double afterTaxValue() => grossValue - taxesOnWithdrawal(grossValue, false);

  void liquidateAndSpend(double amt, {bool isEarlyWithdrawal = false}) =>
      grossValue -= amt + taxesOnWithdrawal(amt, isEarlyWithdrawal);

  @protected
  double taxesOnWithdrawal(double amt, bool isEarlyWithdrawal);

  void increaseBy({required Percent percent}) =>
      grossValue += percent.of(grossValue);
}

class NonMortgageDebt extends InvestmentAccount {
  NonMortgageDebt({required super.grossValue});

  @override
  void liquidateAndSpend(double amt, {bool isEarlyWithdrawal = false}) =>
      throw UnimplementedError('Cannot spend debt.');

  @override
  double taxesOnWithdrawal(double amt, bool isEarlyWithdrawal) =>
      throw UnimplementedError('No taxes on debt.');
}

class TaxableInvestments extends InvestmentAccount {
  TaxableInvestments({required super.grossValue});

  /// Assume 90% of the total amount is "earnings" and the rest is
  /// "contributions". This is conservative but reasonable. Only pay long-term
  /// cap-gains on "earnings" part.
  @override
  double taxesOnWithdrawal(double amt, bool isEarlyWithdrawal) =>
      Economy.longTermCapitalGainsTaxRate.of(amt * 9.0 / 10.0);

  double get annualTaxOnHoldings {
    /// Source: https://stockanalysis.com/etf/vti/dividend/
    final Percent vtiDividendYield = 1.59.percent;

    /// This part is additional taxes from dividends on newly-bought shares, as
    /// well as sales of any speculative trades that I couldn't resist making.
    final Percent messingAround = 10.percent;

    final double taxableAmt = (messingAround + vtiDividendYield).of(grossValue);
    return Economy.longTermCapitalGainsTaxRate.of(taxableAmt);
  }
}

// RetirementSavings has been split into TraditionalRetirement and RothRetirement
// in retirement_accounts.dart for proper tax treatment.
