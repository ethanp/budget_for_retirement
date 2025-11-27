import 'dart:math' as math;

import 'package:budget_for_retirement/model/life_events.dart';
import 'package:budget_for_retirement/util/mutable_simulator_arg.dart';

import 'house_expenses.dart';

class Residences {
  const Residences({
    required this.properties,
    required this.inflationRate,
    required this.effectiveIncomeTaxRate,
  });

  final List<PrimaryResidence> properties;
  final Percent inflationRate;
  final Percent effectiveIncomeTaxRate;

  double homeEquity(LifeEvents lifeEvents) {
    final PrimaryResidence currentHome = _currentHome(lifeEvents);

    if (currentHome.isRental) return 0;

    return _houseExpenses(
      yearsInHouse: lifeEvents.currentAge - currentHome.age.now,
      purchasePrice: currentHome.price,
      downPayment: currentHome.downPayment,
      primaryResidence: currentHome,
    ).equity;
  }

  PrimaryResidence _currentHome(LifeEvents lifeEvents) => properties
      .lastWhere((element) => element.age.now <= lifeEvents.currentAge);

  double costsThisYear(LifeEvents lifeEvents) {
    final PrimaryResidence currentHome = _currentHome(lifeEvents);

    double oldHouseEquity = 0;
    final bool movingThisYear = lifeEvents.currentAge == currentHome.age.now;
    if (movingThisYear) {
      final int priorHomeIdx = properties.indexOf(currentHome) - 1;
      final PrimaryResidence priorHome = properties[priorHomeIdx];
      if (!priorHome.isRental) {
        oldHouseEquity = _houseExpenses(
          yearsInHouse: lifeEvents.currentAge - priorHome.age.now,
          purchasePrice: priorHome.price,
          downPayment: priorHome.downPayment,
          primaryResidence: priorHome,
        ).equity;
      }
    }

    final annualOutlay = currentHome.isRental
        ? _appreciated(currentHome.monthlyRent * 12, lifeEvents.yearsSinceStart,
            currentHome.housingAppreciateRate)
        : _houseExpenses(
            yearsInHouse: lifeEvents.currentAge - currentHome.age.now,
            purchasePrice: currentHome.price,
            downPayment: currentHome.downPayment,
            primaryResidence: currentHome,
          ).annual;

    final housingExpenses = annualOutlay - oldHouseEquity;
    // Housing costs are negative when house sold more than covers first-year
    // expenses for house bought.
    if (housingExpenses < 0) {
      // We have to pay income taxes (IIRC, since it's not a 529 exchange).
      return -effectiveIncomeTaxRate.takeFrom(-housingExpenses);
    }
    return housingExpenses;
  }

  /// "Real" appreciation.
  double _appreciated(
          double startVal, int numYears, Percent appreciationRate) =>
      startVal * math.pow(1 + appreciationRate.asDouble, numYears);

  HouseExpenses _houseExpenses({
    required int yearsInHouse,
    required double purchasePrice,
    required Percent downPayment,
    required PrimaryResidence primaryResidence,
  }) {
    return HouseExpenses.at(
      yearsInHouse: yearsInHouse,
      purchasePrice: purchasePrice,
      downPayment: downPayment,
      mortgageApr: primaryResidence.mortgageApr,
      housingAppreciationRate: primaryResidence.housingAppreciateRate,
      propertyTaxRate: primaryResidence.propertyTaxRate,
      insurancePrice: primaryResidence.insurancePrice.now,
      hoaPrice: primaryResidence.hoaPrice.now,
      inflationRate: inflationRate,
    );
  }
}
