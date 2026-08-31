import 'package:budget_for_retirement/model/financial_simulation.dart';
import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/material.dart';

import 'forecast_line.dart';
import 'forecast_lines.dart';

class Legend() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 144,
      padding: const EdgeInsets.only(left: 10),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.yellow[50],
              border: Border.all(color: Colors.black12),
              borderRadius: const BorderRadius.all(Radius.circular(2)),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _legendItems(context)
                  .separatedBy(const _LegendItemSeparator()),
            ),
          ),
        ),
      ),
    );
  }

  Iterable<Widget> _legendItems(BuildContext context) {
    return _forecast(context).inLegendOrder
        .map<Widget>((l) => _LegendItem(l));
  }

  ForecastLines _forecast(BuildContext context) =>
      FinancialSimulation.dontWatch(context).forecastLines;
}

class const _LegendItem(final ForecastLine line) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [_lineColorSwatch(), _name()]),
    );
  }

  Widget _lineColorSwatch() {
    return Container(
      width: 11,
      height: 8,
      color: line.color,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _name() {
    return Expanded(
      child: Text(line.name, style: TextStyle(fontSize: 14), maxLines: 2),
    );
  }
}

class const _LegendItemSeparator() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Container(height: 1, color: Colors.black12),
    );
  }
}
