import 'dart:math' as math;

import 'earnings.dart';
import 'economy.dart';
import 'investment_account.dart';
import 'life_events.dart';
import 'non_house_expenses.dart';
import 'residences.dart';
import 'retirement_accounts.dart';
import 'user_specified_parameters.dart';

class SimulationStateMachine {
  SimulationStateMachine._({
    required this.economy,
    required this.lifeEvents,
    required this.spending,
    required this.salary,
    required this.traditionalRetirement,
    required this.rothRetirement,
    required this.taxableInvestments,
    required this.nonMortgageDebt,
    required this.residences,
  });

  final Economy economy;
  final LifeEvents lifeEvents;
  final NonHouseExpenses spending;
  final Earnings salary;
  final TraditionalRetirement traditionalRetirement;
  final RothRetirement rothRetirement;
  final TaxableInvestments taxableInvestments;
  final NonMortgageDebt nonMortgageDebt;
  final Residences residences;

  /// Combined retirement savings for display purposes.
  double get totalRetirementSavings =>
      traditionalRetirement.grossValue + rothRetirement.grossValue;

  factory SimulationStateMachine.createFrom(UserSpecifiedParameters args) {
    return SimulationStateMachine._(
      economy: Economy(
        effectiveIncomeTaxRate: args.effectiveIncomeTaxRate,
        debtApr: args.debtApr,
        investmentReturns: args.realInvestmentReturns,
        inflationRate: args.inflationRate,
      ),
      lifeEvents: LifeEvents(
        ageAtChildren: args.children.currentAges,
        endAge: args.endAge.now,
        jobs: args.jobs.listInOrder,
        ageAtRetirement: args.ageAtRetirement.now,
        startingAge: args.simulationStartingAge.now,
      ),
      spending: NonHouseExpenses(
        monthlyLifestyle: args.monthlyNonFoodBudget.now,
        monthlyFood: args.monthlyFoodBudget.now,
      ),
      salary: Earnings(),
      traditionalRetirement: TraditionalRetirement(
        perAnnumTarget: args.traditionalContributionTarget.now,
        initialGross: args.initialTraditionalRetirement.now,
      ),
      rothRetirement: RothRetirement(
        perAnnumTarget: args.rothContributionTarget.now,
        initialGross: args.initialRothRetirement.now,
      ),
      taxableInvestments: TaxableInvestments(
        grossValue: args.initialTaxableInvestmentsGross.now,
      ),
      nonMortgageDebt: NonMortgageDebt(grossValue: 0),
      residences: Residences(
        properties: args.primaryResidences.listInOrder,
        inflationRate: args.inflationRate,
        effectiveIncomeTaxRate: args.effectiveIncomeTaxRate,
      ),
    );
  }

  void advanceOneYear() {
    lifeEvents.currentAge++;

    // Return on investments for all account types.
    traditionalRetirement.increaseBy(percent: economy.investmentReturns);
    rothRetirement.increaseBy(percent: economy.investmentReturns);
    taxableInvestments.increaseBy(percent: economy.investmentReturns);

    taxableInvestments.grossValue -= taxableInvestments.annualTaxOnHoldings;

    nonMortgageDebt.increaseBy(percent: economy.debtApr);

    double incomeRemaining = salary.annualThisYear(lifeEvents);

    // Traditional 401k contributions are pre-tax (reduce taxable income).
    double traditionalContribution = 0;
    if (!lifeEvents.isRetired && nonMortgageDebt.isEmpty) {
      traditionalContribution = math.min(
        traditionalRetirement.perAnnumTarget,
        incomeRemaining,
      );
      incomeRemaining -= traditionalContribution;
    }

    // Pay income taxes on remaining income (after Traditional contributions).
    incomeRemaining = economy.effectiveIncomeTaxRate.takeFrom(incomeRemaining);

    // Now add the Traditional contribution (it was already deducted pre-tax).
    traditionalRetirement.grossValue += traditionalContribution;

    void spendToDebt(double amtSpent) {
      final remaining = _spendMoney(incomeRemaining, amtSpent);
      incomeRemaining = remaining.incomeRemaining;
      nonMortgageDebt.grossValue += remaining.stillOwed;
    }

    final nonHousingExpenses = spending.expensesThisYear(lifeEvents, economy);
    assert(nonHousingExpenses >= 0);
    spendToDebt(nonHousingExpenses);

    final housingExpenses = residences.costsThisYear(lifeEvents);
    if (housingExpenses < 0) {
      taxableInvestments.grossValue -= housingExpenses;
    } else {
      spendToDebt(housingExpenses);
    }

    final remaining = _spendMoney(incomeRemaining, nonMortgageDebt.grossValue);
    incomeRemaining = remaining.incomeRemaining;
    nonMortgageDebt.grossValue = remaining.stillOwed;

    // Roth contributions are post-tax (after we've paid taxes).
    if (!lifeEvents.isRetired && nonMortgageDebt.isEmpty) {
      final rothContribution = math.min(
        rothRetirement.perAnnumTarget,
        incomeRemaining,
      );
      incomeRemaining -= rothContribution;
      rothRetirement.grossValue += rothContribution;
    }

    // Squirrel away remaining salary into taxable investments.
    taxableInvestments.grossValue += incomeRemaining;
  }

