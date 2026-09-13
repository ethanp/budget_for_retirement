import 'package:budget_for_retirement/model/financial_simulation.dart';
import 'package:budget_for_retirement/model/param_registry.dart';
import 'package:budget_for_retirement/util/extensions.dart' show ith;
import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/material.dart';

import 'arg_slider.dart';
import 'slider_group.dart';

class const ChildrenSliderGroup({required final FinancialSimulation simulation})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final params = simulation.sliderPositions;
    final removeChildButton = SliderGroupTitleButton(
      isAdd: false,
      child: _headerButtonText('–'),
      onTap: () {
        params.children.removeOne();
        simulation.run();
      },
    );
    final addChildButton = SliderGroupTitleButton(
      isAdd: true,
      child: _headerButtonText('+'),
      onTap: () {
        if (params.children.count < 5) {
          params.children.addOne();
          simulation.run();
        }
      },
    );
    final childAgeSliders = params.children.sliders
        .mapWithIndex(
          (v, idx) => ArgSlider(
            title: '${ith(place: idx + 1)} child',
            slidableValue: v,
            minimum: ParamRegistry.childBirthAge.minimum,
            maximum: ParamRegistry.childBirthAge.maximum,
          ),
        )
        .toList();
    return SliderGroup(
      title: 'Children',
      children: childAgeSliders,
      headers: [removeChildButton, SizedBox(width: 8), addChildButton],
    );
  }

  static Widget _headerButtonText(String text) {
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
    );
  }
}
