import 'package:budget_for_retirement/model/financial_simulation.dart';
import 'package:budget_for_retirement/model/param_definition.dart';
import 'package:budget_for_retirement/model/param_registry.dart';
import 'package:budget_for_retirement/model/simulation_params.dart';
import 'package:flutter/material.dart';

import 'arg_slider.dart';
import 'career_slider_group.dart';
import 'children_slider_group.dart';
import 'residences_slider_group.dart';
import 'slider_group.dart';

class SlidersListView() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final simulation = FinancialSimulation.watchFrom(context);
    final sliderGroups = _sliderGroups(simulation);
    return ListView.builder(
      itemCount: sliderGroups.length,
      itemBuilder: (ctx, idx) => sliderGroups[idx],
    );
  }

  static List<Widget> _sliderGroups(FinancialSimulation simulation) => [
    CareerSliderGroup(simulation: simulation),
    ChildrenSliderGroup(simulation: simulation),
    ResidencesSliderGroup(simulation: simulation),
    _lifestyleGroup(simulation.sliderPositions),
    _circumstanceGroup(simulation.sliderPositions),
  ];

  static SliderGroup _lifestyleGroup(SimulationParams params) {
    return SliderGroup(
      title: ParamCategory.lifestyle.displayName,
      children: ParamRegistry.byCategory(ParamCategory.lifestyle)
          .map((def) => ArgSlider.fromDefinition(def, params))
          .toList(),
    );
  }

  static SliderGroup _circumstanceGroup(SimulationParams params) {
    return SliderGroup(
      title: ParamCategory.circumstance.displayName,
      children: ParamRegistry.byCategory(ParamCategory.circumstance)
          .map((def) => ArgSlider.fromDefinition(def, params))
          .toList(),
    );
  }
}
