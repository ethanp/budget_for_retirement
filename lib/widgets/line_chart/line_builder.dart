import 'package:budget_for_retirement/model/param_definition.dart';
import 'package:budget_for_retirement/model/simulation_state_machine.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'financial_line_chart.dart';

class LineBuilder({
  /// Used in the chart legend.
  required final String name,

  /// Color of the line in the chart.
  required final Color color,

  /// Pulls the y-axis value for this line at the given LifeState.
  required final double Function(SimulationStateMachine) extractYAxisValue,
}) {
  /// Create from registry definition (uses chartName/chartColor).
  factory fromRegistry(
    ParamDefinition def,
    double Function(SimulationStateMachine) extractor,
  ) => LineBuilder(
    name: def.chartName!,
    color: def.chartColor!,
    extractYAxisValue: extractor,
  );

  /// Format required by FlChart library for 2D-coordinates.
  final List<FlSpot> dataPoints = [];

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

class VerticalLineBuilder({
  required String name,
  required Color color,
  required double xValue,
}) extends LineBuilder {
  this
    : super(
        name: name,
        color: color,
        extractYAxisValue: (_) => throw NotImplementedError(),
      ) {
    dataPoints.add(FlSpot(xValue, 0)); // Line bottom.
    dataPoints.add(FlSpot(xValue, FinancialLineChart.maxY)); // Line top.
  }
}

class NotImplementedError() extends Error;
