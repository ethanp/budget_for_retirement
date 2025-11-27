import 'package:budget_for_retirement/model/financial_simulation.dart';
import 'package:budget_for_retirement/model/user_specified_parameters.dart';
import 'package:budget_for_retirement/util/extensions.dart';
import 'package:budget_for_retirement/util/mutable_simulator_arg.dart';
import 'package:flutter/material.dart';

import 'arg_slider.dart';

class SlidersListView extends StatelessWidget {
  static Widget _headerButtonText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
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
    final UserSpecifiedParameters params = simulation.sliderPositions;
    final List<Widget> jobs = params.jobs.listInOrder
        .mapWithIdx<Widget>((Job job, int idx) => _Jobs(idx, job, simulation))
        .toList();

    return _SliderGroup(
      title: 'Career',
      children: [
        ...jobs,
        Card(
          child: Column(children: [
            _lifetimeSlider(
              params,
              'Age at retirement',
              params.ageAtRetirement,
              pliantMinimumValidValue: params.jobs.listInOrder.last.age,
            ),
            ArgSlider(
              title: 'Effective income tax rate',
              slidableValue: params.effectiveIncomeTaxRate,
              minimum: 0,
              maximum: 50,
              metadata: params.metadataFor('effectiveIncomeTaxRate'),
            ),
            ArgSlider(
              title: 'Start \$: Taxable',
              slidableValue: params.initialTaxableInvestmentsGross,
              minimum: 0,
              maximum: 2e6,
              metadata: params.metadataFor('initialTaxableInvestmentsGross'),
            ),
            ArgSlider(
              title: 'Start \$: Retirement',
              slidableValue: params.initialGrossRetirementInvestments,
              minimum: 0,
              maximum: 1e6,
              metadata: params.metadataFor('initialGrossRetirementInvestments'),
            ),
          ]),
        )
      ],
    );
  }

  static _SliderGroup _childrenGroup(FinancialSimulation simulation) {
    final params = simulation.sliderPositions;
    final removeChildButton = _SliderGroupTitleButton(
      color: Colors.red,
      child: _headerButtonText('–'),
      onTap: () {
        params.children.removeOne();
        simulation.run();
      },
    );
    final addChildButton = _SliderGroupTitleButton(
      color: Colors.green,
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
              minimum: 25,
              maximum: 55,
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

  static _SliderGroup _lifestyleGroup(
      UserSpecifiedParameters simulationParams) {
    return _SliderGroup(title: 'Lifestyle', children: [
      ArgSlider(
        title: 'Non-food / mo',
        slidableValue: simulationParams.monthlyNonFoodBudget,
        minimum: 1e3,
        maximum: 14e3,
        metadata: simulationParams.metadataFor('monthlyNonFoodBudget'),
      ),
      ArgSlider(
        title: 'Food / mo',
        slidableValue: simulationParams.monthlyFoodBudget,
        minimum: 300,
        maximum: 3000,
        metadata: simulationParams.metadataFor('monthlyFoodBudget'),
      ),
      ArgSlider(
        title: 'Retirement savings \$/yr (target)',
        slidableValue: simulationParams.retirementInvestmentsPerAnnumTarget,
        maximum: 33e3,
        metadata:
            simulationParams.metadataFor('retirementInvestmentsPerAnnumTarget'),
      ),
    ]);
  }

  static Widget _circumstanceGroup(
    UserSpecifiedParameters simulationParams,
  ) {
    return _SliderGroup(title: 'Circumstance', children: [
      ArgSlider(
        title: '(real) Investment returns',
        slidableValue: simulationParams.realInvestmentReturns,
        minimum: -5,
        maximum: 13,
        metadata: simulationParams.metadataFor('realInvestmentReturns'),
      ),
      ArgSlider(
        title: 'Inflation rate',
        slidableValue: simulationParams.inflationRate,
        minimum: -5,
        maximum: 13,
        metadata: simulationParams.metadataFor('inflationRate'),
      ),
      ArgSlider(
        title: '(real) Debt rate',
        slidableValue: simulationParams.debtApr,
        minimum: .5,
        maximum: 25,
        metadata: simulationParams.metadataFor('debtApr'),
      ),
    ]);
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
        children: [_header, ...children],
      ),
    );
  }

  Widget get _header {
    return Container(
      color: Colors.grey[300],
      child: Padding(
        padding: const EdgeInsets.only(
          top: 6,
          bottom: 4,
          left: 6,
          right: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_titleText, Row(children: headers)],
        ),
      ),
    );
  }

  Widget get _titleText {
    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: Colors.grey[900]!.withRed(90),
        ),
      ),
    );
  }
}

