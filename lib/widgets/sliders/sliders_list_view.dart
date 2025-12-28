import 'package:budget_for_retirement/model/financial_simulation.dart';
import 'package:budget_for_retirement/model/param_definition.dart';
import 'package:budget_for_retirement/model/param_registry.dart';
import 'package:budget_for_retirement/model/simulation_params.dart';
import 'package:budget_for_retirement/theme/app_colors.dart';
import 'package:budget_for_retirement/util/extensions.dart';
import 'package:budget_for_retirement/util/mutable_simulator_arg.dart';
import 'package:flutter/material.dart';

import 'arg_slider.dart';

class SlidersListView extends StatelessWidget {
  static Widget _headerButtonText(String text) {
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
    );
  }

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
        _careerGroup(simulation),
        _childrenGroup(simulation),
        _residencesGroup(simulation),
        _lifestyleGroup(simulation.sliderPositions),
        _circumstanceGroup(simulation.sliderPositions),
      ];

  static _SliderGroup _careerGroup(FinancialSimulation simulation) {
    final SimulationParams params = simulation.sliderPositions;
    final List<Widget> jobs = params.jobs.listInOrder
        .mapWithIdx<Widget>((Job job, int idx) => _Jobs(idx, job, simulation))
        .toList();

    return _SliderGroup(
      title: 'Career',
      children: [
        ...jobs,
        _ThemedCard(
          child: Column(children: [
            // Age at retirement has special handling (minimum valid value)
            _lifetimeSlider(
              params,
              ParamRegistry.ageAtRetirement.displayName,
              params.ageAtRetirement,
              pliantMinimumValidValue: params.jobs.listInOrder.last.age,
            ),
            ArgSlider.fromDefinition(
                ParamRegistry.effectiveIncomeTaxRate, params),
            ArgSlider.fromDefinition(
                ParamRegistry.initialTaxableInvestmentsGross, params),
            ArgSlider.fromDefinition(
                ParamRegistry.initialTraditionalRetirement, params),
            ArgSlider.fromDefinition(
                ParamRegistry.initialRothRetirement, params),
          ]),
        )
      ],
    );
  }

  static _SliderGroup _childrenGroup(FinancialSimulation simulation) {
    final params = simulation.sliderPositions;
    final removeChildButton = _SliderGroupTitleButton(
      isAdd: false,
      child: _headerButtonText('–'),
      onTap: () {
        params.children.removeOne();
        simulation.run();
      },
    );
    final addChildButton = _SliderGroupTitleButton(
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
        .withIdx((idx, v) => ArgSlider(
              title: '${ith(place: idx + 1)} child',
              slidableValue: v,
              minimum: ParamRegistry.childBirthAge.minimum,
              maximum: ParamRegistry.childBirthAge.maximum,
            ))
        .toList();
    return _SliderGroup(
      title: 'Children',
      children: childAgeSliders,
      headers: [
        removeChildButton,
        SizedBox(width: 8),
        addChildButton,
      ],
    );
  }

  static _SliderGroup _residencesGroup(FinancialSimulation simulation) =>
      _SliderGroup(
          title: 'Residences',
          children: simulation.sliderPositions.primaryResidences.listInOrder
              .withIdx<Widget>((int idx, PrimaryResidence residence) =>
                  _ResidenceSlider(residence, idx, simulation))
              .toList());

  static _SliderGroup _lifestyleGroup(SimulationParams params) {
    return _SliderGroup(
      title: ParamCategory.lifestyle.displayName,
      children: ParamRegistry.byCategory(ParamCategory.lifestyle)
          .map((def) => ArgSlider.fromDefinition(def, params))
          .toList(),
    );
  }

  static Widget _circumstanceGroup(SimulationParams params) {
    return _SliderGroup(
      title: ParamCategory.circumstance.displayName,
      children: ParamRegistry.byCategory(ParamCategory.circumstance)
          .map((def) => ArgSlider.fromDefinition(def, params))
          .toList(),
    );
  }
}

class _ThemedCard extends StatelessWidget {
  const _ThemedCard({required this.child});
  final Widget child;

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

class _SliderGroup extends StatelessWidget {
  const _SliderGroup({
    required this.title,
    required this.children,
    this.headers = const [],
  });

  final String title;
  final List<Widget> children;
  final List<Widget> headers;

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
          children: [_titleText(context), Row(children: headers)],
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

class _SliderGroupTitleButton extends StatelessWidget {
  const _SliderGroupTitleButton({
    required this.onTap,
    required this.child,
    required this.isAdd,
  });

  final VoidCallback? onTap;
  final Widget child;
  final bool isAdd;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final buttonColor = isAdd ? colors.successColor : colors.dangerColor;
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor.withOpacity(0.7),
        foregroundColor: colors.textColor1,
        minimumSize: const Size(32, 32),
        maximumSize: const Size(32, 32),
        padding: const EdgeInsets.only(left: 6, right: 5, top: 3, bottom: 8),
      ),
      child: child,
    );
  }
}

class _ResidenceContractTypeSwitch extends StatelessWidget {
  const _ResidenceContractTypeSwitch(this.residence);

  final PrimaryResidence residence;

  bool get isSwitchedOn => residence.isRental;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final simulation = FinancialSimulation.watchFrom(context);
    final typeSwitch = Transform.scale(
      scale: 0.7,
      child: Switch(
        value: isSwitchedOn,
        activeTrackColor: colors.accentSecondary,
        inactiveTrackColor: colors.accentTertiary,
        thumbColor: WidgetStatePropertyAll(colors.accentPrimary),
        onChanged: (isRent) {
          residence.updateType(isRent);
          simulation.run();
        },
      ),
    );

