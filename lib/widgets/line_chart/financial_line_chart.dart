import 'dart:math';

import 'package:budget_for_retirement/model/financial_simulation.dart';
import 'package:budget_for_retirement/model/simulation_params.dart';
import 'package:budget_for_retirement/util/extensions.dart';
import 'package:budget_for_retirement/widgets/line_chart/line_builder.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'legend.dart';
import 'lines_builder.dart';

class FinancialLineChart extends StatelessWidget {
  const FinancialLineChart();

  static const maxY = 5e6;

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final padding = isLandscape
        ? const EdgeInsets.only(bottom: 2, top: 2, right: 4, left: 2)
        : const EdgeInsets.only(bottom: 28, top: 10, right: 16);

    return Card(
      child: Padding(
        padding: padding,
        child: Column(children: [
          if (!isLandscape) _chartTitle(context),
          Expanded(
            child: Row(children: [
              Expanded(child: _lineChart(context)),
              Legend(),
            ]),
          ),
        ]),
      ),
    );
  }

  LinesBuilder _latestData(BuildContext context) =>
      FinancialSimulation.dontWatch(context).latestData;

  Widget _lineChart(BuildContext context) {
    FinancialSimulation.watchFrom(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final horizLines = 5;
    final horizInterval = maxY / horizLines - 1;
    return Padding(
      padding: EdgeInsets.all(isLandscape ? 4 : 14),
      child: LineChart(
        LineChartData(
          lineTouchData: _showTooltip(context),
          gridData: _gridLines(horizInterval),
          titlesData: _axisLabels(context, horizInterval),
          borderData: _borderLines(),
          lineBarsData: _lineData(context),

          // Define the domain and range of the chart.
          minX: _initialLifeState(context).simulationStartingAge.now - 2.0,
          maxX: _initialLifeState(context).endAge.now + 2.0,
          minY: 0,
          maxY: maxY,
        ),
      ),
    );
  }

  FlGridData _gridLines(double horizInterval) {
    return FlGridData(
      show: true,
      horizontalInterval: horizInterval,
      drawVerticalLine: true,
      verticalInterval: 1,
      checkToShowVerticalLine: (v) => v % 10 == 0,
    );
  }

  SimulationParams _initialLifeState(BuildContext context) =>
      FinancialSimulation.dontWatch(context).sliderPositions;

  List<LineChartBarData> _lineData(BuildContext context) {
    final List<LineBuilder> horizontalLines =
        _latestData(context).horizontalLines;
    final List<VerticalLineBuilder> verticalLines = _verticalLines(context);
    return (horizontalLines + verticalLines).mapL(_line);
  }

  List<VerticalLineBuilder> _verticalLines(BuildContext context) =>
      LinesBuilder.verticalLines(_initialLifeState(context));

  FlBorderData _borderLines() {
    return FlBorderData(
      show: true,
      border: const Border(
        bottom: BorderSide(color: Colors.blueGrey, width: 1.2),
        left: BorderSide(color: Colors.blueGrey, width: 1.2),
      ),
    );
  }

  FlTitlesData _axisLabels(BuildContext context, double horizInterval) {
    return FlTitlesData(
      bottomTitles: _labelXAxis(context),
      leftTitles: _labelYAxis(context, horizInterval),
      topTitles: _labelVerticalLines(context),
    );
  }

  AxisTitles _labelXAxis(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final labelValue = 58; // somewhere near the middle
    final labelStyle = TextStyle(
      color: Colors.blueGrey,
      fontSize: isLandscape ? 12 : 18,
      fontWeight: FontWeight.w600,
    );
    final valueStyle = TextStyle(
      color: Colors.blueGrey,
      fontSize: isLandscape ? 10 : 16,
    );
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: isLandscape ? 12 : 22,
        interval: 1,
        getTitlesWidget: (value, meta) {
          final String text = value % 10 == 0
              // Label the start of each decade.
              ? value.round().toString()
              : value == labelValue
                  // Label the axis.
                  ? (isLandscape ? 'Age' : '\nAge')
                  : '';
          final TextStyle style = value == labelValue ? labelStyle : valueStyle;
          return Text(text, style: style);
        },
      ),
    );
  }

  AxisTitles _labelYAxis(BuildContext context, double horizInterval) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) => Text(
          value.asCompactDollars(),
          style: TextStyle(
            color: Colors.blueGrey,
            letterSpacing: -.5,
            fontSize: isLandscape ? 9 : 12,
          ),
        ),
        interval: horizInterval,
        reservedSize: isLandscape ? 32 : 50,
      ),
    );
  }

  AxisTitles _labelVerticalLines(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: isLandscape ? 12 : 22,
        getTitlesWidget: (value, meta) {
          final Iterable<VerticalLineBuilder> labels = _verticalLines(context)
              .where((l) => l.dataPoints.first.x.toInt() == value.toInt());
          return Transform.rotate(
            angle: pi / 4, // rotate 45 degrees (in radians)
            child: Text(
              labels.isEmpty ? '' : labels.first.name,
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: isLandscape ? 8 : 11,
              ),
            ),
          );
        },
        interval: 1,
      ),
    );
  }

  Widget _chartTitle(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          CupertinoIcons.chart_bar,
          size: isLandscape ? 20 : 28,
          color: Colors.black,
        ),
        SizedBox(width: isLandscape ? 4 : 8),
        Text(
          'Forecast',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: isLandscape ? 18 : 28,
          ),
        ),
      ],
    );
  }

  LineTouchData _showTooltip(BuildContext context) {
    final horizontalLines = _latestData(context).horizontalLines;
    final verticalLines = _verticalLines(context);
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) => Colors.white.withOpacity(.9),
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipItems: (List<LineBarSpot> spotsOnBars) => [
          ...spotsOnBars.map((spotOnBar) {
            final String string = _tooltipString(
              spotOnBar,
              horizontalLines,
              verticalLines,
            );
            return LineTooltipItem(
              string,
              TextStyle(
                color: spotOnBar.bar.color!.withOpacity(1),
                fontSize: 12,
              ),
              children: [
                // Chart library dictates that #tooltip_items == #touched_spots,
                // so to show the date as a separate line, we append it to the
                // last tooltip. Yes, the touched spots are [Equatable].
                if (spotOnBar == spotsOnBars.last)
                  TextSpan(
                    text: '\nAge: ${spotOnBar.x.toInt()}',
                    style: TextStyle(
                      color: Colors.black,
                      fontStyle: FontStyle.italic,
                    ),
                  )
              ],
            );
          }),
        ],
      ),
    );
  }

  String _tooltipString(
    LineBarSpot spotOnBar,
    List<LineBuilder> horizontalLines,
    List<VerticalLineBuilder> verticalLines,
  ) {
    // NB: We only know it's horizontal because of the barIndex.
    final isHorizontal = spotOnBar.barIndex < horizontalLines.length;
    String string;
    if (isHorizontal) {
      final String name = horizontalLines[spotOnBar.barIndex].name;
      final String amt = spotOnBar.y.asCompactDollars();
      string = '$name: $amt';
    } else {
      final index = spotOnBar.barIndex - horizontalLines.length;
      final String name = verticalLines[index].name;
      string = 'Event: $name';
    }
    return string;
  }

  LineChartBarData _line(LineBuilder line) {
    final isVertical = line.runtimeType == VerticalLineBuilder;
    return LineChartBarData(
      spots: line.dataPoints,
      color: line.color,
      barWidth: 2,
      isStrokeCapRound: !isVertical,
      dashArray: isVertical ? [6, 4] : null,
      dotData: FlDotData(show: false),
    );
  }
}
