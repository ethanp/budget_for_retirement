import 'package:budget_for_retirement/util/extensions.dart';
import 'package:budget_for_retirement/util/mutable_simulator_arg.dart';

class HouseExpenses {
  const HouseExpenses.at({
    required this.yearsInHouse,
    required this.downPayment,
    required this.purchasePrice,
    required this.mortgageApr,
    required this.housingAppreciationRate,
    required this.propertyTaxRate,
    required this.insurancePrice,
    required this.hoaPrice,
    required this.inflationRate,
  });

  final int yearsInHouse;
  final Percent downPayment;
  final Percent mortgageApr;
  final Percent housingAppreciationRate;
  final Percent propertyTaxRate;
  final double insurancePrice;
  final double hoaPrice;
  final Percent inflationRate;

  /// Needed to differentiate which house we're talking about.
  final double purchasePrice;

  double get downPaymentAmt => downPayment.of(purchasePrice);

  static final int _mortgageDurationYears = 30;

  double get _mortgageApr => mortgageApr.asDouble;

  /// They estimate it at 3-6% in the article, so I chose 10%, to add in moving
  /// costs and some initial remodeling.
  /// https://www.thebalance.com/more-than-a-mortgage-the-cost-of-owning-a-home-453819
  /// https://smartasset.com/mortgage/closing-costs#gfe-table
  double get _closingCosts => 10.percent.of(purchasePrice);

  double get _fullLoanAmount => downPayment.takeFrom(purchasePrice);

  double get purchasePayment =>
      yearsInHouse == 0 ? downPaymentAmt + _closingCosts : 0;

  double get currentValue =>
      housingAppreciationRate.toScaleFor(yearsInHouse).of(purchasePrice);

  /// See also https://www.nytimes.com/interactive/2014/upshot/buy-rent-calculator.html
  double get annual =>
      purchasePayment +
      realAnnualMortgagePayment +
      maintenance +
      taxes +
      insurance +
      hoa +
      pmi;

  double get monthly => annual / 12;

  double get taxes => propertyTaxRate.of(currentValue);

  /// Insurance scales with current home value, based on initial price ratio.
  double get insurance =>
      Percent.unscaled(insurancePrice / purchasePrice).of(currentValue);

  /// HOA is a fixed annual cost (in real/inflation-adjusted terms).
  double get hoa => hoaPrice;

  /// Based on 1) what I saw online, 2) my experience so far, 3) my gut.
  double get maintenance => 0.7.percent.of(purchasePrice);

  /// This algorithm for calculating the real annual mortgage payment was
  /// validated as correct by ChatGPT-5. Claude 4 says it's incorrect lol.
  /// I think ChatGPT is right.
  double get realAnnualMortgagePayment =>
      _adjustForInflation(nominalAnnualMortgagePayment);

  /// Formula from https://businessinsider.com/personal-finance/how-to-calculate-mortgage-payment
  ///
  /// I don't understand how the math works, but I added unit tests to
  /// `house_expenses_test.dart` that show that it matches an online
  /// calculator reasonably well.
  double get nominalAnnualMortgagePayment {
    if (yearsInHouse >= _mortgageDurationYears) return 0;
    final Percent scaleFactor = mortgageApr.toScaleFor(_mortgageDurationYears);
    return _fullLoanAmount *
        scaleFactor.of(_mortgageApr) /
        scaleFactor.asGrowthFactor;
  }

  double _adjustForInflation(double nominalPayment) {
    return inflationRate
        .toScaleFor(yearsInHouse, inverted: true)
        .of(nominalPayment);
  }

  /// PMI applies while LTV > 80%, then drops off.
  /// Typical PMI ~0.2%–2% of value annually; use 0.5% by default.
  double get pmi => yearsInHouse >= _mortgageDurationYears ||
          _remainingMortgage / currentValue <= 0.8
      ? 0
      : .5.percent.of(currentValue);

  double get equity => currentValue - _remainingMortgage;

  /// Formula from https://www.youtube.com/watch?v=aaM78m_laOo
  ///
  /// Don't totally understand but results look reasonable.
  double get _remainingMortgage {
    if (yearsInHouse >= _mortgageDurationYears) return 0;
    final Percent scaleFactor = mortgageApr.toScaleFor(yearsInHouse);
    final double futureValueOfPrincipal = scaleFactor.of(_fullLoanAmount);
    final double futureValueOfAnnuity = nominalAnnualMortgagePayment *
        (scaleFactor.asDouble - 1) /
        _mortgageApr;
    return futureValueOfPrincipal - futureValueOfAnnuity;
  }
}
