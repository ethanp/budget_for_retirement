import 'package:budget_for_retirement/model/financial_simulation.dart';
import 'package:budget_for_retirement/model/param_registry.dart';
import 'package:budget_for_retirement/model/simulation_params.dart';
import 'package:budget_for_retirement/util/mutable_simulator_arg.dart';
import 'package:budget_for_retirement/theme/app_colors.dart';
import 'package:budget_for_retirement/util/extensions.dart' show ith;
import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/material.dart';

import 'arg_slider.dart';
import 'lifetime_age_slider.dart';
import 'slider_group.dart';
import 'slider_list_buttons.dart';

class const CareerSliderGroup({required final FinancialSimulation simulation})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SimulationParams params = simulation.sliderPositions;
    final List<Widget> jobs = params.jobs.listInOrder
        .mapWithIndex<Widget>(
          (Job job, int idx) => JobSliderCard(idx, job, simulation),
        )
        .toList();

    return SliderGroup(
      title: 'Career',
      children: [
        ...jobs,
        SliderCard(
          child: Column(
            children: [
              LifetimeAgeSlider(
                simulationParams: params,
                title: ParamRegistry.ageAtRetirement.displayName,
                pliantValue: params.ageAtRetirement,
                pliantMinimumValidValue: params.jobs.listInOrder.last.age,
              ),
              ArgSlider.fromDefinition(
                ParamRegistry.effectiveIncomeTaxRate,
                params,
              ),
              ArgSlider.fromDefinition(
                ParamRegistry.initialTaxableInvestmentsGross,
                params,
              ),
              ArgSlider.fromDefinition(
                ParamRegistry.initialTraditionalRetirement,
                params,
              ),
              ArgSlider.fromDefinition(
                ParamRegistry.initialRothRetirement,
                params,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class const JobSliderCard(
  final int idx,
  final Job job,
  final FinancialSimulation simulation,
) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SimulationParams simulationParams = simulation.sliderPositions;
    final Widget startDateSlider = LifetimeAgeSlider(
      simulationParams: simulationParams,
      title: ParamRegistry.jobAge.displayName,
      pliantValue: job.age,
    );
    final salarySlider = ArgSlider.fromListField(
      ParamRegistry.jobSalary,
      job.salary,
    );
    return Column(
      children: [
        SliderCard(
          child: Column(
            children: [
              _topRow(context, simulationParams),
              if (idx > 0) startDateSlider,
              salarySlider,
            ],
          ),
        ),
        _addButton(context, simulationParams),
      ],
    );
  }

  Widget _addButton(BuildContext context, SimulationParams simulationParams) {
    return SliderListButton.addWithConnectors(
      context: context,
      suffix: 'job',
      onPressed: () {
        if (simulationParams.jobs.listInOrder.length < 9) {
          simulationParams.jobs.addOneAfter(idx);
          simulation.run();
        }
      },
    );
  }

  Widget _topRow(BuildContext context, SimulationParams simulationParams) {
    final colors = AppColors.of(context);
    final number = idx == 0 ? 'Preexisting' : '${ith(place: idx + 1)}';
    final Widget deleteButton = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SliderListButton.delete(
        context: context,
        onPressed: () {
          simulationParams.jobs.remove(job);
          simulation.run();
        },
      ),
    );
    return Padding(
      padding: const EdgeInsets.all(8).copyWith(bottom: 2),
      child: Row(
        children: [
          Text(
            '$number job',
            style: TextStyle(
              color: colors.accentSecondary,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          if (idx > 0) deleteButton,
        ],
      ),
    );
  }
}
