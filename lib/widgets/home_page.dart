import 'dart:io';

import 'package:budget_for_retirement/widgets/line_chart/financial_line_chart.dart';
import 'package:budget_for_retirement/widgets/under_chart_cards/housing_card.dart';
import 'package:budget_for_retirement/widgets/under_chart_cards/under_chart_cards.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'sliders/sliders.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _updateOrientation(0);
  }

  void _updateOrientation(int index) {
    if (index == 1 || index == 2) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Platform.isIOS;

    if (isMobile) {
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
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
          onTap: (index) {
            _updateOrientation(index);
          },
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
                  child: SafeArea(
                    top: false,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          color: Colors.brown[700]!.withOpacity(.2),
                          padding: const EdgeInsets.all(1),
                          child: const FinancialLineChart(),
                        );
                      },
                    ),
                  ),
                ),
              );
            case 2:
              return CupertinoTabView(
                builder: (context) => Material(
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      child: underChartCards(),
                    ),
                  ),
                ),
              );
            default:
              return CupertinoTabView(
                builder: (context) => Material(
                  child: SafeArea(
                    top: false,
                    child: const Sliders(showInsightsOverlay: true),
                  ),
                ),
              );
          }
        },
      );
    }

    return Scaffold(
      body: Row(children: [
        const Sliders(),
        Expanded(child: chartAndCards),
      ]),
    );
  }

  Widget get chartAndCards {
    return Container(
      color: Colors.brown[700]!.withOpacity(.2),
      padding: const EdgeInsets.all(1),
      child: Column(children: [
        Expanded(child: const FinancialLineChart()),
        underChartCards(),
      ]),
    );
  }

  Widget get chartOnly {
    return Container(
      color: Colors.brown[700]!.withOpacity(.2),
      padding: const EdgeInsets.all(1),
      child: const FinancialLineChart(),
    );
  }

  Widget underChartCards() {
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

class _LandscapeChartWrapper extends StatefulWidget {
  const _LandscapeChartWrapper({required this.child});

  final Widget child;

  @override
  State<_LandscapeChartWrapper> createState() => _LandscapeChartWrapperState();
}

class _LandscapeChartWrapperState extends State<_LandscapeChartWrapper> {
  @override
  void initState() {
    super.initState();
    _setLandscape();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setLandscape();
  }

  void _setLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _setLandscape();
    return widget.child;
  }
}

class _PortraitOrientationWrapper extends StatefulWidget {
  const _PortraitOrientationWrapper({required this.child});

  final Widget child;

  @override
  State<_PortraitOrientationWrapper> createState() =>
      _PortraitOrientationWrapperState();
}

class _PortraitOrientationWrapperState
    extends State<_PortraitOrientationWrapper> {
  @override
  void initState() {
    super.initState();
    _setPortrait();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setPortrait();
  }

  void _setPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _setPortrait();
    return widget.child;
  }
}
