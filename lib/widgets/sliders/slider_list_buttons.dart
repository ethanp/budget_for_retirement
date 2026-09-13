import 'package:budget_for_retirement/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SliderListButton() {
  static Widget addWithConnectors({
    required BuildContext context,
    required String suffix,
    required VoidCallback onPressed,
  }) {
    final colors = AppColors.of(context);
    return _betweenConnectors(
      context,
      _button(
        context: context,
        text: 'Add a $suffix',
        foreground: colors.successColor,
        background: colors.backgroundDepth2,
        onPressed: onPressed,
      ),
    );
  }

  static Widget delete({
    required BuildContext context,
    required VoidCallback onPressed,
  }) {
    final colors = AppColors.of(context);
    return _button(
      context: context,
      text: 'Delete',
      foreground: colors.dangerColor,
      background: colors.backgroundDepth2,
      onPressed: onPressed,
    );
  }

  static Widget _connectorBar(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 10,
      width: 8,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colors.backgroundDepth4,
                  colors.backgroundDepth3,
                  colors.backgroundDepth5,
                  colors.backgroundDepth3,
                  colors.backgroundDepth4,
                ]
              : [
                  colors.borderDepth1,
                  colors.backgroundDepth4,
                  colors.backgroundDepth2,
                  colors.backgroundDepth4,
                  colors.borderDepth1,
                ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
      ),
    );
  }

  static Widget _betweenConnectors(BuildContext context, Widget button) =>
      Column(
        children: [
          _connectorBar(context),
          button,
          _connectorBar(context),
        ],
      );

  static Widget _button({
    required BuildContext context,
    required String text,
    required Color foreground,
    required Color background,
    required VoidCallback onPressed,
  }) {
    final colors = AppColors.of(context);
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: foreground,
        backgroundColor: background,
        side: BorderSide(color: colors.borderDepth2),
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 12),
      ),
      onPressed: onPressed,
      child: Text(text, style: TextStyle(fontSize: 12)),
    );
  }
}
