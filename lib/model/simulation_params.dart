import 'package:budget_for_retirement/util/config_metadata.dart';
import 'package:budget_for_retirement/util/extensions.dart';
import 'package:budget_for_retirement/util/mutable_simulator_arg.dart';

import 'param_definition.dart';
import 'param_registry.dart';

/// Exception thrown when config parsing fails.
class ConfigParseException implements Exception {
  ConfigParseException(this.message);
  final String message;
  @override
  String toString() => 'ConfigParseException: $message';
}

/// Dynamic parameter storage that uses [ParamRegistry] as source of truth.
/// Parses directly from JSON config.
class SimulationParams {
  final Map<String, SlidableSimulatorArg> _scalars = {};
  final Map<String, ConfigMetadata> _metadata;

  Jobs jobs;
  Children children;
  PrimaryResidences primaryResidences;

  SimulationParams._({
    required this.jobs,
    required this.children,
    required this.primaryResidences,
    required Map<String, ConfigMetadata> metadata,
  }) : _metadata = metadata;

  /// Parse directly from JSON config.
  factory SimulationParams.fromJson(Map<String, dynamic> json) {
    final metadata = <String, ConfigMetadata>{};

    // Parse all scalar parameters using registry definitions
    final scalars = <String, SlidableSimulatorArg>{};
    for (final def in ParamRegistry.allScalar) {
      final parsed = _parseScalar(json, def, metadata);
      if (parsed != null) scalars[def.key] = parsed;
    }

    // Parse list parameters
    final jobs = _parseJobs(json);
    final children = _parseChildren(json);
    final residences = _parseResidences(json);

    final params = SimulationParams._(
      jobs: jobs,
      children: children,
      primaryResidences: residences,
      metadata: metadata,
    );
    params._scalars.addAll(scalars);
    return params;
  }

  static SlidableSimulatorArg? _parseScalar(
    Map<String, dynamic> json,
    ParamDefinition def,
    Map<String, ConfigMetadata> metadata,
  ) {
    final wrapper = json[def.key];
    if (wrapper == null) return null;
    if (wrapper is! Map<String, dynamic>) {
      throw ConfigParseException('${def.key} must be an object with "value"');
    }

    // Extract metadata
    final metaJson = wrapper['metadata'];
    if (metaJson is Map<String, dynamic>) {
      final meta = ConfigMetadata.fromJson(metaJson);
      if (meta.hasData) metadata[def.key] = meta;
    }

    // Extract value
    final rawValue = wrapper['value'];
    if (rawValue == null) {
      throw ConfigParseException('${def.key} must have a "value" field');
    }

    switch (def.type) {
      case ParamType.int:
        return Int((rawValue as num).toInt());
      case ParamType.double:
        return Double((rawValue as num).toDouble());
      case ParamType.percent:
        return (rawValue as num).toDouble().percent;
      case ParamType.dollars:
        if (def.isKiloDollars && rawValue is Map) {
          final sum = (rawValue as Map<String, dynamic>)
              .values
              .fold<double>(0, (a, v) => a + (v as num).toDouble());
          return sum.kiloDollars;
        } else if (def.isKiloDollars) {
          return (rawValue as num).toDouble().kiloDollars;
        } else {
          return Dollars((rawValue as num).toDouble());
        }
      case ParamType.dollarMap:
      case ParamType.list:
        return null;
    }
  }

  static Jobs _parseJobs(Map<String, dynamic> json) {
    final list = _extractList(json, 'jobs');
    return Jobs(list.map((item) {
      final m = item as Map<String, dynamic>;
      return Job.create(
        age: (m['age'] as num).toInt(),
        salary: Dollars((m['salary'] as num).toDouble()),
      );
    }).toList());
  }

  static Children _parseChildren(Map<String, dynamic> json) {
    final list = _extractList(json, 'children');
    return Children(list.map((v) => Int((v as num).toInt())).toList());
  }

  static PrimaryResidences _parseResidences(Map<String, dynamic> json) {
    final list = _extractList(json, 'primaryResidences');
    return PrimaryResidences(list.map((item) {
      final m = item as Map<String, dynamic>;
      final typeName = (m['type'] as String).toLowerCase();
      final age = (m['age'] as num).toInt();

      if (typeName == 'buy') {
        return PrimaryResidence.buy(
          age: age,
          price: Dollars((m['price'] as num).toDouble()),
          downPayment: (m['downPaymentPercent'] as num).toDouble().percent,
          mortgageApr: (m['mortgageApr'] as num).toDouble().percent,
          housingAppreciateRate:
              (m['housingAppreciateRate'] as num).toDouble().percent,
          propertyTaxRate: (m['propertyTaxRate'] as num).toDouble().percent,
          insurancePrice: Dollars((m['insurancePrice'] as num).toDouble()),
          hoaPrice: Dollars((m['hoaPrice'] as num).toDouble()),
        );
      }
      return PrimaryResidence.rent(
        age: age,
        rent: Dollars((m['rent'] as num).toDouble()),
      );
    }).toList());
  }

  static List<dynamic> _extractList(Map<String, dynamic> json, String key) {
    final wrapper = json[key];
    if (wrapper is! Map<String, dynamic>) {
      throw ConfigParseException('$key must be an object with "value"');
    }
    final list = wrapper['value'];
    if (list is! List) {
      throw ConfigParseException('$key.value must be a list');
    }
    return list;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GENERIC ACCESSORS
  // ═══════════════════════════════════════════════════════════════════════════

  SlidableSimulatorArg getSlider(ParamDefinition def) => _scalars[def.key]!;
  SlidableSimulatorArg? getSliderByKey(String key) => _scalars[key];
  ConfigMetadata? metadataFor(String key) => _metadata[key];

  // ═══════════════════════════════════════════════════════════════════════════
  // TYPED ACCESSORS (for simulation logic compatibility)
  // ═══════════════════════════════════════════════════════════════════════════

  Int get ageAtRetirement => _scalars['ageAtRetirement']! as Int;
  Int get endAge => _scalars['endAge']! as Int;
  Int get simulationStartingAge => _scalars['simulationStartingAge']! as Int;

  Percent get effectiveIncomeTaxRate =>
      _scalars['effectiveIncomeTaxRate']! as Percent;
  Percent get realInvestmentReturns =>
      _scalars['realInvestmentReturns']! as Percent;
  Percent get inflationRate => _scalars['inflationRate']! as Percent;
  Percent get debtApr => _scalars['debtApr']! as Percent;

  Dollars get monthlyNonFoodBudget =>
      _scalars['monthlyNonFoodBudget']! as Dollars;
  Dollars get monthlyFoodBudget => _scalars['monthlyFoodBudget']! as Dollars;
  Dollars get initialTaxableInvestmentsGross =>
      _scalars['initialTaxableInvestmentsGross']! as Dollars;
  Dollars get initialTraditionalRetirement =>
      _scalars['initialTraditionalRetirement']! as Dollars;
  Dollars get initialRothRetirement =>
      _scalars['initialRothRetirement']! as Dollars;
  Dollars get traditionalContributionTarget =>
      _scalars['traditionalContributionTarget']! as Dollars;
  Dollars get rothContributionTarget =>
      _scalars['rothContributionTarget']! as Dollars;
}
