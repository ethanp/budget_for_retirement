import 'package:budget_for_retirement/model/simulation_state_machine.dart';
import 'package:budget_for_retirement/model/user_specified_parameters.dart';
import 'package:budget_for_retirement/util/config_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SimulationDefaults defaults;

  setUpAll(() async {
    defaults = await ConfigLoader(configPath: 'config.json').load();
  });

  group('LifeEvents', () {
    test('Career should be finite', () {
      final simulation = SimulationStateMachine.createFrom(
        UserSpecifiedParameters.fromDefaults(defaults),
      );
      while (!simulation.lifeEvents.isRetired) simulation.advanceOneYear();
      expect(simulation.lifeEvents.isRetired, true);
    });
    test('Life should be finite', () {
      final simulation = SimulationStateMachine.createFrom(
        UserSpecifiedParameters.fromDefaults(defaults),
      );
      while (!simulation.lifeEvents.isDead) simulation.advanceOneYear();
      expect(simulation.lifeEvents.isDead, true);
    });
  });

  group('Default path', () {
    test('Default path should be very financially safe', () {
      final simulation = SimulationStateMachine.createFrom(
        UserSpecifiedParameters.fromDefaults(defaults),
      );
      while (!simulation.lifeEvents.isDead) simulation.advanceOneYear();
      expect(simulation.retirementSavings.grossValue, greaterThan(1e6));
      expect(simulation.taxableInvestments.grossValue, greaterThan(1e6));
    });
  });
}
