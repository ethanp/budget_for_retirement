import 'dart:math' as math;

import 'package:budget_for_retirement/model/financial_simulation.dart';
import 'package:budget_for_retirement/util/config_metadata.dart';
import 'package:budget_for_retirement/util/extensions.dart';
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

  /// If true, when slider reaches its rightmost-point, the label text will
  /// read "never" instead of the current value.
  final bool endsWithNever;

  /// If present, represents the minimum value that is currently valid.
  final SlidableSimulatorArg? slidableMinimumValidValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Pad longer titled parameters further away from their neighbors to make
      // it more legible.
      padding: EdgeInsets.symmetric(vertical: math.pow(title.length, 3) / 3000),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          color: Colors.red.withOpacity(tooLow ? .4 : 0),
        ),
        height: 34,
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              titleWithBadge(),
              slider(context, constraints),
              Flexible(child: triangleButtons(context)),
              Flexible(child: textInput(context)),
              tooLow
                  ? tooLowText()
                  // Sized box is used to keep the rightmost part of
                  // the Row away from the scrollview slider.
                  : SizedBox(width: 5)
            ],
          ),
        ),
      ),
    );
  }

  Widget titleWithBadge() {
    final showBadge = metadata != null && metadata!.hasData;
    return Container(
      width: showBadge ? 130 : 110,
      padding: const EdgeInsets.only(right: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 14,
                height: 1.2,
                letterSpacing: -0.6,
                wordSpacing: -1,
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
    return SizedBox(
      width: constraints.maxWidth / 2.4,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          // Thickness of the track
          trackHeight: 7,
          // The little shadow you see on hover of the slider nub
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 9),
          // The slider nub itself
          thumbShape: const RoundSliderThumbShape(
            enabledThumbRadius: 6,
            elevation: 3,
          ),
          inactiveTrackColor: Colors.green.withOpacity(.4),
          thumbColor: Colors.green[700]
              .lerpWith(Colors.blueGrey, .6)
              .lerpWith(Colors.black, .5),
          activeTrackColor: Colors.cyan[800]!.withOpacity(.75),
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
    final sayNever = !tooLow && endsWithNever && slidableValue.now == maximum;
    textEditingController.text = sayNever ? 'never' : '$slidableValue';
    return SizedBox(
      width: 70,
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
          color: Color.lerp(
            Colors.grey[900],
            Colors.grey[800],
            0.7,
          ),
        ),
      ),
    );
  }

  Widget tooLowText() {
    return Text(
      '  Too low',
      style: TextStyle(
        color: Colors.red[900],
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        triangleButton(context, _TriangleDirection.up),
        SizedBox(height: 2),
        triangleButton(context, _TriangleDirection.down),
      ],
    );
  }

  Widget triangleButton(BuildContext context, _TriangleDirection direction) {
    final triangleBaseColor =
        direction == _TriangleDirection.up ? Colors.green : Colors.red;
    var spaceColor = Color.lerp(triangleBaseColor[100], Colors.grey[400], 0.5);
    var shapeColor = Color.lerp(triangleBaseColor[900], Colors.grey[800], 0.5);
    final triangle = CustomPaint(
      size: Size(8, 6),
      painter: _TrianglePainter(
        direction: direction,
        color: shapeColor!,
      ),
    );
    final borderRadius = BorderRadius.circular(3);
    final filling = BoxDecoration(
      border: Border.all(color: Colors.grey[700]!),
      borderRadius: borderRadius,
      color: spaceColor,
    );
    return GestureDetector(
      onTap: () => incrementSecondDigit(direction, context),
      child: Material(
        elevation: 1,
        borderRadius: borderRadius,
        child: Container(
          decoration: filling,
          padding: const EdgeInsets.all(2),
          child: triangle,
        ),
      ),
    );
  }

  void incrementSecondDigit(
    _TriangleDirection direction,
    BuildContext context,
  ) {
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

    // Draw triangle based on the direction
    if (direction == _TriangleDirection.up) {
      path
        ..moveTo(size.width / 2, 0) // Top center
        ..lineTo(0, size.height) // Bottom left
        ..lineTo(size.width, size.height); // Bottom right
    } else {
      path
        ..moveTo(0, 0) // Top left
        ..lineTo(size.width, 0) // Top right
        ..lineTo(size.width / 2, size.height); // Bottom center
    }

    canvas.drawPath(path..close(), Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
