import 'package:budget_for_retirement/model/financial_simulation.dart';
import 'package:ethan_utils/ethan_utils.dart';
import 'package:budget_for_retirement/model/house_expenses.dart';
import 'package:budget_for_retirement/model/simulation_params.dart';
import 'package:budget_for_retirement/theme/app_colors.dart';
import 'package:budget_for_retirement/util/extensions.dart';
import 'package:budget_for_retirement/util/mutable_simulator_arg.dart';
import 'package:flutter/material.dart';

import 'under_chart_cards.dart';

class HousingCard() extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HousingCardState();
}

class _HousingCardState() extends UnderChartCardState<HousingCard> {
  @override
  bool folded = true;

  @override
  Widget title(BuildContext context) =>
      cardTitle(context, 'Housing (per month)');

  @override
  Widget content(BuildContext context) {
    final colors = AppColors.of(context);
    final SimulationParams sliders = FinancialSimulation.watchFrom(context)
        .sliderPositions;

    final List<DataColumn> tableColumnHeaders =
        <String>[
          'Age',
          'Price',
          'Down',
          ...[0, 10, 20, 30, 50].map((milestone) => '$milestone yrs'),
        ].mapL(
          (s) => DataColumn(
            label: Text(
              s,
              style: TextStyle(
                color: colors.textColor1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );

    List<DataRow> houseData(PrimaryResidence residence) =>
        _HousingMonthlyRows(residence, sliders, colors).rows;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 22,
        dataRowMinHeight: 22,
        columnSpacing: 10,
        dividerThickness: 1,
        columns: tableColumnHeaders,
        rows: sliders.primaryResidences.listInOrder
            .where((residence) => !residence.isRental)
            .expand(houseData)
            .toList(),
      ),
    );
  }
}

class _HousingMonthlyRows(
  final PrimaryResidence residence,
  final SimulationParams sliders,
  final AppColors colors,
) {
  List<DataRow> get rows => [
    DataRow(cells: _purchaseAndMonthlyTotalsRow(sliders)),
    DataRow(
      cells: _monthlyExpenseAtMilestones(
        'value',
        sliders,
        (h) => h.currentValue * 12,
        residence,
      ),
    ),
    DataRow(
      cells: _monthlyExpenseAtMilestones(
        'insurance',
        sliders,
        (h) => h.insurance,
        residence,
      ),
    ),
    DataRow(
      cells: _monthlyExpenseAtMilestones(
        'maintenance',
        sliders,
        (h) => h.maintenance,
        residence,
      ),
    ),
    DataRow(
      cells: _monthlyExpenseAtMilestones(
        'mortgage',
        sliders,
        (h) => h.realAnnualMortgagePayment,
        residence,
      ),
    ),
    DataRow(
      cells: _monthlyExpenseAtMilestones(
        'taxes',
        sliders,
        (h) => h.taxes,
        residence,
      ),
    ),
  ];

  static const yearsOut = [0, 10, 20, 30, 50];

  List<DataCell> _purchaseAndMonthlyTotalsRow(SimulationParams sliders) {
    return [
      DataCell(
        Text(
          residence.age.toString(),
          style: TextStyle(color: colors.textColor1),
        ),
      ),
      DataCell(
        Text(
          residence.price.asCompactDollars(),
          style: TextStyle(color: colors.textColor1),
        ),
      ),
      DataCell(
        Text(
          _houseExpenses(
            sliders,
            0,
            residence,
          ).downPaymentAmt.asCompactDollars(),
          style: TextStyle(color: colors.textColor1),
        ),
      ),
      ...yearsOut.map(
        (int yrs) => DataCell(
          Text(
            _houseExpenses(sliders, yrs, residence).monthly.asCompactDollars(),
            style: TextStyle(color: colors.textColor1),
          ),
        ),
      ),
    ];
  }

  List<DataCell> _monthlyExpenseAtMilestones(
    String title,
    SimulationParams sliders,
    double Function(HouseExpenses) getField,
    PrimaryResidence residence,
  ) {
    final dataStyle = TextStyle(color: colors.textColor3);
    final categoryLabelStyle = dataStyle.copyWith(fontStyle: FontStyle.italic);
    return [
      DataCell(Text('')),
      DataCell(Text('')),
      DataCell(Text(title, style: categoryLabelStyle)),
      ...yearsOut.map((int yrs) {
        final allAnnualExpenses = _houseExpenses(sliders, yrs, residence);
        var fieldMonthlyExpense = getField(allAnnualExpenses) / 12;
        return DataCell(
          Text(fieldMonthlyExpense.asCompactDollars(), style: dataStyle),
        );
      }),
    ];
  }

  HouseExpenses _houseExpenses(
    SimulationParams sliderPositions,
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
