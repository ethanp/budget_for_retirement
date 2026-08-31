import 'package:budget_for_retirement/model/financial_simulation.dart';
import 'package:budget_for_retirement/util/extensions.dart';
import 'package:flutter/material.dart';

class const MinRetirementInsightData({
  required final String displayValue,
  required final Color color,
  required final bool canRetire,
}) {
  factory ageOrNever(FinancialSimulation simulation) {
    final int minRetirementAge = simulation.findMinRetirementAge();
    final int endAge = simulation.sliderPositions.endAge.now;
    final bool canStopWorking = minRetirementAge < endAge;
    return MinRetirementInsightData(
      displayValue: canStopWorking ? '$minRetirementAge' : 'Never',
      color: canStopWorking ? _successColor : _dangerColor,
      canRetire: canStopWorking,
    );
  }
}

class const NetWorthInsightData({
  required final String displayValue,
  required final Color color,
  required final bool hasPositiveNetWorth,
  required final double value,
}) {
  factory at95(FinancialSimulation simulation) {
    final double finalSavings =
        simulation.forecastLines.netWorth.dataPoints.last.y;
    final bool endWithSavings = finalSavings >= 0;
    return NetWorthInsightData(
      displayValue: finalSavings.asCompactDollars(),
      color: endWithSavings ? _successColor : _dangerColor,
      hasPositiveNetWorth: endWithSavings,
      value: finalSavings,
    );
  }

  factory at45(FinancialSimulation simulation) {
    final startingAge = simulation.sliderPositions.simulationStartingAge.now;
    final targetAge = 45.0;

    if (targetAge < startingAge) {
      return NetWorthInsightData(
        displayValue: 'N/A',
        color: _neutralColor,
        hasPositiveNetWorth: false,
        value: 0,
      );
    }

    final dataPoint = simulation.forecastLines.netWorth.dataPoints.firstWhere(
      (point) => point.x == targetAge,
      orElse: () => simulation.forecastLines.netWorth.dataPoints.last,
    );

    final double netWorth = dataPoint.y;
    final bool isPositive = netWorth >= 0;
    return NetWorthInsightData(
      displayValue: netWorth.asCompactDollars(),
      color: isPositive ? _successColor : _dangerColor,
      hasPositiveNetWorth: isPositive,
      value: netWorth,
    );
  }
}

const _successColor = Color(0xFF00A896);
const _dangerColor = Color(0xFFE57373);
const _neutralColor = Color(0xFF78909C);
