import 'dart:math' as math;

import 'earnings.dart';
import 'economy.dart';
import 'investment_account.dart';
import 'life_events.dart';
import 'non_house_expenses.dart';
import 'residences.dart';
import 'user_specified_parameters.dart';

class SimulationStateMachine {
  SimulationStateMachine._({
    required this.economy,
    required this.lifeEvents,
    required this.spending,
    required this.salary,
    required this.retirementSavings,
    required this.taxableInvestments,
    required this.nonMortgageDebt,
    required this.residences,
  });

  // References to configuration parameters.
  final Economy economy;
  final LifeEvents lifeEvents;
  final NonHouseExpenses spending;
  final Earnings salary;
  final RetirementSavings retirementSavings;
  final TaxableInvestments taxableInvestments;
  final NonMortgageDebt nonMortgageDebt;
  final Residences residences;

  // This factory exists because in Dart you can't initialize final fields
  // based on other final fields within a field definition, constructor
  // initializer list, or constructor body. This is the recommended alternative.
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
        ageAtDeath: args.ageAtDeath.now,
        jobs: args.jobs.listInOrder,
        ageAtRetirement: args.ageAtRetirement.now,
        startingAge: args.simulationStartingAge.now,
      ),
      spending: NonHouseExpenses(
        monthlyLifestyle: args.monthlyNonFoodBudget.now,
        monthlyFood: args.monthlyFoodBudget.now,
      ),
      salary: Earnings(),
      retirementSavings: RetirementSavings(
        perAnnumTarget: args.retirementInvestmentsPerAnnumTarget.now,
        initialGross: args.initialGrossRetirementInvestments.now,
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

  /// This is where we define the order in which the advancements are made
  /// across subcomponents of the simulation model.
  void advanceOneYear() {
    // Time keeps on ticking, ticking, ticking; into the future.
    lifeEvents.currentAge++;

    // Return on investments.
    for (final acct in [retirementSavings, taxableInvestments]) {
      acct.increaseBy(percent: economy.investmentReturns);
    }

    taxableInvestments.grossValue -= taxableInvestments.annualTaxOnHoldings;

    // Debt on debt on debt.
    nonMortgageDebt.increaseBy(percent: economy.debtApr);

    double incomeRemaining = salary.annualThisYear(lifeEvents);

    // Pay income taxes (federal + state + local, soc-sec, etc).
    incomeRemaining = economy.effectiveIncomeTaxRate.takeFrom(incomeRemaining);

    void spendToDebt(double amtSpent) {
      final remaining = _spendMoney(incomeRemaining, amtSpent);
      incomeRemaining = remaining.incomeRemaining;
      nonMortgageDebt.grossValue += remaining.stillOwed;
    }

    // Cover spending.
    final nonHousingExpenses = spending.expensesThisYear(lifeEvents, economy);
    assert(nonHousingExpenses >= 0);
    spendToDebt(nonHousingExpenses);

    // Cover housing.
    final housingExpenses = residences.costsThisYear(lifeEvents);
    // Housing costs are negative when house sold more than covers first-year
    // expenses for house bought.
    if (housingExpenses < 0) {
      taxableInvestments.grossValue -= housingExpenses;
    } else {
      spendToDebt(housingExpenses);
    }

    // Pay off debt.
    final remaining = _spendMoney(incomeRemaining, nonMortgageDebt.grossValue);
    incomeRemaining = remaining.incomeRemaining;
    nonMortgageDebt.grossValue = remaining.stillOwed;

    // Save for retirement (pre-tax) if not "in debt". This isn't physically
    // in order of when it gets taken out (prior to salary deposit), but
    // logically it's where we'd wish it was taken out.
    if (!lifeEvents.isRetired && nonMortgageDebt.isEmpty) {
      final target = retirementSavings.perAnnumTarget;
      final smaller = math.min(target, incomeRemaining);
      incomeRemaining -= smaller;
      retirementSavings.grossValue += smaller;
    }

    // Squirrel away remaining salary.
    taxableInvestments.grossValue += incomeRemaining;
  }

  RemainingMoney _spendMoney(double salaryRemaining, double debtRemaining) {
    // Spend using retirement savings.
    if (lifeEvents.isRetired && lifeEvents.currentAge > 60) {
      final smaller = math.min(retirementSavings.grossValue, debtRemaining);
      retirementSavings.liquidateAndSpend(smaller, isEarlyWithdrawal: false);
      debtRemaining -= smaller;
    }

    // Spend using salary.
    {
      final smaller = math.min(salaryRemaining, debtRemaining);
      salaryRemaining -= smaller;
      debtRemaining -= smaller;
    }

    // Spend using investments.
    {
      final smaller = math.min(
        debtRemaining,
        taxableInvestments.afterTaxValue(),
      );
      debtRemaining -= smaller;
      taxableInvestments.liquidateAndSpend(smaller);
    }

    // Withdraw early from retirement savings for extreme debt situations.
    if (nonMortgageDebt.grossValue > 250e3) {
      final smaller = math.min(retirementSavings.grossValue, debtRemaining);
      retirementSavings.liquidateAndSpend(
        smaller,
        isEarlyWithdrawal: lifeEvents.currentAge < 60,
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
