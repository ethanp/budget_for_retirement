import 'package:budget_for_retirement/model/economy.dart';
import 'package:budget_for_retirement/util/extensions.dart';

import 'life_events.dart';

class NonHouseExpenses {
  NonHouseExpenses({
    required this.monthlyFood,
    required this.monthlyLifestyle,
  });

  /// Eating out + eating in.
  final double monthlyFood;

  /// Includes vacations, healthcare, clothes, etc.
  final double monthlyLifestyle;

  /// Returns the estimated annual non-housing expenses for the current
  /// simulation-year.
  double expensesThisYear(LifeEvents lifeEvents, Economy economy) {
    final monthlyCosts = [
      monthlyFood,
      monthlyLifestyle,
      _ChildCosts.monthly(lifeEvents),
      _HealthInsurancePremium.monthly(lifeEvents),
    ];
    return monthlyCosts.sum * 12;
  }
}

class _ChildCosts {
  static double monthly(LifeEvents lifeEvents) =>
      lifeEvents.currentChildAges.map(_childAnnualCost).sum / 12.0;

  static double _childAnnualCost(int childAge) {
    if (childAge < 0) {
      return 0;
    } else if (childAge <= 5) {
      // Someone on blind estimated they spent 50K/yr in Seattle till public
      // school took over.
      return 40e3;
    } else if (childAge <= 18) {
      // Food, stuff, healthcare (incl insurance), opportunity costs, etc.
      return 30e3;
    } else if (childAge <= 22) {
      // Room & board, food, etc.
      return 20e3;
    } else if (childAge <= 26) {
      // Health insurance, visitation, spoilage, etc.
      return 5e3;
    } else {
      // In case they let me visit them lol.
      return 1e3;
    }
  }
}

class _HealthInsurancePremium {
  /// Source: https://www.google.com/search?q=medicare+age+eligibility
  static const int MedicareMinimumAge = 65;

  /// Source https://www.cms.gov/newsroom/fact-sheets/2022-medicare-parts-b-premiums-and-deductibles2022-medicare-part-d-income-related-monthly-adjustment
  static const double MedicarePremium = 500;

  /// Source: https://www.physicianonfire.com/cost-of-healthcare-in-early-retirement/
  static const double SelfPayMonthlyMedicalPremium = 1800;

  /// As of 10/24.
  static const double EmployerHealthPlanPremium = 80;

  static double monthly(LifeEvents lifeEvents) {
    if (!lifeEvents.isRetired) {
      return EmployerHealthPlanPremium;
    } else if (lifeEvents.currentAge >= MedicareMinimumAge) {
      return MedicarePremium;
    } else {
      return SelfPayMonthlyMedicalPremium;
    }
  }
}
