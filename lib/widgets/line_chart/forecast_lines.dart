import 'package:budget_for_retirement/model/param_registry.dart';
import 'package:budget_for_retirement/model/simulation_params.dart';
import 'package:budget_for_retirement/model/simulation_state_machine.dart';
import 'package:budget_for_retirement/util/mutable_simulator_arg.dart';
import 'package:flutter/material.dart' show Colors;

import 'forecast_line.dart';

class ForecastLines._() {
  factory empty() => ForecastLines._();

  final _taxableInvestments = ForecastLine.fromChartDefinition(
    ParamRegistry.initialTaxableInvestmentsGross,
    (s) => s.taxableInvestments.grossValue,
  );
  final _traditionalRetirement = ForecastLine.fromChartDefinition(
    ParamRegistry.initialTraditionalRetirement,
    (s) => s.traditionalRetirement.grossValue,
  );
  final _rothRetirement = ForecastLine.fromChartDefinition(
    ParamRegistry.initialRothRetirement,
    (s) => s.rothRetirement.grossValue,
  );
  final _homeEquity = ForecastLine.fromChartDefinition(
    ParamRegistry.homeEquity,
    (s) => s.residences.homeEquity(s.lifeEvents),
  );
  final netWorth = ForecastLine.fromChartDefinition(
    ParamRegistry.netWorth,
    (s) =>
        s.taxableInvestments.grossValue +
        s.residences.homeEquity(s.lifeEvents) +
        s.totalRetirementSavings -
        s.nonMortgageDebt.grossValue,
  );
  final _earnings = ForecastLine.fromChartDefinition(
    ParamRegistry.earnings,
    (s) => s.salary.annualThisYear(s.lifeEvents),
  );
  final _nonHousingExpenses = ForecastLine.fromChartDefinition(
    ParamRegistry.nonHousingExpenses,
    (s) => s.spending.expensesThisYear(s.lifeEvents, s.economy),
  );
  final _housingExpenses = ForecastLine.fromChartDefinition(
    ParamRegistry.housingExpenses,
    (s) => s.residences.costsThisYear(s.lifeEvents),
  );
  final _debt = ForecastLine.fromChartDefinition(
    ParamRegistry.debt,
    (s) => s.nonMortgageDebt.grossValue,
  );

  List<ForecastLine> get inLegendOrder => [
    netWorth,
    _debt,
    _nonHousingExpenses,
    _housingExpenses,
    _traditionalRetirement,
    _rothRetirement,
    _earnings,
    _taxableInvestments,
    _homeEquity,
  ];

  void recordYear(SimulationStateMachine lifeState) {
    for (final forecastLine in inLegendOrder) {
      forecastLine.recordYear(lifeState);
    }
  }

  static List<LifeEventMarker> lifeEventMarkers(SimulationParams initialState) =>
      [
        LifeEventMarker(
          name: 'Retire',
          color: Colors.blueGrey.withValues(alpha: .7),
          age: initialState.ageAtRetirement.toDouble(),
        ),
        ...initialState.jobs.listInOrder.map(
          (job) => LifeEventMarker(
            name: 'Job ${job.age}',
            color: Colors.blueGrey.withValues(alpha: .7),
            age: job.age.toDouble(),
          ),
        ),
        ...initialState.children.currentAges.map(
          (age) => LifeEventMarker(
            name: 'Child $age',
            color: Colors.orange,
            age: age.toDouble(),
          ),
        ),
        ...initialState.primaryResidences.listInOrder.map(
          (PrimaryResidence housePurchase) => LifeEventMarker(
            name: housePurchase.toString(),
            color: Colors.teal.withValues(alpha: .7),
            age: housePurchase.age.toDouble(),
          ),
        ),
      ];
}
