import 'package:budget_for_retirement/model/financial_simulation.dart';
import 'package:budget_for_retirement/util/extensions.dart';
import 'package:flutter/material.dart';

class const MinRetirementInsightData({
  required final String displayValue,
  required final Color color,
  required final bool canRetire,
});

class const NetWorthInsightData({
  required final String displayValue,
  required final Color color,
  required final bool hasPositiveNetWorth,
  required final double value,
});

// Colors that work well in both light and dark themes
const _successColor = Color(0xFF00A896);
const _dangerColor = Color(0xFFE57373);
const _neutralColor = Color(0xFF78909C);

MinRetirementInsightData buildMinRetirementInsightData(
  FinancialSimulation simulation,
) {
  final int minRetirementAge = simulation.findMinRetirementAge();
  final int endAge = simulation.sliderPositions.endAge.now;
  final bool canStopWorking = minRetirementAge < endAge;
  final String text = canStopWorking ? '$minRetirementAge' : 'Never';
  final Color color = canStopWorking ? _successColor : _dangerColor;

  return MinRetirementInsightData(
    displayValue: text,
    color: color,
    canRetire: canStopWorking,
  );
}

NetWorthInsightData buildNetWorthInsightData(FinancialSimulation simulation) {
  final double finalSavings =
      simulation.latestData.netSavings.dataPoints.last.y;
  final bool endWithSavings = finalSavings >= 0;
  final Color color = endWithSavings ? _successColor : _dangerColor;
  final String finalCurrency = finalSavings.asCompactDollars();

  return NetWorthInsightData(
    displayValue: finalCurrency,
    color: color,
    hasPositiveNetWorth: endWithSavings,
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
      color: _neutralColor,
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
  final Color color = isPositive ? _successColor : _dangerColor;
  final String displayCurrency = netWorth.asCompactDollars();

  return NetWorthInsightData(
    displayValue: displayCurrency,
    color: color,
    hasPositiveNetWorth: isPositive,
    value: netWorth,
  );
}
