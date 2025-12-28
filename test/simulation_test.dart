import 'dart:convert';
import 'dart:io';

import 'package:budget_for_retirement/model/retirement_accounts.dart';
import 'package:budget_for_retirement/model/simulation_params.dart';
import 'package:budget_for_retirement/model/simulation_state_machine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Map<String, dynamic> configJson;

  setUpAll(() async {
    final raw = await File('config.json').readAsString();
    configJson = jsonDecode(raw) as Map<String, dynamic>;
  });

  group('LifeEvents', () {
    test('Career should be finite', () {
      final simulation = SimulationStateMachine.createFrom(
        SimulationParams.fromJson(configJson),
      );
      while (!simulation.lifeEvents.isRetired) simulation.advanceOneYear();
      expect(simulation.lifeEvents.isRetired, true);
    });
    test('Simulation should be finite', () {
      final simulation = SimulationStateMachine.createFrom(
        SimulationParams.fromJson(configJson),
      );
      while (!simulation.lifeEvents.pastEndAge) simulation.advanceOneYear();
      expect(simulation.lifeEvents.pastEndAge, true);
    });
  });

  group('Default path', () {
    test('Default path should be very financially safe', () {
      final simulation = SimulationStateMachine.createFrom(
        SimulationParams.fromJson(configJson),
      );
      while (!simulation.lifeEvents.pastEndAge) simulation.advanceOneYear();
      expect(simulation.totalRetirementSavings, greaterThan(1e6));
      expect(simulation.taxableInvestments.grossValue, greaterThan(1e6));
    });
  });

  group('Retirement Account Tax Treatment', () {
    test('Traditional withdrawals are taxed as income', () {
      final account = TraditionalRetirement(
        perAnnumTarget: 10000,
        initialGross: 100000,
      );
      // 22% income tax on full withdrawal
      final taxOnWithdrawal = account.taxesOnWithdrawal(10000, false);
      expect(taxOnWithdrawal, closeTo(2200, 1));
    });

    test('Traditional early withdrawals have 10% penalty', () {
      final account = TraditionalRetirement(
        perAnnumTarget: 10000,
        initialGross: 100000,
      );
      // 22% income tax + 10% penalty
      final taxOnWithdrawal = account.taxesOnWithdrawal(10000, true);
      expect(taxOnWithdrawal, closeTo(3200, 1));
    });

    test('Roth qualified withdrawals are tax-free', () {
      final account = RothRetirement(
        perAnnumTarget: 7000,
        initialGross: 100000,
      );
      final taxOnWithdrawal = account.taxesOnWithdrawal(10000, false);
      expect(taxOnWithdrawal, equals(0));
    });

    test('Roth early withdrawals tax earnings only', () {
      final account = RothRetirement(
        perAnnumTarget: 7000,
        initialGross: 100000,
      );
      // Only 50% is earnings, taxed at 22% + 10% penalty
      // 5000 * 0.22 + 5000 * 0.10 = 1100 + 500 = 1600
      final taxOnWithdrawal = account.taxesOnWithdrawal(10000, true);
      expect(taxOnWithdrawal, closeTo(1600, 1));
    });
  });
}