class _SliderGroupTitleButton extends StatelessWidget {
  const _SliderGroupTitleButton({
    required this.onTap,
    required this.child,
    required this.color,
  });

  final VoidCallback? onTap;
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      child: child,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.lerpWith(Colors.grey, .4),
        minimumSize: const Size(32, 32),
        maximumSize: const Size(32, 32),
        padding: const EdgeInsets.only(left: 6, right: 5, top: 3, bottom: 8),
      ),
    );
  }
}

class _ResidenceContractTypeSwitch extends StatelessWidget {
  const _ResidenceContractTypeSwitch(this.residence);

  final PrimaryResidence residence;

  bool get isSwitchedOn => residence.isRental;

  @override
  Widget build(BuildContext context) {
    final simulation = FinancialSimulation.watchFrom(context);
    final typeSwitch = Switch(
      value: isSwitchedOn,
      activeTrackColor: Colors.orange.withValues(alpha: .8).withBlue(130),
      inactiveTrackColor: Colors.green[800]!.withValues(alpha: .75),
      thumbColor: WidgetStatePropertyAll(Colors.green[700]
          .lerpWith(Colors.blueGrey, .6)
          .lerpWith(Colors.black, .5)),
      onChanged: (isRent) {
        residence.updateType(isRent);
        simulation.run();
      },
    );

    final onStyle = TextStyle(fontWeight: FontWeight.w700);
    final offStyle = TextStyle(fontWeight: FontWeight.w300, color: Colors.grey);

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
    UserSpecifiedParameters simulationParams = simulation.sliderPositions;
    final Widget startDateSlider =
        _lifetimeSlider(simulationParams, 'Age hired', job.age);
    final Widget salarySlider = ArgSlider(
      title: 'Starting salary',
      slidableValue: job.salary,
      minimum: 0,
      maximum: 700e3,
    );
    return Column(
      children: [
        Card(
          margin: EdgeInsets.symmetric(horizontal: 4),
          child: Column(children: [
            _topRow(simulationParams),
            // First job MUST be at the simulation's start time (for simplicity).
            if (idx > 0) startDateSlider,
            salarySlider,
          ]),
        ),
        _addButton(simulationParams),
      ],
    );
  }

  Widget _addButton(UserSpecifiedParameters simulationParams) {
    return _Button.pipedAdd(
      suffix: 'job',
      onPressed: () {
        if (simulationParams.jobs.listInOrder.length < 9) {
          simulationParams.jobs.addOneAfter(idx);
          simulation.run();
        }
      },
    );
  }