  /// Tax-efficient withdrawal order:
  /// 1. Taxable accounts first (preserves tax-advantaged growth)
  /// 2. Traditional accounts second (required by RMDs eventually)
  /// 3. Roth accounts last (let tax-free growth continue longest)
  RemainingMoney _spendMoney(double salaryRemaining, double debtRemaining) {
    final isEarlyWithdrawal = lifeEvents.currentAge < 59;

    // 1. Spend using salary first.
    {
      final smaller = math.min(salaryRemaining, debtRemaining);
      salaryRemaining -= smaller;
      debtRemaining -= smaller;
    }

    // 2. Spend using taxable investments.
    if (debtRemaining > 0) {
      final smaller = math.min(
        debtRemaining,
        taxableInvestments.afterTaxValue(),
      );
      debtRemaining -= smaller;
      taxableInvestments.liquidateAndSpend(smaller);
    }

    // 3. Spend using Traditional retirement (if retired and age 59+).
    if (debtRemaining > 0 && lifeEvents.isRetired && !isEarlyWithdrawal) {
      final smaller = math.min(traditionalRetirement.grossValue, debtRemaining);
      traditionalRetirement.liquidateAndSpend(smaller,
          isEarlyWithdrawal: false);
      debtRemaining -= smaller;
    }

    // 4. Spend using Roth retirement (if retired and age 59+, tax-free).
    if (debtRemaining > 0 && lifeEvents.isRetired && !isEarlyWithdrawal) {
      final smaller = math.min(rothRetirement.grossValue, debtRemaining);
      rothRetirement.liquidateAndSpend(smaller, isEarlyWithdrawal: false);
      debtRemaining -= smaller;
    }

    // 5. Early withdrawal from Traditional for extreme debt (> $250K).
    if (debtRemaining > 0 && nonMortgageDebt.grossValue > 250e3) {
      final smaller = math.min(traditionalRetirement.grossValue, debtRemaining);
      traditionalRetirement.liquidateAndSpend(
        smaller,
        isEarlyWithdrawal: isEarlyWithdrawal,
      );
      debtRemaining -= smaller;
    }

    // 6. Early withdrawal from Roth for extreme debt (contributions first).
    if (debtRemaining > 0 && nonMortgageDebt.grossValue > 250e3) {
      final smaller = math.min(rothRetirement.grossValue, debtRemaining);
      rothRetirement.liquidateAndSpend(
        smaller,
        isEarlyWithdrawal: isEarlyWithdrawal,
      );
      debtRemaining -= smaller;
    }

    return RemainingMoney(salaryRemaining, debtRemaining);
  }
}

class RemainingMoney {
  const RemainingMoney(this.incomeRemaining, this.stillOwed);

  final double incomeRemaining;
  final double stillOwed;
}
