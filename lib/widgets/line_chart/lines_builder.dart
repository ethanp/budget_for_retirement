import 'package:budget_for_retirement/model/param_registry.dart';
import 'package:budget_for_retirement/model/simulation_params.dart';
import 'package:budget_for_retirement/model/simulation_state_machine.dart';
import 'package:budget_for_retirement/util/mutable_simulator_arg.dart';
import 'package:flutter/material.dart' show Colors;

import 'line_builder.dart';

class LinesBuilder {
  LinesBuilder._();

  factory LinesBuilder.empty() => LinesBuilder._();

  final _taxableInvestments = LineBuilder.fromRegistry(
    ParamRegistry.initialTaxableInvestmentsGross,
    (s) => s.taxableInvestments.grossValue,
  );
  final _traditionalRetirement = LineBuilder.fromRegistry(
    ParamRegistry.initialTraditionalRetirement,
    (s) => s.traditionalRetirement.grossValue,
  );
  final _rothRetirement = LineBuilder.fromRegistry(
    ParamRegistry.initialRothRetirement,
    (s) => s.rothRetirement.grossValue,
  );
  final _homeBalance = LineBuilder.fromRegistry(
    ParamRegistry.homeEquity,
    (s) => s.residences.homeEquity(s.lifeEvents),
  );
  final netSavings = LineBuilder.fromRegistry(
    ParamRegistry.netWorth,
    (s) =>
        s.taxableInvestments.grossValue +
        s.residences.homeEquity(s.lifeEvents) +
        s.totalRetirementSavings -
        s.nonMortgageDebt.grossValue,
  );
  final _earnings = LineBuilder.fromRegistry(
    ParamRegistry.earnings,
    (s) => s.salary.annualThisYear(s.lifeEvents),
  );
  final _nonHousingExpenses = LineBuilder.fromRegistry(
    ParamRegistry.nonHousingExpenses,
    (s) => s.spending.expensesThisYear(s.lifeEvents, s.economy),
  );
  final _housingExpenses = LineBuilder.fromRegistry(
    ParamRegistry.housingExpenses,
    (s) => s.residences.costsThisYear(s.lifeEvents),
  );
  final _debt = LineBuilder.fromRegistry(
    ParamRegistry.debt,
    (s) => s.nonMortgageDebt.grossValue,
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
    SimulationParams initialState,
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
