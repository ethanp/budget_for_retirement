import 'package:budget_for_retirement/model/financial_simulation.dart';
import 'package:budget_for_retirement/util/extensions.dart';
import 'package:flutter/material.dart';

class MinRetirementInsightData {
  const MinRetirementInsightData({
    required this.displayValue,
    required this.color,
    required this.canRetire,
  });

  final String displayValue;
  final Color color;
  final bool canRetire;
}

class NetWorthInsightData {
  const NetWorthInsightData({
    required this.displayValue,
    required this.color,
    required this.hasPositiveNetWorth,
    required this.value,
  });

  final String displayValue;
  final Color color;
  final bool hasPositiveNetWorth;
  final double value;
}

MinRetirementInsightData buildMinRetirementInsightData(
  FinancialSimulation simulation,
) {
  final int minRetirementAge = simulation.findMinRetirementAge();
  final int death = simulation.sliderPositions.ageAtDeath.now;
  final bool canStopWorking = minRetirementAge < death;
  final String text = canStopWorking ? '$minRetirementAge' : 'Never';
  final Color color =
      canStopWorking ? Colors.green.shade700 : Colors.red.shade700;

  return MinRetirementInsightData(
    displayValue: text,
    color: color,
    canRetire: canStopWorking,
  );
}

NetWorthInsightData buildNetWorthInsightData(
  FinancialSimulation simulation,
) {
  final double finalSavings =
      simulation.latestData.netSavings.dataPoints.last.y;
  final bool dieWithSavings = finalSavings >= 0;
  final Color color =
      dieWithSavings ? Colors.green.shade700 : Colors.red.shade700;
  final String finalCurrency = finalSavings.asCompactDollars();

  return NetWorthInsightData(
    displayValue: finalCurrency,
    color: color,
    hasPositiveNetWorth: dieWithSavings,
    value: finalSavings,
  );
}

NetWorthInsightData buildNetWorthAtAge45InsightData(
  FinancialSimulation simulation,
) {
  final startingAge = simulation.sliderPositions.simulationStartingAge.now;
  final targetAge = 45.0;

  if (targetAge < startingAge) {
    return NetWorthInsightData(
      displayValue: 'N/A',
      color: Colors.grey.shade700,
      hasPositiveNetWorth: false,
      value: 0,
    );
  }

  final dataPoint = simulation.latestData.netSavings.dataPoints.firstWhere(
    (point) => point.x == targetAge,
    orElse: () => simulation.latestData.netSavings.dataPoints.last,
  );

  final double netWorth = dataPoint.y;
  final bool isPositive = netWorth >= 0;
  final Color color = isPositive ? Colors.green.shade700 : Colors.red.shade700;
  final String displayCurrency = netWorth.asCompactDollars();

  return NetWorthInsightData(
    displayValue: displayCurrency,
    color: color,
    hasPositiveNetWorth: isPositive,
    value: netWorth,
  );
}
