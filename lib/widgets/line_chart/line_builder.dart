import 'package:budget_for_retirement/model/param_definition.dart';
import 'package:budget_for_retirement/model/simulation_state_machine.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'financial_line_chart.dart';

class LineBuilder {
  LineBuilder({
    required this.name,
    required this.color,
    required this.extractYAxisValue,
  });

  /// Create from registry definition (uses chartName/chartColor).
  factory LineBuilder.fromRegistry(
    ParamDefinition def,
    double Function(SimulationStateMachine) extractor,
  ) =>
      LineBuilder(
        name: def.chartName!,
        color: def.chartColor!,
        extractYAxisValue: extractor,
      );

  /// Format required by FlChart library for 2D-coordinates.
  final List<FlSpot> dataPoints = [];

  /// Used in the chart legend.
  final String name;

  /// Color of the line in the chart.
  final Color color;

  /// Pulls the y-axis value for this line at the given LifeState.
  final double Function(SimulationStateMachine) extractYAxisValue;

  /// Append the given LifeState as a 2D point on this line.
  ///
  /// The x-axis contains the age.
  void appendDataPointsExtractedFrom(SimulationStateMachine lifeState) {
    dataPoints.add(
      FlSpot(
        lifeState.lifeEvents.currentAge.toDouble(),
        extractYAxisValue(lifeState),
      ),
    );
  }
}

class VerticalLineBuilder extends LineBuilder {
  VerticalLineBuilder({
    required String name,
    required Color color,
    required double xValue,
  }) : super(
          name: name,
          color: color,
          extractYAxisValue: (_) => throw NotImplementedError(),
        ) {
    dataPoints.add(FlSpot(xValue, 0)); // Line bottom.
    dataPoints.add(FlSpot(xValue, FinancialLineChart.maxY)); // Line top.
  }
}

class NotImplementedError extends Error {}
