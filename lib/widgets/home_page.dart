import 'package:budget_for_retirement/theme/app_colors.dart';
import 'package:budget_for_retirement/widgets/line_chart/forecast_chart.dart';
import 'package:budget_for_retirement/widgets/under_chart_cards/housing_card.dart';
import 'package:budget_for_retirement/widgets/under_chart_cards/under_chart_cards.dart';
import 'package:ethan_ui/ethan_ui.dart';
import 'package:flutter/material.dart';

import 'sliders/sliders.dart';

class const MainTab({
  required final IconData icon,
  required final String label,
  required final Widget screen,
});

const _mainTabs = <MainTab>[
  MainTab(
    icon: Icons.tune,
    label: 'Sliders',
    screen: Sliders(showSliderInsights: true),
  ),
  MainTab(icon: Icons.bar_chart, label: 'Chart', screen: _ChartTab()),
  MainTab(icon: Icons.view_list, label: 'Details', screen: _DetailsTab()),
];

class HomePage() extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState() extends State<HomePage> {
  int _selectedTabIndex = 0;
  final _navigatorKeys = List<GlobalKey<NavigatorState>>.generate(
    _mainTabs.length,
    (_) => GlobalKey<NavigatorState>(),
  );

  @override
  Widget build(BuildContext context) {
    return EScaffoldShell(
      contentMaxWidth: double.infinity,
      bottomBar: ETabBar(
        selectedIndex: _selectedTabIndex,
        tabs: [
          for (final tab in _mainTabs) ETab(icon: tab.icon, label: tab.label),
        ],
        onSelected: (index) {
          if (index == _selectedTabIndex) {
            _navigatorKeys[index].currentState?.popUntil(
              (route) => route.isFirst,
            );
            return;
          }
          setState(() => _selectedTabIndex = index);
        },
      ),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: [
          for (var tabIndex = 0; tabIndex < _mainTabs.length; tabIndex++)
            Navigator(
              key: _navigatorKeys[tabIndex],
              onGenerateRoute: (settings) => MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => _mainTabs[tabIndex].screen,
              ),
            ),
        ],
      ),
    );
  }
}

class const _ChartTab() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return ColoredBox(
      color: colors.backgroundDepth1,
      child: const Padding(
        padding: EdgeInsets.all(1),
        child: ForecastChart(),
      ),
    );
  }
}

class const _DetailsTab() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return ColoredBox(
      color: colors.backgroundDepth1,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [LifespanCard(), MinRetirementCard(), NetWorthAt95Card()],
            ),
            HousingCard(),
            ForecastTableCard(),
          ],
        ),
      ),
    );
  }
}