    final onStyle = TextStyle(
        fontWeight: FontWeight.w700, color: colors.textColor1, fontSize: 13);
    final offStyle = TextStyle(
        fontWeight: FontWeight.w300, color: colors.textColor3, fontSize: 13);

    final ownLabel = Text('Own', style: isSwitchedOn ? offStyle : onStyle);
    final rentLabel = Text('Rent', style: isSwitchedOn ? onStyle : offStyle);

    return Row(children: [ownLabel, typeSwitch, rentLabel]);
  }
}

class _Jobs extends StatelessWidget {
  const _Jobs(this.idx, this.job, this.simulation);

  final int idx;
  final Job job;
  final FinancialSimulation simulation;

  @override
  Widget build(BuildContext context) {
    SimulationParams simulationParams = simulation.sliderPositions;
    final Widget startDateSlider = _lifetimeSlider(
      simulationParams,
      ParamRegistry.jobAge.displayName,
      job.age,
    );
    final salarySlider =
        ArgSlider.fromListField(ParamRegistry.jobSalary, job.salary);
    return Column(
      children: [
        _ThemedCard(
          child: Column(children: [
            _topRow(context, simulationParams),
            if (idx > 0) startDateSlider,
            salarySlider,
          ]),
        ),
        _addButton(context, simulationParams),
      ],
    );
  }

  Widget _addButton(BuildContext context, SimulationParams simulationParams) {
    return _Button.pipedAdd(
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
      child: _Button.delete(
        context: context,
        onPressed: () {
          simulationParams.jobs.remove(job);
          simulation.run();
        },
      ),
    );
    return Padding(
      padding: const EdgeInsets.all(8).copyWith(bottom: 2),
      child: Row(children: [
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
      ]),
    );
  }
}

class _ResidenceSlider extends StatelessWidget {
  const _ResidenceSlider(this.residence, this.idx, this.simulation);

  final PrimaryResidence residence;
  final int idx;
  final FinancialSimulation simulation;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final SimulationParams params = simulation.sliderPositions;
    final PrimaryResidences residences = params.primaryResidences;

    final Widget ithTitle = Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Text(
        idx == 0 ? 'Preexisting' : ith(place: idx + 1),
        style: TextStyle(
          color: colors.accentSecondary,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
    final Widget topRow = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            ithTitle,
            _ResidenceContractTypeSwitch(residence),
          ]),
          if (idx > 0)
            _Button.delete(
              context: context,
              onPressed: () {
                residences.remove(residence);
                simulation.run();
              },
            ),
        ],
      ),
    );
    final Widget ageSlider = ArgSlider(
      title: ParamRegistry.residenceAge.displayName,
      slidableValue: residence.age,
      minimum: ParamRegistry.residenceAge.minimum,
      maximum: idx > 0
          ? params.endAge.toDouble()
          : params.simulationStartingAge.toDouble(),
    );
    final Widget priceSlider = ArgSlider(
      title: residence.isRental ? 'Rent' : 'Price',
      slidableValue: residence.value,
      minimum: residence.contractType.now.minimum,
      maximum: residence.contractType.now.maximum,
    );
    final downPaymentSlider = ArgSlider.fromListField(
        ParamRegistry.residenceDownPayment, residence.downPayment);
    final taxRateSlider = ArgSlider.fromListField(
        ParamRegistry.residencePropertyTax, residence.propertyTaxRate);
    final insuranceSlider = ArgSlider.fromListField(
        ParamRegistry.residenceInsurance, residence.insurancePrice);
    final hoaSlider =
        ArgSlider.fromListField(ParamRegistry.residenceHoa, residence.hoaPrice);
    final mortgageAprSlider = ArgSlider.fromListField(
        ParamRegistry.residenceMortgageApr, residence.mortgageApr);
    final appreciationSlider = ArgSlider.fromListField(
        ParamRegistry.residenceAppreciation, residence.housingAppreciateRate);
    final Widget addResidenceButton = _Button.pipedAdd(
      context: context,
      suffix: 'residence',
      onPressed: () {
        if (residences.listInOrder.length < 5) {
          residences.addOneAfter(idx);
          simulation.run();
        }
      },
    );
    final Widget residenceSliders = _ThemedCard(
      child: Column(children: [
        topRow,
        ageSlider,
        priceSlider,
        if (!residence.isRental) ...[
          downPaymentSlider,
          taxRateSlider,
          insuranceSlider,
          hoaSlider,
          mortgageAprSlider,
          appreciationSlider,
        ],
      ]),
    );
    return Column(children: [
      residenceSliders,
      addResidenceButton,
    ]);
  }
}

Widget _lifetimeSlider(
  SimulationParams simulationParams,
  String title,
  SlidableSimulatorArg pliantValue, {
  SlidableSimulatorArg? pliantMinimumValidValue,
}) {
  return ArgSlider(
    title: title,
    slidableValue: pliantValue,
    minimum: simulationParams.simulationStartingAge.toDouble(),
    maximum: simulationParams.endAge.toDouble() + 5,
    endsWithNever: true,
    slidableMinimumValidValue: pliantMinimumValidValue,
  );
}

class _Button {
  static Widget pipedAdd({
    required BuildContext context,
    required String suffix,
    required VoidCallback onPressed,
  }) {
    final colors = AppColors.of(context);
    return _piped(
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

  static Widget _pipeLine(BuildContext context) {
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

  static Widget _piped(BuildContext context, Widget w) =>
      Column(children: [_pipeLine(context), w, _pipeLine(context)]);

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
