import 'package:budget_for_retirement/util/extensions.dart';
import 'package:budget_for_retirement/util/mutable_simulator_arg.dart';

import 'investment_account.dart';

/// Traditional retirement accounts (401k, Traditional IRA).
/// Contributions are pre-tax, withdrawals are 100% taxed as ordinary income.
class TraditionalRetirement extends InvestmentAccount {
  final double perAnnumTarget;
  static final _retirementMarginalRate = 22.percent;

  TraditionalRetirement({
    required this.perAnnumTarget,
    required double initialGross,
  }) : super(grossValue: initialGross);

  @override
  double taxesOnWithdrawal(double amt, bool isEarlyWithdrawal) {
    final incomeTax = _retirementMarginalRate.of(amt);
    final earlyPenalty = isEarlyWithdrawal ? 10.percent.of(amt) : 0.0;
    return incomeTax + earlyPenalty;
  }
}

/// Roth retirement accounts (Roth 401k, Roth IRA, HSA for medical).
/// Contributions are post-tax, qualified withdrawals are tax-free.
class RothRetirement extends InvestmentAccount {
  final double perAnnumTarget;
  static final _retirementMarginalRate = 22.percent;

  RothRetirement({
    required this.perAnnumTarget,
    required double initialGross,
  }) : super(grossValue: initialGross);

  @override
  double taxesOnWithdrawal(double amt, bool isEarlyWithdrawal) {
    // Qualified withdrawals (age 59.5+, account 5+ years old) are tax-free
    if (!isEarlyWithdrawal) return 0.0;

    // Early withdrawals: contributions are always tax-free, earnings are taxed + penalized
    // Simplified: assume 50% is contributions, 50% is earnings
    final earningsAmt = amt / 2;
    final incomeTax = _retirementMarginalRate.of(earningsAmt);
    final penalty = 10.percent.of(earningsAmt);
    return incomeTax + penalty;
  }
}

/// Combined view of both retirement account types for convenience.
class RetirementAccounts {
  final TraditionalRetirement traditional;
  final RothRetirement roth;

  RetirementAccounts({required this.traditional, required this.roth});

  double get totalGrossValue => traditional.grossValue + roth.grossValue;

  void applyReturns(Percent returnRate) {
    traditional.increaseBy(percent: returnRate);
    roth.increaseBy(percent: returnRate);
  }
}
