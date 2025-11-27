import 'package:budget_for_retirement/model/house_expenses.dart';
import 'package:budget_for_retirement/util/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Compare with values from https://www.businessinsider.com/personal-finance/how-to-calculate-mortgage-payment.
  group('annualMortgagePayment should match online calculator result', () {
    test('\$100K house over 30 yrs at 7%', () {
      final simulation = HouseExpenses.at(
        yearsInHouse: 0,
        purchasePrice: 100000,
        mortgageApr: 7.percent,
        housingAppreciationRate: 0.percent,
        propertyTaxRate: 0.percent,
        insurancePrice: 0,
        hoaPrice: 0,
        downPayment: 20.percent,
        inflationRate: 3.percent,
      );
      expect(
        simulation.realAnnualMortgagePayment,
        within(distance: 100, from: 532.24 * 12),
      );
    });

    test('\$222K house over 30 yrs at 4%', () {
      final simulation = HouseExpenses.at(
        yearsInHouse: 0,
        purchasePrice: 222000,
        mortgageApr: 4.percent,
        housingAppreciationRate: 0.percent,
        propertyTaxRate: 0.percent,
        insurancePrice: 0,
        hoaPrice: 0,
        downPayment: 20.percent,
        inflationRate: 3.percent,
      );
      expect(
        simulation.realAnnualMortgagePayment,
        within(distance: 100, from: 847.89 * 12),
      );
    });

    test('\$1M house over 30 yrs at 8%', () {
      final simulation = HouseExpenses.at(
        yearsInHouse: 0,
        purchasePrice: 1E6,
        mortgageApr: 8.percent,
        housingAppreciationRate: 0.percent,
        propertyTaxRate: 0.percent,
        insurancePrice: 0,
        hoaPrice: 0,
        downPayment: 20.percent,
        inflationRate: 3.percent,
      );
      expect(
        simulation.realAnnualMortgagePayment,
        within(distance: 1000, from: 5870.12 * 12),
      );
    });
  });
}
