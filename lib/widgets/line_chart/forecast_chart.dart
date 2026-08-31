import 'dart:math';

import 'package:ethan_utils/ethan_utils.dart';

import 'package:budget_for_retirement/model/financial_simulation.dart';
import 'package:budget_for_retirement/model/simulation_params.dart';
import 'package:budget_for_retirement/util/extensions.dart';
import 'package:budget_for_retirement/widgets/line_chart/forecast_line.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'legend.dart';
import 'forecast_lines.dart';

class const ForecastChart() extends StatelessWidget {
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
        child: Column(
          children: [
            if (!isLandscape) _forecastTitle(context),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _forecastChart(context)),
                  Legend(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ForecastLines _forecast(BuildContext context) =>
      FinancialSimulation.dontWatch(context).forecastLines;

  Widget _forecastChart(BuildContext context) {
    FinancialSimulation.watchFrom(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final horizLines = 5;
    final horizInterval = maxY / horizLines - 1;
    return Padding(
      padding: EdgeInsets.all(isLandscape ? 4 : 14),
      child: LineChart(
        LineChartData(
          lineTouchData: _ageAndDollarsTooltip(context),
          gridData: _decadeAndDollarBandGrid(horizInterval),
          titlesData: _ageDollarsAndEventLabels(context, horizInterval),
          borderData: _leftAndBottomBorder(),
          lineBarsData: _forecastAndEventStrokes(context),
          minX: _sliderPositions(context).simulationStartingAge.now - 2.0,
          maxX: _sliderPositions(context).endAge.now + 2.0,
          minY: 0,
          maxY: maxY,
        ),
      ),
    );
  }

  FlGridData _decadeAndDollarBandGrid(double horizInterval) {
    return FlGridData(
      show: true,
      horizontalInterval: horizInterval,
      drawVerticalLine: true,
      verticalInterval: 1,
      checkToShowVerticalLine: (v) => v % 10 == 0,
    );
  }

  SimulationParams _sliderPositions(BuildContext context) =>
      FinancialSimulation.dontWatch(context).sliderPositions;

  List<LineChartBarData> _forecastAndEventStrokes(BuildContext context) {
    final List<ForecastLine> forecastLines = _forecast(context).inLegendOrder;
    final List<LifeEventMarker> lifeEventMarkers = _lifeEventMarkers(context);
    return (forecastLines + lifeEventMarkers).mapL(_solidForecastOrDashedEvent);
  }

  List<LifeEventMarker> _lifeEventMarkers(BuildContext context) =>
      ForecastLines.lifeEventMarkers(_sliderPositions(context));

  FlBorderData _leftAndBottomBorder() {
    return FlBorderData(
      show: true,
      border: const Border(
        bottom: BorderSide(color: Colors.blueGrey, width: 1.2),
        left: BorderSide(color: Colors.blueGrey, width: 1.2),
      ),
    );
  }

  FlTitlesData _ageDollarsAndEventLabels(
    BuildContext context,
    double horizInterval,
  ) {
    return FlTitlesData(
      bottomTitles: _decadeTicksAndAgeLabel(context),
      leftTitles: _compactDollarTicks(context, horizInterval),
      topTitles: _rotatedLifeEventNames(context),
    );
  }

  AxisTitles _decadeTicksAndAgeLabel(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final labelValue = 58;
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
              ? value.round().toString()
              : value == labelValue
              ? (isLandscape ? 'Age' : '\nAge')
              : '';
          final TextStyle style = value == labelValue ? labelStyle : valueStyle;
          return Text(text, style: style);
        },
      ),
    );
  }

  AxisTitles _compactDollarTicks(BuildContext context, double horizInterval) {
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

  AxisTitles _rotatedLifeEventNames(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: isLandscape ? 12 : 22,
        getTitlesWidget: (value, meta) {
          final Iterable<LifeEventMarker> labels = _lifeEventMarkers(context)
              .where((l) => l.dataPoints.first.x.toInt() == value.toInt());
          return Transform.rotate(
            angle: pi / 4,
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

  Widget _forecastTitle(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.bar_chart,
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

  LineTouchData _ageAndDollarsTooltip(BuildContext context) {
    final forecastLines = _forecast(context).inLegendOrder;
    final lifeEventMarkers = _lifeEventMarkers(context);
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) => Colors.white.withValues(alpha: .9),
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipItems: (List<LineBarSpot> spotsOnBars) => [
          ...spotsOnBars.map((spotOnBar) {
            final String string = _forecastOrEventCaption(
              spotOnBar,
              forecastLines,
              lifeEventMarkers,
            );
            return LineTooltipItem(
              string,
              TextStyle(
                color: spotOnBar.bar.color!.withValues(alpha: 1),
                fontSize: 12,
              ),
              children: [
                if (spotOnBar == spotsOnBars.last)
                  TextSpan(
                    text: '\nAge: ${spotOnBar.x.toInt()}',
                    style: TextStyle(
                      color: Colors.black,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _forecastOrEventCaption(
    LineBarSpot spotOnBar,
    List<ForecastLine> forecastLines,
    List<LifeEventMarker> lifeEventMarkers,
  ) {
    final isForecastLine = spotOnBar.barIndex < forecastLines.length;
    if (isForecastLine) {
      final String name = forecastLines[spotOnBar.barIndex].name;
      final String amt = spotOnBar.y.asCompactDollars();
      return '$name: $amt';
    }
    final index = spotOnBar.barIndex - forecastLines.length;
    final String name = lifeEventMarkers[index].name;
    return 'Event: $name';
  }

  LineChartBarData _solidForecastOrDashedEvent(ForecastLine line) {
    final isLifeEvent = line is LifeEventMarker;
    return LineChartBarData(
      spots: line.dataPoints,
      color: line.color,
      barWidth: 2,
      isStrokeCapRound: !isLifeEvent,
      dashArray: isLifeEvent ? [6, 4] : null,
      dotData: FlDotData(show: false),
    );
  }
}
