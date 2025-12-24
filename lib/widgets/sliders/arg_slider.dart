import 'dart:math' as math;

import 'package:budget_for_retirement/model/financial_simulation.dart';
import 'package:budget_for_retirement/theme/app_colors.dart';
import 'package:budget_for_retirement/util/config_metadata.dart';
import 'package:budget_for_retirement/util/mutable_simulator_arg.dart';
import 'package:flutter/material.dart';

import 'metadata_badge.dart';

/// Primary UX element for configuring arguments to the [FinancialSimulation].
class ArgSlider extends StatelessWidget {
  ArgSlider({
    required this.title,
    this.minimum = 0,
    required this.maximum,
    required this.slidableValue,
    this.slidableMinimumValidValue,
    this.endsWithNever = false,
    this.metadata,
  }) {
    if (minimum > slidableValue.now) slidableValue.slideTo(minimum);
    if (maximum < slidableValue.now) slidableValue.slideTo(maximum);
  }

  final String title;
  final double minimum;
  final double maximum;
  final SlidableSimulatorArg slidableValue;
  final ConfigMetadata? metadata;

  final bool endsWithNever;
  final SlidableSimulatorArg? slidableMinimumValidValue;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: math.pow(title.length, 3) / 3000),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          color:
              tooLow ? colors.dangerColor.withOpacity(.4) : Colors.transparent,
        ),
        height: 34,
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              titleWithBadge(context),
              slider(context, constraints),
              Flexible(child: triangleButtons(context)),
              Flexible(child: textInput(context)),
              tooLow ? tooLowText(context) : SizedBox(width: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget titleWithBadge(BuildContext context) {
    final colors = AppColors.of(context);
    final showBadge = metadata != null && metadata!.hasData;
    return Container(
      width: 130,
      padding: const EdgeInsets.only(right: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                height: 1.2,
                letterSpacing: -0.6,
                wordSpacing: -1,
                color: colors.textColor2,
              ),
            ),
          ),
          if (showBadge) ...[
            const SizedBox(width: 4),
            MetadataBadge(metadata: metadata!),
          ],
        ],
      ),
    );
  }

  Widget slider(BuildContext context, BoxConstraints constraints) {
    final colors = AppColors.of(context);
    return SizedBox(
      width: constraints.maxWidth / 2.9,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 7,
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 9),
          thumbShape: const RoundSliderThumbShape(
            enabledThumbRadius: 6,
            elevation: 3,
          ),
          inactiveTrackColor: colors.backgroundDepth4,
          thumbColor: colors.accentSecondary,
          activeTrackColor: colors.accentPrimary,
        ),
        child: Slider(
          value: slidableValue.now.toDouble(),
          min: minimum,
          max: maximum,
          divisions: 100,
          onChanged: (double newValue) => updateValue(newValue, context),
        ),
      ),
    );
  }

  void updateValue(double newValue, BuildContext context) {
    slidableValue.slideTo(newValue);
    FinancialSimulation.dontWatch(context).run();
  }

  final TextEditingController textEditingController = TextEditingController();

  Widget textInput(BuildContext context) {
    final colors = AppColors.of(context);
    final sayNever = !tooLow && endsWithNever && slidableValue.now == maximum;
    textEditingController.text = sayNever ? 'never' : '$slidableValue';
    return SizedBox(
      width: 62,
      child: TextField(
        controller: textEditingController,
        onSubmitted: (String userInput) {
          final newValue = textFromUser(userInput);
          if (newValue != null) updateValue(newValue, context);
        },
        decoration: InputDecoration(isDense: true, border: InputBorder.none),
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 15,
          color: colors.textColor1,
        ),
      ),
    );
  }

  Widget tooLowText(BuildContext context) {
    final colors = AppColors.of(context);
    return Text(
      '  Too low',
      style: TextStyle(
        color: colors.dangerColor,
        fontWeight: FontWeight.w700,
        fontSize: 10,
      ),
    );
  }

  double? textFromUser(String userInput) {
    if (userInput.characters.first == '\$') {
      userInput = userInput.substring(1);
    }
    int multiplier = 1;
    String lastLetter = userInput.characters.last;
    if ({'k', 'K'}.contains(lastLetter)) {
      userInput = userInput.substring(0, userInput.length - 1);
      multiplier = 1000;
    } else if ({'m', 'M'}.contains(lastLetter)) {
      userInput = userInput.substring(0, userInput.length - 1);
      multiplier = 1000 * 1000;
    }
    final double? inputValue = double.tryParse(userInput);
    if (inputValue == null) {
      print('WARNING: invalid user input $inputValue');
      return null;
    }
    return inputValue * multiplier;
  }

  Widget triangleButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        triangleButton(context, _TriangleDirection.down),
        SizedBox(width: 4),
        triangleButton(context, _TriangleDirection.up),
      ],
    );
  }

  Widget triangleButton(BuildContext context, _TriangleDirection direction) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isUp = direction == _TriangleDirection.up;
    final baseColor = isUp ? colors.successColor : colors.dangerColor;
    final spaceColor = isDark
        ? baseColor.withOpacity(0.2)
        : Color.lerp(baseColor.withOpacity(0.3), colors.backgroundDepth3, 0.5);
    final shapeColor = baseColor;

    final triangle = CustomPaint(
      size: Size(14, 10),
      painter: _TrianglePainter(direction: direction, color: shapeColor),
    );
    final borderRadius = BorderRadius.circular(4);
    final filling = BoxDecoration(
      border: Border.all(color: colors.borderDepth2),
      borderRadius: borderRadius,
      color: spaceColor,
    );
    return GestureDetector(
      onTap: () => incrementSecondDigit(direction, context),
      child: Material(
        elevation: isDark ? 0 : 1,
        borderRadius: borderRadius,
        color: Colors.transparent,
        child: Container(
          decoration: filling,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          child: triangle,
        ),
      ),
    );
  }

  void incrementSecondDigit(
      _TriangleDirection direction, BuildContext context) {
    final log10 = math.log(slidableValue.now) / math.log(10);
    final increment = math.pow(10, log10.floor() - 1).toDouble();
    final adjustment =
        direction == _TriangleDirection.up ? increment : -increment;
    updateValue(slidableValue.now + adjustment, context);
  }

  bool get tooLow =>
      slidableMinimumValidValue != null &&
      slidableValue <= slidableMinimumValidValue!;
}

enum _TriangleDirection { up, down }

class _TrianglePainter extends CustomPainter {
  final Color color;
  final _TriangleDirection direction;

  _TrianglePainter({required this.color, required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (direction == _TriangleDirection.up) {
      path
        ..moveTo(size.width / 2, 0)
        ..lineTo(0, size.height)
        ..lineTo(size.width, size.height);
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height);
    }
    canvas.drawPath(path..close(), Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
