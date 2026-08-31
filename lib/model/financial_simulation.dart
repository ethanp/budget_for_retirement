import 'package:budget_for_retirement/widgets/insights/insight_metrics.dart';
import 'package:budget_for_retirement/widgets/line_chart/forecast_lines.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'simulation_params.dart';
import 'simulation_state_machine.dart';

class FinancialSimulation({
  required final Map<String, dynamic> configJson,
}) extends ChangeNotifier {
  this {
    reset();
  }

  late SimulationParams sliderPositions;
  var forecastLines = ForecastLines.empty();

  static FinancialSimulation dontWatch(BuildContext context) =>
      context.read<FinancialSimulation>();

  static FinancialSimulation watchFrom(BuildContext context) =>
      context.watch<FinancialSimulation>();

  void reset() {
    sliderPositions = SimulationParams.fromJson(configJson);
    run();
  }

  void run() {
    forecastLines = ForecastLines.empty();
    final simulationState = SimulationStateMachine.createFrom(sliderPositions);
    while (!simulationState.lifeEvents.pastEndAge) {
      simulationState.advanceOneYear();
      forecastLines.recordYear(simulationState);
    }
    notifyListeners();
  }

  int findMinRetirementAge() {
    final int origRetirementAge = sliderPositions.ageAtRetirement.now;

    final minRetirementAge = _earliestAgeWithNonNegativeNetWorthAtEnd(
      from: sliderPositions.simulationStartingAge.now,
      to: sliderPositions.endAge.now,
    );

    sliderPositions.ageAtRetirement.updateTo(origRetirementAge);
    return minRetirementAge;
  }

  int _earliestAgeWithNonNegativeNetWorthAtEnd({
    required int from,
    required int to,
  }) {
    for (int age = from; age < to; age++) {
      if (_endsWithNonNegativeNetWorth(age)) return age;
    }
    return to;
  }

  bool _endsWithNonNegativeNetWorth(int retirementAge) {
    final trialForecast = ForecastLines.empty();
    sliderPositions.ageAtRetirement.updateTo(retirementAge);
    final simulationState = SimulationStateMachine.createFrom(sliderPositions);
    while (!simulationState.lifeEvents.pastEndAge) {
      simulationState.advanceOneYear();
      trialForecast.recordYear(simulationState);
    }
    return trialForecast.netWorth.dataPoints.last.y >= 0;
  }

  bool get isFinanciallyHealthy {
    final netWorthAt45 = NetWorthInsightData.at45(this);
    final netWorthAtEnd = NetWorthInsightData.at95(this);
    return netWorthAt45.hasPositiveNetWorth &&
        netWorthAtEnd.hasPositiveNetWorth;
  }
}
