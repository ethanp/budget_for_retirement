import 'package:budget_for_retirement/model/financial_simulation.dart';
import 'package:budget_for_retirement/model/param_registry.dart';
import 'package:budget_for_retirement/model/simulation_params.dart';
import 'package:budget_for_retirement/util/mutable_simulator_arg.dart';
import 'package:budget_for_retirement/theme/app_colors.dart';
import 'package:budget_for_retirement/util/extensions.dart' show ith;
import 'package:ethan_utils/ethan_utils.dart';
import 'package:flutter/material.dart';

import 'arg_slider.dart';
import 'slider_group.dart';
import 'slider_list_buttons.dart';

class const ResidencesSliderGroup({
  required final FinancialSimulation simulation,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SliderGroup(
    title: 'Residences',
    children: simulation.sliderPositions.primaryResidences.listInOrder
        .mapWithIndex<Widget>(
          (PrimaryResidence residence, int idx) =>
              ResidenceSliderCard(residence, idx, simulation),
        )
        .toList(),
  );
}

class const ResidenceContractTypeSwitch(final PrimaryResidence residence)
    extends StatelessWidget {
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
      fontWeight: FontWeight.w700,
      color: colors.textColor1,
      fontSize: 13,
    );
    final offStyle = TextStyle(
      fontWeight: FontWeight.w300,
      color: colors.textColor3,
      fontSize: 13,
    );

    final ownLabel = Text('Own', style: isSwitchedOn ? offStyle : onStyle);
    final rentLabel = Text('Rent', style: isSwitchedOn ? onStyle : offStyle);

    return Row(children: [ownLabel, typeSwitch, rentLabel]);
  }
}

class const ResidenceSliderCard(
  final PrimaryResidence residence,
  final int idx,
  final FinancialSimulation simulation,
) extends StatelessWidget {
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
          Row(children: [ithTitle, ResidenceContractTypeSwitch(residence)]),
          if (idx > 0)
            SliderListButton.delete(
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
      ParamRegistry.residenceDownPayment,
      residence.downPayment,
    );
    final taxRateSlider = ArgSlider.fromListField(
      ParamRegistry.residencePropertyTax,
      residence.propertyTaxRate,
    );
    final insuranceSlider = ArgSlider.fromListField(
      ParamRegistry.residenceInsurance,
      residence.insurancePrice,
    );
    final hoaSlider = ArgSlider.fromListField(
      ParamRegistry.residenceHoa,
      residence.hoaPrice,
    );
    final mortgageAprSlider = ArgSlider.fromListField(
      ParamRegistry.residenceMortgageApr,
      residence.mortgageApr,
    );
    final appreciationSlider = ArgSlider.fromListField(
      ParamRegistry.residenceAppreciation,
      residence.housingAppreciateRate,
    );
    final Widget addResidenceButton = SliderListButton.addWithConnectors(
      context: context,
      suffix: 'residence',
      onPressed: () {
        if (residences.listInOrder.length < 5) {
          residences.addOneAfter(idx);
          simulation.run();
        }
      },
    );
    final Widget residenceSliders = SliderCard(
      child: Column(
        children: [
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
        ],
      ),
    );
    return Column(children: [residenceSliders, addResidenceButton]);
  }
}
