import 'package:budget_for_retirement/theme/app_colors.dart';
import 'package:flutter/material.dart';

class const SliderCard({required final Widget child}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Card(
      color: colors.backgroundDepth2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: child,
    );
  }
}

class const SliderGroup({
  required final String title,
  required final List<Widget> children,
  final List<Widget> headers = const [],
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: ListView(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: [_header(context), ...children],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      color: colors.backgroundDepth3,
      child: Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 4, left: 6, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _titleText(context),
            Row(children: headers),
          ],
        ),
      ),
    );
  }

  Widget _titleText(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: colors.textColor1,
        ),
      ),
    );
  }
}

class const SliderGroupTitleButton({
  required final VoidCallback? onTap,
  required final Widget child,
  required final bool isAdd,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final buttonColor = isAdd ? colors.successColor : colors.dangerColor;
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor.withValues(alpha: 0.7),
        foregroundColor: colors.textColor1,
        minimumSize: const Size(32, 32),
        maximumSize: const Size(32, 32),
        padding: const EdgeInsets.only(left: 6, right: 5, top: 3, bottom: 8),
      ),
      child: child,
    );
  }
}
