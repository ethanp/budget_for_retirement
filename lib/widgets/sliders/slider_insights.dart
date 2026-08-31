import 'package:budget_for_retirement/model/financial_simulation.dart';
import 'package:budget_for_retirement/theme/app_colors.dart';
import 'package:budget_for_retirement/widgets/insights/insight_metrics.dart';
import 'package:flutter/material.dart';

class const SliderInsights() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final simulation = FinancialSimulation.watchFrom(context);
    final minRetirementData = MinRetirementInsightData.ageOrNever(simulation);
    final netWorthData = NetWorthInsightData.at95(simulation);
    final netWorthAt45Data = NetWorthInsightData.at45(simulation);

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceForHealth(
          isHealthy: simulation.isFinanciallyHealthy,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.borderDepth1, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: _InsightTile(
              label: 'Min retire',
              value: minRetirementData.displayValue,
              valueColor: minRetirementData.color,
            ),
          ),
          _divider(context),
          Expanded(
            child: _InsightTile(
              label: 'At 45',
              value: netWorthAt45Data.displayValue,
              valueColor: netWorthAt45Data.color,
            ),
          ),
          _divider(context),
          Expanded(
            child: _InsightTile(
              label: 'At 95',
              value: netWorthData.displayValue,
              valueColor: netWorthData.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: colors.borderDepth1,
    );
  }
}

class const _InsightTile({
  required final String label,
  required final String value,
  required final Color valueColor,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colors.textColor1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