  Widget _topRow(UserSpecifiedParameters simulationParams) {
    final number = idx == 0 ? 'Preexisting' : '${ith(place: idx + 1)}';
    final Widget deleteButton = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _Button.delete(onPressed: () {
        simulationParams.jobs.remove(job);
        simulation.run();
      }),
    );
    return Padding(
      padding: const EdgeInsets.all(8).copyWith(bottom: 2),
      // The Row is here to left-align the text
      child: Row(children: [
        Text(
          number + ' job',
          style: TextStyle(
            color: Colors.blueGrey[700],
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),

        // 1st job cannot be deleted (for simplicity).
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
    final UserSpecifiedParameters params = simulation.sliderPositions;
    final PrimaryResidences residences = params.primaryResidences;

    final Widget ithTitle = Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Text(
        idx == 0 ? 'Preexisting' : ith(place: idx + 1),
        style: TextStyle(
          color: Colors.blueGrey[700],
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
          // For simplicity, user cannot delete first residence.
          if (idx > 0)
            _Button.delete(onPressed: () {
              residences.remove(residence);
              simulation.run();
            }),
        ],
      ),
    );
    final Widget ageSlider = ArgSlider(
      title: 'Age',
      slidableValue: residence.age,
      minimum: 20,
      maximum: idx > 0
          ? params.ageAtDeath.toDouble()
          : params.simulationStartingAge.toDouble(),
    );
    final Widget priceSlider = ArgSlider(
      title: residence.isRental ? 'Rent' : 'Price',
      slidableValue: residence.value,
      minimum: residence.contractType.now.minimum,
      maximum: residence.contractType.now.maximum,
    );
    final Widget downPaymentSlider = ArgSlider(
      title: 'Down payment %',
      maximum: 100,
      slidableValue: residence.downPayment,
    );
    final Widget taxRateSlider = ArgSlider(
      title: 'Property tax %',
      minimum: 0.5,
      maximum: 4,
      slidableValue: residence.propertyTaxRate,
    );
    final Widget insuranceSlider = ArgSlider(
      title: 'Insurance \$/yr',
      minimum: 500,
      maximum: 10000,
      slidableValue: residence.insurancePrice,
    );
    final Widget hoaSlider = ArgSlider(
      title: 'HOA \$/yr',
      minimum: 0,
      maximum: 12000,
      slidableValue: residence.hoaPrice,
    );
    final Widget mortgageAprSlider = ArgSlider(
      title: 'Mortgage %APR',
      minimum: 2,
      maximum: 20,
      slidableValue: residence.mortgageApr,
    );
    final Widget appreciationSlider = ArgSlider(
      title: '(real) Housing appreciation',
      slidableValue: residence.housingAppreciateRate,
      minimum: -5,
      maximum: 7,
    );
    final Widget addResidenceButton = _Button.pipedAdd(
      suffix: 'residence',
      onPressed: () {
        if (residences.listInOrder.length < 5) {
          residences.addOneAfter(idx);
          simulation.run();
        }
      },
    );
    final Widget residenceSliders = Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
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

/// Creates an [ArgSlider] restricted to values within the user's lifetime.
Widget _lifetimeSlider(
  UserSpecifiedParameters simulationParams,
  String title,
  SlidableSimulatorArg pliantValue, {
  SlidableSimulatorArg? pliantMinimumValidValue,
}) {
  return ArgSlider(
    title: title,
    slidableValue: pliantValue,
    minimum: simulationParams.simulationStartingAge.toDouble(),
    maximum: simulationParams.ageAtDeath.toDouble() + 5,
    endsWithNever: true,
    slidableMinimumValidValue: pliantMinimumValidValue,
  );
}

class _Button {
  static Widget pipedAdd({
    required String suffix,
    required VoidCallback onPressed,
  }) {
    return _piped(
      _button(
        text: 'Add a $suffix',
        foreground: Colors.green[700],
        background: Colors.grey[100].lerpWith(Colors.lightGreenAccent, .15),
        onPressed: onPressed,
      ),
    );
  }

  static Widget delete({required VoidCallback onPressed}) {
    return _button(
      text: 'Delete',
      foreground: Colors.red[900],
      background: Colors.grey[100].lerpWith(Colors.pink, .10),
      onPressed: onPressed,
    );
  }

  static final Widget _pipeLine = Container(
    height: 10,
    width: 8,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.grey[600]!, // Dark edge
          Colors.grey[500]!, // Mid-tone
          Colors.grey[200]!, // Highlight
          Colors.grey[500]!, // Mid-tone
          Colors.grey[700]!, // Dark edge
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
    ),
  );

  static Widget _piped(Widget w) => Column(children: [_pipeLine, w, _pipeLine]);

  static Widget _button({
    required String text,
    required Color? foreground,
    required Color background,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: foreground,
        backgroundColor: background,
        elevation: .2,
        padding: EdgeInsets.symmetric(horizontal: 12),
      ),
      child: Text(text, style: TextStyle(fontSize: 12)),
      onPressed: onPressed,
    );
  }
}
