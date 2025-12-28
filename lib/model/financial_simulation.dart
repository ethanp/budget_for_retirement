import 'package:budget_for_retirement/widgets/line_chart/lines_builder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'simulation_params.dart';
import 'simulation_state_machine.dart';

class FinancialSimulation extends ChangeNotifier {
  FinancialSimulation({required this.configJson}) {
    reset();
  }

  /// Raw JSON config, kept for reset functionality.
  final Map<String, dynamic> configJson;
  late SimulationParams sliderPositions;
  var latestData = LinesBuilder.empty();

  static FinancialSimulation dontWatch(BuildContext context) =>
      context.read<FinancialSimulation>();

  static FinancialSimulation watchFrom(BuildContext context) =>
      context.watch<FinancialSimulation>();

  void reset() {
    sliderPositions = SimulationParams.fromJson(configJson);
    run();
  }

  void run() {
    latestData = LinesBuilder.empty();
    final simulationState = SimulationStateMachine.createFrom(sliderPositions);
    while (!simulationState.lifeEvents.pastEndAge) {
      simulationState.advanceOneYear();
      latestData.addYear(simulationState);
    }
    notifyListeners();
  }

  /// Monitor for the retirement age, ceteris paribus (other sliders being
  /// equal).
  int findMinRetirementAge() {
    // Instead of implementing a proper copy() function, we just
    // remember the original user-set retirement age, then run the simulation,
    // then swap it back in before the method returns :).
    final int origRetirementAge = sliderPositions.ageAtRetirement.now;

    final minRetirementAge = _findMinimumRetirementAge(
      from: sliderPositions.simulationStartingAge.now,
      to: sliderPositions.endAge.now,
    );

    sliderPositions.ageAtRetirement.updateTo(origRetirementAge);
    return minRetirementAge;
  }

  /// Returns [to] if no valid age is found.
  int _findMinimumRetirementAge({required int from, required int to}) {
    // NB: Could be binary search but it's already fast enough.
    for (int age = from; age < to; age++)
      if (_isSafeRetirementAge(age)) return age;
    return to;
  }

  /// Returns true iff retiring at [retirementAge] would still allow living
  /// until age 95 with a net worth of at least zero.
  bool _isSafeRetirementAge(int retirementAge) {
    // NB: Only needs partial re-calculation for each iteration, but it's
    //  already fast enough.
    final simulationData = LinesBuilder.empty();
    sliderPositions.ageAtRetirement.updateTo(retirementAge);
    final simulationState = SimulationStateMachine.createFrom(sliderPositions);
    while (!simulationState.lifeEvents.pastEndAge) {
      simulationState.advanceOneYear();
      simulationData.addYear(simulationState);
    }
    return simulationData.netSavings.dataPoints.last.y >= 0;
  }
}
