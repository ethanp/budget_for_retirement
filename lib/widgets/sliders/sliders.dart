import 'package:budget_for_retirement/model/financial_simulation.dart';
import 'package:budget_for_retirement/theme/app_colors.dart';
import 'package:budget_for_retirement/theme/theme_notifier.dart';
import 'package:budget_for_retirement/widgets/insights/insight_metrics.dart';
import 'package:budget_for_retirement/widgets/sliders/slider_insights.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'sliders_list_view.dart';

class Sliders extends StatefulWidget {
  const Sliders({this.showInsightsOverlay = false});

  final bool showInsightsOverlay;

  @override
  State<Sliders> createState() => _SlidersState();
}

class _SlidersState extends State<Sliders> {
  late bool _showInsightsOverlay;

  @override
  void initState() {
    super.initState();
    _showInsightsOverlay = widget.showInsightsOverlay;
  }

  static const double headerHeight = 58;
  static const double insightsTopOffset = 4;
  static const double insightsHeight = 16;

  @override
  Widget build(BuildContext context) {
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final double listTopPadding = safeAreaTop +
        headerHeight +
        (_showInsightsOverlay ? insightsTopOffset + insightsHeight : 0);
    final colors = AppColors.of(context);

    return Container(
      width: 400,
      color: colors.backgroundDepth1,
      child: Stack(
        children: [
          _slidersListView(listTopPadding),
          if (_showInsightsOverlay) _insightsOverlay(context, safeAreaTop),
          _header(context, safeAreaTop),
          if (safeAreaTop > 0) _safeAreaGradient(context, safeAreaTop),
        ],
      ),
    );
  }

  static Widget _slidersListView(double topPadding) {
    return Column(children: [
      SizedBox(height: topPadding),
      Expanded(child: SlidersListView()),
    ]);
  }

  Widget _insightsOverlay(BuildContext context, double safeAreaTop) {
    return Positioned(
      top: headerHeight + safeAreaTop + insightsTopOffset,
      left: 16,
      right: 16,
      child: const SliderInsights(),
    );
  }

  Widget _header(BuildContext context, double safeAreaTop) {
    final colors = AppColors.of(context);
    final simulation = FinancialSimulation.watchFrom(context);

    return Positioned(
      top: safeAreaTop,
      left: 0,
      right: 0,
      child: Container(
        width: double.infinity,
        height: headerHeight,
        decoration: BoxDecoration(
          color: colors.surfaceForHealth(
              isHealthy: isFinanciallyHealthy(simulation)),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _themeToggle(context),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _title(context),
                    _subtitle(context),
                  ],
                ),
              ),
              _resetButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themeToggle(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final isDark = themeNotifier.isDark;
    return _HeaderButton(
      icon: isDark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill,
      label: 'theme',
      onPressed: () => themeNotifier.toggle(),
    );
  }

  Widget _resetButton(BuildContext context) {
    return _HeaderButton(
      icon: CupertinoIcons.arrow_counterclockwise,
      label: 'reset',
      onPressed: () => FinancialSimulation.dontWatch(context).reset(),
    );
  }

  Widget _safeAreaGradient(BuildContext context, double safeAreaTop) {
    final colors = AppColors.of(context);
    final simulation = FinancialSimulation.watchFrom(context);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: safeAreaTop,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.backgroundDepth1,
              colors.surfaceForHealth(
                  isHealthy: isFinanciallyHealthy(simulation)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    final colors = AppColors.of(context);
    return Text(
      'Retirement Planner',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: colors.textColor1,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  Widget _subtitle(BuildContext context) {
    final colors = AppColors.of(context);
    return Text(
      '"Real" Dollars (adjusted for inflation)',
      style: TextStyle(fontSize: 11, color: colors.textColor3),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 0,
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: colors.backgroundDepth2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: colors.textColor2),
          ),
          Text(label, style: TextStyle(fontSize: 9, color: colors.textColor3)),
        ],
      ),
    );
  }
}
