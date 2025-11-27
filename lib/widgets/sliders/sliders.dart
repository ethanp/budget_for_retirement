import 'package:budget_for_retirement/model/financial_simulation.dart';
import 'package:budget_for_retirement/util/extensions.dart';
import 'package:budget_for_retirement/widgets/sliders/slider_insights.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  static const double headerHeight = 90;
  static const double insightsTopOffset = 8;
  static const double listTopPaddingWithInsights = 140;
  static const double listTopPaddingWithoutInsights = 86;

  @override
  Widget build(BuildContext context) {
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final double listTopPadding = _showInsightsOverlay
        ? listTopPaddingWithInsights + safeAreaTop
        : listTopPaddingWithoutInsights + safeAreaTop;

    return SizedBox(
      width: 400,
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
    final headerColor =
        Colors.orangeAccent[100]!.lerpWith(Colors.grey[400]!, .4);
    return Positioned(
      top: safeAreaTop,
      left: 0,
      right: 0,
      child: Container(
        width: double.infinity,
        height: headerHeight,
        decoration: BoxDecoration(
          color: headerColor,
          border: Border.all(color: Colors.black.withOpacity(.1)),
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _toggleInsightsButton(context),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _titleWithIcon,
                  ),
                  const SizedBox(width: 8),
                  _resetButton(context),
                ],
              ),
            ),
            _subtitle,
          ],
        ),
      ),
    );
  }

  Widget _toggleInsightsButton(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 0,
      onPressed: () {
        setState(() {
          _showInsightsOverlay = !_showInsightsOverlay;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _showInsightsOverlay
              ? Colors.grey[700]!.withOpacity(0.3)
              : Colors.grey[700]!.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          CupertinoIcons.chart_bar_alt_fill,
          size: 20,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _resetButton(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 0,
      onPressed: () {
        FinancialSimulation.dontWatch(context).reset();
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey[700]!.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          CupertinoIcons.arrow_counterclockwise,
          size: 20,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  static Widget _safeAreaGradient(BuildContext context, double safeAreaTop) {
    final headerColor =
        Colors.orangeAccent[100]!.lerpWith(Colors.grey[400]!, .4);
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
              Colors.white,
              headerColor,
            ],
          ),
        ),
      ),
    );
  }

  Widget get _titleWithIcon {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.slider_horizontal_3,
            size: 24,
            color: Colors.grey[800],
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Simulation Parameters',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  static Widget get _subtitle {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '"Real" Dollars (adjusted for inflation)',
        style: TextStyle(fontSize: 15, color: Colors.grey[800]),
      ),
    );
  }
}
