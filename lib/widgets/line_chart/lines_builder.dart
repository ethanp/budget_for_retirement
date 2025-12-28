import 'package:budget_for_retirement/model/simulation_state_machine.dart';
import 'package:budget_for_retirement/model/user_specified_parameters.dart';
import 'package:budget_for_retirement/util/mutable_simulator_arg.dart';
import 'package:flutter/material.dart';

import 'line_builder.dart';

class LinesBuilder {
  LinesBuilder._();

  factory LinesBuilder.empty() => LinesBuilder._();

  final _taxableInvestments = LineBuilder(
    name: 'Taxable Investments',
    color: Colors.green.withOpacity(0.3),
    extractYAxisValue: (lifeState) => lifeState.taxableInvestments.grossValue,
  );
  final _traditionalRetirement = LineBuilder(
    name: 'Traditional (401k/IRA)',
    color: Colors.blue.withOpacity(0.3),
    extractYAxisValue: (lifeState) =>
        lifeState.traditionalRetirement.grossValue,
  );
  final _rothRetirement = LineBuilder(
    name: 'Roth (IRA/HSA)',
    color: Colors.indigo.withOpacity(0.3),
    extractYAxisValue: (lifeState) => lifeState.rothRetirement.grossValue,
  );
  final _homeBalance = LineBuilder(
    name: 'Home equity',
    color: Colors.greenAccent.withOpacity(0.6),
    extractYAxisValue: (lifeState) =>
        lifeState.residences.homeEquity(lifeState.lifeEvents),
  );
  final netSavings = LineBuilder(
    name: 'Net Worth',
    color: Colors.black87,
    extractYAxisValue: (lifeState) =>
        lifeState.taxableInvestments.grossValue +
        lifeState.residences.homeEquity(lifeState.lifeEvents) +
        lifeState.totalRetirementSavings -
        lifeState.nonMortgageDebt.grossValue,
  );
  final _earnings = LineBuilder(
    name: 'Earnings',
    color: Colors.purple.withOpacity(0.3),
    extractYAxisValue: (lifeState) =>
        lifeState.salary.annualThisYear(lifeState.lifeEvents),
  );
  final _nonHousingExpenses = LineBuilder(
    name: 'Non-housing expenses',
    color: Colors.orange.withOpacity(0.3),
    extractYAxisValue: (lifeState) => lifeState.spending
        .expensesThisYear(lifeState.lifeEvents, lifeState.economy),
  );
  final _housingExpenses = LineBuilder(
    name: 'Housing expenses',
    color: Colors.pink.withOpacity(0.3),
    extractYAxisValue: (lifeState) =>
        lifeState.residences.costsThisYear(lifeState.lifeEvents),
  );
  final _debt = LineBuilder(
    name: '"Bad" debt',
    color: Colors.pink,
    extractYAxisValue: (lifeState) => lifeState.nonMortgageDebt.grossValue,
  );

  /// NB: This is the order the legend appears in.
  ///     But it is [luckily] NOT the order that calculations happen in.
  List<LineBuilder> get horizontalLines => [
        netSavings,
        _debt,
        _nonHousingExpenses,
        _housingExpenses,
        _traditionalRetirement,
        _rothRetirement,
        _earnings,
        _taxableInvestments,
        _homeBalance,
      ];

  void addYear(SimulationStateMachine lifeState) => horizontalLines.forEach(
      (lineBuilder) => lineBuilder.appendDataPointsExtractedFrom(lifeState));

  static List<VerticalLineBuilder> verticalLines(
    UserSpecifiedParameters initialState,
  ) =>
      [
        VerticalLineBuilder(
          name: 'Retire',
          color: Colors.blueGrey.withOpacity(.7),
          xValue: initialState.ageAtRetirement.toDouble(),
        ),
        ...initialState.jobs.listInOrder.map(
          (job) => VerticalLineBuilder(
            name: 'Job ' + job.age.toString(),
            color: Colors.blueGrey.withOpacity(.7),
            xValue: job.age.toDouble(),
          ),
        ),
        ...initialState.children.currentAges.map(
          (age) => VerticalLineBuilder(
            name: 'Child ' + age.toString(),
            color: Colors.orange,
            xValue: age.toDouble(),
          ),
        ),
        ...initialState.primaryResidences.listInOrder.map(
          (PrimaryResidence housePurchase) => VerticalLineBuilder(
            name: housePurchase.toString(),
            color: Colors.teal.withOpacity(.7),
            xValue: housePurchase.age.toDouble(),
          ),
        ),
      ];
}
