import 'package:budget_for_retirement/model/financial_simulation.dart';
import 'package:budget_for_retirement/theme/app_colors.dart';
import 'package:budget_for_retirement/util/extensions.dart'
    show CompactCurrency;
import 'package:ethan_utils/ethan_utils.dart';
import 'package:budget_for_retirement/widgets/insights/insight_metrics.dart';
import 'package:budget_for_retirement/widgets/line_chart/forecast_line.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

abstract class UnderChartCardState<T extends StatefulWidget>()
    extends State<T> {
  bool folded = false;

  final bool expands = true;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: () => setState(() => folded = !folded),
      child: Card(
        color: colors.backgroundDepth2,
        margin: const EdgeInsets.all(4),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              title(context),
              Center(
                child: expands && folded
                    ? foldedHint(context)
                    : content(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget foldedHint(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: Text(
        'Click to reveal',
        style: TextStyle(fontStyle: FontStyle.italic, color: colors.textColor3),
      ),
    );
  }

  @protected
  Widget cardTitle(BuildContext context, String text) {
    final colors = AppColors.of(context);
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: colors.textColor1,
      ),
    );
  }

  @protected
  Widget title(BuildContext context);

  @protected
  Widget content(BuildContext context);
}

class LifespanCard() extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LifespanCardState();
}

class _LifespanCardState() extends UnderChartCardState<LifespanCard> {
  @override
  Widget title(BuildContext context) =>
      cardTitle(context, 'Lifespan simulated');
  @override
  final bool expands = false;

  @override
  Widget content(BuildContext context) {
    final colors = AppColors.of(context);
    final simulation = FinancialSimulation.watchFrom(context);
    final startingAge = simulation.sliderPositions.simulationStartingAge.now;
    final int endAge = simulation.sliderPositions.endAge.now;
    return Text(
      '$startingAge–to-$endAge',
      style: TextStyle(fontSize: 20, color: colors.accentPrimary),
    );
  }
}

class MinRetirementCard() extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MinRetirementCardState();
}

class _MinRetirementCardState() extends UnderChartCardState<MinRetirementCard> {
  @override
  Widget title(BuildContext context) =>
      cardTitle(context, 'Min retirement age');

  @override
  final bool expands = false;

  @override
  Widget content(BuildContext context) {
    final simulation = FinancialSimulation.watchFrom(context);
    final data = MinRetirementInsightData.ageOrNever(simulation);
    return Text(
      data.displayValue,
      style: TextStyle(fontSize: 20, color: data.color),
    );
  }
}

class NetWorthAt95Card() extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NetWorthAt95CardState();
}

class _NetWorthAt95CardState() extends UnderChartCardState<NetWorthAt95Card> {
  @override
  Widget title(BuildContext context) => cardTitle(context, 'Net worth at 95');

  @override
  final bool expands = false;

  @override
  Widget content(BuildContext context) {
    final simulation = FinancialSimulation.watchFrom(context);
    final data = NetWorthInsightData.at95(simulation);
    return Text(
      data.displayValue,
      style: TextStyle(fontSize: 20, color: data.color),
    );
  }
}

class ForecastTableCard() extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ForecastTableCardState();
}

class _ForecastTableCardState() extends UnderChartCardState<ForecastTableCard> {
  @override
  bool folded = true;

  @override
  Widget content(BuildContext context) {
    final colors = AppColors.of(context);
    final List<ForecastLine> forecastLines = FinancialSimulation.watchFrom(
      context,
    ).forecastLines.inLegendOrder;
    final List<FlSpot> firstLinePoints = forecastLines.first.dataPoints;

    final ageRowsWithForecastDollars = firstLinePoints.indices.map((idx) {
      final age = firstLinePoints[idx].x.floor().toString();
      final Iterable<String> lineValues = forecastLines.map(
        (forecastLine) => forecastLine.dataPoints[idx].y.asCompactDollars(),
      );
      final List<DataCell> dataCells = [age]
          .followedBy(lineValues)
          .map(
            (cellValue) => DataCell(
              Text(cellValue, style: TextStyle(color: colors.textColor2)),
            ),
          )
          .toList();
      return DataRow(cells: dataCells);
    }).toList();

    final List<DataColumn> columns = ['Age']
        .followedBy(forecastLines.map((line) => line.name))
        .map(
          (lineName) => DataColumn(
            label: Text(
              lineName,
              style: TextStyle(
                color: colors.textColor1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )
        .toList();

    return SizedBox(
      height: 400,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowHeight: 22,
            dataRowMinHeight: 12,
            columnSpacing: 12,
            dividerThickness: 1,
            columns: columns,
            rows: ageRowsWithForecastDollars,
          ),
        ),
      ),
    );
  }

  @override
  Widget title(BuildContext context) {
    return cardTitle(context, 'Forecast (table)');
  }
}
