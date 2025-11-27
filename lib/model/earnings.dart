import 'dart:math' as math;

import 'package:budget_for_retirement/model/life_events.dart';
import 'package:budget_for_retirement/util/extensions.dart';

class Earnings {
  static const int MinimumSocSecAge = 62;

  /// Gross [pre-tax] pay.
  ///
  /// * Eg. at Google that would be contractual-salary + bonus + stock grant.
  /// * But for a contractor it would be contract fees or whatever.
  /// * For an eligible retiree, it includes Social Security payments.
  double annualThisYear(LifeEvents lifeEvents) {
    return lifeEvents.isRetired
        ? _retirementIncome(lifeEvents)
        : _salaryIncome(lifeEvents);
  }

  double _salaryIncome(LifeEvents lifeEvents) {
    final currentJob = lifeEvents.currentJob;
    final yearsAtThisJob = lifeEvents.currentAge - currentJob.age.now;
    final startingSalary = currentJob.salary.now;
    final annualIncrease = 3.percent.of(startingSalary);
    final rawProjectedSalary = startingSalary + yearsAtThisJob * annualIncrease;
    final maxJobSalary = 120.percent.of(startingSalary);
    return math.min(rawProjectedSalary, maxJobSalary);
  }

  double _retirementIncome(LifeEvents lifeEvents) {
    // The later you start to pull SocSec, the more they pay. But we use the
    // minimum current payout to be conservative since many believe the govt
    // will reduce the benefits before I get to take part.
    final drawingSocialSecurity = lifeEvents.currentAge >= MinimumSocSecAge;
    if (!drawingSocialSecurity) return 0;
    // Source for the amount used: https://www.ssa.gov/cgi-bin/benefit6.cgi.
    const monthlyPayment = 2561.0;
    return monthlyPayment * DateTime.monthsPerYear;
  }
}
