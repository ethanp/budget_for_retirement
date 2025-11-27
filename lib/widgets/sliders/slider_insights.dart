import 'package:budget_for_retirement/model/financial_simulation.dart';
import 'package:budget_for_retirement/widgets/insights/insight_metrics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SliderInsights extends StatelessWidget {
  const SliderInsights();

  @override
  Widget build(BuildContext context) {
    final simulation = FinancialSimulation.watchFrom(context);
    final minRetirementData = buildMinRetirementInsightData(simulation);
    final netWorthData = buildNetWorthInsightData(simulation);
    final netWorthAt45Data = buildNetWorthAtAge45InsightData(simulation);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      child: Row(
        children: [
          Expanded(
            child: _InsightTile(
              label: 'Min retirement age',
              value: minRetirementData.displayValue,
              valueColor: minRetirementData.color,
              icon: CupertinoIcons.person_badge_plus,
            ),
          ),
          Container(
            width: 1,
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.grey[200],
          ),
          Expanded(
            child: _InsightTile(
              label: 'Net worth at death',
              value: netWorthData.displayValue,
              valueColor: netWorthData.color,
              icon: CupertinoIcons.money_dollar_circle,
            ),
          ),
          Container(
            width: 1,
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.grey[200],
          ),
          Expanded(
            child: _InsightTile(
              label: 'Net worth at 45',
              value: netWorthAt45Data.displayValue,
              valueColor: netWorthAt45Data.color,
              icon: CupertinoIcons.calendar,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.icon,
  });

  final String label;
  final String value;
  final Color valueColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[700]),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
