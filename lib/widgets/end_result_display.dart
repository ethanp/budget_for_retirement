import 'package:budget_for_retirement/model/financial_simulation.dart';
import 'package:budget_for_retirement/util/extensions.dart';
import 'package:flutter/material.dart';

/// Tells user whether they "won" or "lost" in under 3 seconds.
class EndResultDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final simulationData = FinancialSimulation.watchFrom(context).latestData;
    final finalPoint = simulationData.netSavings.dataPoints.last;
    final finalSavings = finalPoint.y;
    final endWithSavings = finalSavings > 0;
    final finalCurrency = finalSavings.asCompactDollars();
    final finalAge = finalPoint.x.toInt();
    return Align(
      alignment: Alignment.center,
      child: Text(
        "At age $finalAge, you'll have $finalCurrency",
        style: TextStyle(
          fontSize: 20,
          color: endWithSavings ? Colors.grey[200] : Colors.black87.withRed(99),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
