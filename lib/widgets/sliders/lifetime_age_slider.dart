import 'package:budget_for_retirement/model/simulation_params.dart';
import 'package:budget_for_retirement/util/mutable_simulator_arg.dart';
import 'package:flutter/material.dart';

import 'arg_slider.dart';

class const LifetimeAgeSlider({
  required final SimulationParams simulationParams,
  required final String title,
  required final SlidableSimulatorArg pliantValue,
  final SlidableSimulatorArg? pliantMinimumValidValue,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ArgSlider(
      title: title,
      slidableValue: pliantValue,
      minimum: simulationParams.simulationStartingAge.toDouble(),
      maximum: simulationParams.endAge.toDouble() + 5,
      endsWithNever: true,
      slidableMinimumValidValue: pliantMinimumValidValue,
    );
  }
}
