import 'package:budget_for_retirement/model/financial_simulation.dart';
import 'package:budget_for_retirement/model/house_expenses.dart';
import 'package:budget_for_retirement/model/user_specified_parameters.dart';
import 'package:budget_for_retirement/util/extensions.dart';
import 'package:budget_for_retirement/util/mutable_simulator_arg.dart';
import 'package:flutter/material.dart';

import 'under_chart_cards.dart';

class HousingCard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HousingCardState();
}

class _HousingCardState extends UnderChartCardState<HousingCard> {
  @override
  bool folded = true;

  @override
  Widget title() => titleStyle('Housing (per month)');

  @override
  Widget content(BuildContext context) {
    final UserSpecifiedParameters sliders =
        FinancialSimulation.watchFrom(context).sliderPositions;

    final List<DataColumn> tableColumnHeaders = <String>[
      'Age',
      'Price',
      'Down',
      ...[0, 10, 20, 30, 50].map((milestone) => '$milestone yrs'),
    ].mapL((s) => DataColumn(label: Text(s)));

    List<DataRow> houseData(PrimaryResidence residence) =>
        _HousingCardRowsBuilder(
          residence,
          sliders,
        ).build;

    return DataTable(
      headingRowHeight: 22,
      dataRowMinHeight: 22,
      columnSpacing: 10,
      dividerThickness: 1,
      columns: tableColumnHeaders,
      rows: sliders.primaryResidences.listInOrder
          .where((residence) => !residence.isRental)
          .expand(houseData)
          .toList(),
    );
  }
}

class _HousingCardRowsBuilder {
  _HousingCardRowsBuilder(this.residence, this.sliders);

  final PrimaryResidence residence;
  final UserSpecifiedParameters sliders;

  List<DataRow> get build => [
        DataRow(cells: _combinedRow(sliders)),
        DataRow(
          cells: _getARow(
            'value',
            sliders,
            (h) => h.currentValue * 12,
            residence,
          ),
        ),
        DataRow(
          cells: _getARow(
            'insurance',
            sliders,
            (h) => h.insurance,
            residence,
          ),
        ),
        DataRow(
          cells: _getARow(
            'maintenance',
            sliders,
            (h) => h.maintenance,
            residence,
          ),
        ),
        DataRow(
          cells: _getARow(
            'mortgage',
            sliders,
            (h) => h.realAnnualMortgagePayment,
            residence,
          ),
        ),
        DataRow(
          cells: _getARow(
            'taxes',
            sliders,
            (h) => h.taxes,
            residence,
          ),
        ),
      ];

  static const yearsOut = [0, 10, 20, 30, 50];

  List<DataCell> _combinedRow(UserSpecifiedParameters sliders) {
    return [
      DataCell(Text(residence.age.toString())),
      DataCell(Text(residence.price.asCompactDollars())),
      DataCell(Text(_houseExpenses(sliders, 0, residence)
          .downPaymentAmt
          .asCompactDollars())),
      ...yearsOut.map(
        (int yrs) => DataCell(
          Text(_houseExpenses(sliders, yrs, residence)
              .monthly
              .asCompactDollars()),
        ),
      ),
    ];
  }

  List<DataCell> _getARow(
    String title,
    UserSpecifiedParameters sliders,
    double Function(HouseExpenses) getField,
    PrimaryResidence residence,
  ) {
    final dataStyle = TextStyle(color: Colors.blueGrey[300]);
    final titleStyle = dataStyle.copyWith(fontStyle: FontStyle.italic);
    return [
      DataCell(Text('')),
      DataCell(Text('')),
      DataCell(Text(title, style: titleStyle)),
      ...yearsOut.map(
        (int yrs) {
          final allAnnualExpenses = _houseExpenses(sliders, yrs, residence);
          var fieldMonthlyExpense = getField(allAnnualExpenses) / 12;
          return DataCell(
            Text(
              fieldMonthlyExpense.asCompactDollars(),
              style: dataStyle,
            ),
          );
        },
      ),
    ];
  }

  HouseExpenses _houseExpenses(
    UserSpecifiedParameters sliderPositions,
    int yearsInHouse,
    PrimaryResidence residence,
  ) {
    return HouseExpenses.at(
      yearsInHouse: yearsInHouse,
      purchasePrice: residence.price,
      mortgageApr: residence.mortgageApr,
      housingAppreciationRate: residence.housingAppreciateRate,
      propertyTaxRate: residence.propertyTaxRate,
      insurancePrice: residence.insurancePrice.now,
      hoaPrice: residence.hoaPrice.now,
      downPayment: residence.downPayment,
      inflationRate: sliderPositions.inflationRate,
    );
  }
}
