import 'package:budget_for_retirement/util/config_loader.dart';
import 'package:budget_for_retirement/util/config_metadata.dart';
import 'package:budget_for_retirement/util/extensions.dart';
import 'package:budget_for_retirement/util/mutable_simulator_arg.dart';

class UserSpecifiedParameters {
  Jobs jobs;
  Children children;
  PrimaryResidences primaryResidences;
  Int ageAtRetirement;
  Int endAge;
  Int simulationStartingAge;
  Dollars monthlyNonFoodBudget;
  Dollars monthlyFoodBudget;
  Dollars initialTraditionalRetirement;
  Dollars initialRothRetirement;
  Dollars traditionalContributionTarget;
  Dollars rothContributionTarget;
  Dollars initialTaxableInvestmentsGross;
  Percent effectiveIncomeTaxRate;
  Percent debtApr;
  Percent realInvestmentReturns;
  Percent inflationRate;
  final Map<String, ConfigMetadata> _metadata;

  UserSpecifiedParameters._({
    required this.jobs,
    required this.children,
    required this.primaryResidences,
    required this.ageAtRetirement,
    required this.endAge,
    required this.simulationStartingAge,
    required this.monthlyNonFoodBudget,
    required this.monthlyFoodBudget,
    required this.initialTraditionalRetirement,
    required this.initialRothRetirement,
    required this.traditionalContributionTarget,
    required this.rothContributionTarget,
    required this.initialTaxableInvestmentsGross,
    required this.effectiveIncomeTaxRate,
    required this.debtApr,
    required this.realInvestmentReturns,
    required this.inflationRate,
    required Map<String, ConfigMetadata> metadata,
  }) : _metadata = metadata;

  factory UserSpecifiedParameters.fromDefaults(SimulationDefaults defaults) {
    final jobList = defaults.jobs
        .map((job) => Job.create(age: job.age, salary: Dollars(job.salary)))
        .toList(growable: false);
    final childrenList =
        defaults.children.map((age) => Int(age)).toList(growable: false);
    final residencesList = defaults.primaryResidences
        .map(_primaryResidenceFromConfig)
        .toList(growable: false);

    return UserSpecifiedParameters._(
      jobs: Jobs(jobList),
      children: Children(childrenList),
      primaryResidences: PrimaryResidences(residencesList),
      ageAtRetirement: Int(defaults.ageAtRetirement),
      endAge: Int(defaults.endAge),
      simulationStartingAge: Int(defaults.simulationStartingAge),
      monthlyNonFoodBudget: Dollars(defaults.monthlyNonFoodBudget),
      monthlyFoodBudget: Dollars(defaults.monthlyFoodBudget),
      initialTraditionalRetirement:
          thousandDollars(defaults.initialTraditionalRetirement),
      initialRothRetirement: thousandDollars(defaults.initialRothRetirement),
      traditionalContributionTarget:
          thousandDollars(defaults.traditionalContributionTarget),
      rothContributionTarget: thousandDollars(defaults.rothContributionTarget),
      initialTaxableInvestmentsGross:
          thousandDollars(defaults.initialTaxableInvestmentsGross),
      effectiveIncomeTaxRate: defaults.effectiveIncomeTaxRate.percent,
      debtApr: defaults.debtApr.percent,
      realInvestmentReturns: defaults.realInvestmentReturns.percent,
      inflationRate: defaults.inflationRate.percent,
      metadata: defaults.metadata,
    );
  }

  ConfigMetadata? metadataFor(String key) => _metadata[key];

  static Dollars thousandDollars(Map<String, double> map) =>
      map.values.fold<Dollars>(
        0.kiloDollars,
        (acc, e) => acc + e.kiloDollars,
      );
}

PrimaryResidence _primaryResidenceFromConfig(ResidenceConfig config) {
  if (config.type == ResidenceType.buy) {
    return PrimaryResidence.buy(
      age: config.age,
      price: Dollars(config.price!),
      downPayment: config.downPaymentPercent!.percent,
      mortgageApr: config.mortgageApr!.percent,
      housingAppreciateRate: config.housingAppreciateRate!.percent,
      propertyTaxRate: config.propertyTaxRate!.percent,
      insurancePrice: Dollars(config.insurancePrice!),
      hoaPrice: Dollars(config.hoaPrice!),
    );
  }

  return PrimaryResidence.rent(
    age: config.age,
    rent: Dollars(config.rent!),
  );
}
