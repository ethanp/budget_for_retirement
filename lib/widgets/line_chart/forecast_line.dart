import 'package:budget_for_retirement/model/param_definition.dart';
import 'package:budget_for_retirement/model/simulation_state_machine.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'forecast_chart.dart';

class ForecastLine({
  required final String name,
  required final Color color,
  required final double Function(SimulationStateMachine) dollarsAt,
}) {
  factory fromChartDefinition(
    ParamDefinition def,
    double Function(SimulationStateMachine) dollarsAt,
  ) => ForecastLine(
    name: def.chartName!,
    color: def.chartColor!,
    dollarsAt: dollarsAt,
  );

  final List<FlSpot> dataPoints = [];

  void recordYear(SimulationStateMachine lifeState) {
    dataPoints.add(
      FlSpot(
        lifeState.lifeEvents.currentAge.toDouble(),
        dollarsAt(lifeState),
      ),
    );
  }
}

class LifeEventMarker({
  required String name,
  required Color color,
  required double age,
}) extends ForecastLine {
  this
    : super(
        name: name,
        color: color,
        dollarsAt: (_) => throw NotImplementedError(),
      ) {
    dataPoints.add(FlSpot(age, 0));
    dataPoints.add(FlSpot(age, ForecastChart.maxY));
  }
}

class NotImplementedError() extends Error;
