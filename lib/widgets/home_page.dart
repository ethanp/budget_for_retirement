import 'package:budget_for_retirement/theme/app_colors.dart';
import 'package:budget_for_retirement/widgets/line_chart/financial_line_chart.dart';
import 'package:budget_for_retirement/widgets/under_chart_cards/housing_card.dart';
import 'package:budget_for_retirement/widgets/under_chart_cards/under_chart_cards.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'sliders/sliders.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: colors.backgroundDepth2,
        activeColor: colors.accentPrimary,
        inactiveColor: colors.textColor3,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.slider_horizontal_3),
            label: 'Sliders',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar),
            label: 'Chart',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_list),
            label: 'Details',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) => Material(
                child: const Sliders(showInsightsOverlay: true),
              ),
            );
          case 1:
            return CupertinoTabView(
              builder: (context) => Material(
                color: colors.backgroundDepth1,
                child: SafeArea(
                  top: false,
                  child: Container(
                    color: colors.backgroundDepth1,
                    padding: const EdgeInsets.all(1),
                    child: const FinancialLineChart(),
                  ),
                ),
              ),
            );
          case 2:
            return CupertinoTabView(
              builder: (context) => Material(
                color: colors.backgroundDepth1,
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    child: underChartCards(context),
                  ),
                ),
              ),
            );
          default:
            return CupertinoTabView(
              builder: (context) => Material(
                child: const Sliders(showInsightsOverlay: true),
              ),
            );
        }
      },
    );
  }

  Widget underChartCards(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            LifespanCard(),
            MinRetirementCard(),
            FinalGrossCard(),
          ],
        ),
        HousingCard(),
        ForecastTableCard(),
      ],
    );
  }
}
