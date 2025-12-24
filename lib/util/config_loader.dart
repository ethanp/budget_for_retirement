import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'config_metadata.dart';

class ConfigLoadException implements Exception {
  ConfigLoadException(this.message);

  final String message;

  @override
  String toString() => 'ConfigLoadException: $message';
}

class ConfigLoader {
  Future<SimulationDefaults> load() async {
    late final String raw;
    try {
      raw = await rootBundle.loadString('config.json');
    } catch (e) {
      throw ConfigLoadException('Missing config.json: $e');
    }

    late final Map<String, dynamic> parsed;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw ConfigLoadException('config.json must contain a JSON object.');
      }
      parsed = decoded;
    } on FormatException catch (error) {
      throw ConfigLoadException(
          'Unable to parse config.json: ${error.message}');
    }

    return SimulationDefaults.fromJson(parsed);
  }
}

class SimulationDefaults {
  SimulationDefaults({
    required this.startingAge,
    required this.jobs,
    required this.children,
    required this.primaryResidences,
    required this.ageAtRetirement,
    required this.ageAtDeath,
    required this.simulationStartingAge,
    required this.monthlyNonFoodBudget,
    required this.monthlyFoodBudget,
    required this.initialGrossRetirementInvestments,
    required this.retirementInvestmentsPerAnnumTarget,
    required this.initialTaxableInvestmentsGross,
    required this.effectiveIncomeTaxRate,
    required this.debtApr,
    required this.realInvestmentReturns,
    required this.inflationRate,
    required this.metadata,
  });

  final int startingAge;
  final List<JobConfig> jobs;
  final List<int> children;
  final List<ResidenceConfig> primaryResidences;
  final int ageAtRetirement;
  final int ageAtDeath;
  final int simulationStartingAge;
  final double monthlyNonFoodBudget;
  final double monthlyFoodBudget;
  final Map<String, double> initialGrossRetirementInvestments;
  final Map<String, double> retirementInvestmentsPerAnnumTarget;
  final Map<String, double> initialTaxableInvestmentsGross;
  final double effectiveIncomeTaxRate;
  final double debtApr;
  final double realInvestmentReturns;
  final double inflationRate;
  final Map<String, ConfigMetadata> metadata;

  factory SimulationDefaults.fromJson(Map<String, dynamic> json) {
    final metadata = <String, ConfigMetadata>{};

    T extractWithMeta<T>(
        String key, T Function(Map<String, dynamic>, String) parser) {
      final meta = _extractMetadata(json, key);
      if (meta.hasData) metadata[key] = meta;
      return parser(json, key);
    }

    return SimulationDefaults(
      startingAge: extractWithMeta('startingAge', _requireIntWithMeta),
      jobs: _requireList<JobConfig>(
        json,
        'jobs',
        (value) => JobConfig.fromJson(_ensureJsonMap(value, 'jobs.item')),
      ),
      children: _requireList<int>(
        json,
        'children',
        (value) => _ensureNum(value, 'children.item').toInt(),
      ),
      primaryResidences: _requireList<ResidenceConfig>(
        json,
        'primaryResidences',
        (value) => ResidenceConfig.fromJson(
            _ensureJsonMap(value, 'primaryResidences.item')),
      ),
      ageAtRetirement: extractWithMeta('ageAtRetirement', _requireIntWithMeta),
      ageAtDeath: extractWithMeta('ageAtDeath', _requireIntWithMeta),
      simulationStartingAge:
          extractWithMeta('simulationStartingAge', _requireIntWithMeta),
      monthlyNonFoodBudget:
          extractWithMeta('monthlyNonFoodBudget', _requireDoubleWithMeta),
      monthlyFoodBudget:
          extractWithMeta('monthlyFoodBudget', _requireDoubleWithMeta),
      initialGrossRetirementInvestments: extractWithMeta(
        'initialGrossRetirementInvestments',
        _requireNumericMapWithMeta,
      ),
      retirementInvestmentsPerAnnumTarget: extractWithMeta(
        'retirementInvestmentsPerAnnumTarget',
        _requireNumericMapWithMeta,
      ),
      initialTaxableInvestmentsGross: extractWithMeta(
        'initialTaxableInvestmentsGross',
        _requireNumericMapWithMeta,
      ),
      effectiveIncomeTaxRate:
          extractWithMeta('effectiveIncomeTaxRate', _requireDoubleWithMeta),
      debtApr: extractWithMeta('debtApr', _requireDoubleWithMeta),
      realInvestmentReturns:
          extractWithMeta('realInvestmentReturns', _requireDoubleWithMeta),
      inflationRate: extractWithMeta('inflationRate', _requireDoubleWithMeta),
      metadata: metadata,
    );
  }
}

class JobConfig {
  JobConfig({required this.age, required this.salary});

  final int age;
  final double salary;

  factory JobConfig.fromJson(Map<String, dynamic> json) {
    return JobConfig(
      age: _requireInt(json, 'age'),
      salary: _requireDouble(json, 'salary'),
    );
  }
}

enum ResidenceType { buy, rent }

class ResidenceConfig {
  ResidenceConfig.buy({
    required this.age,
    required this.price,
    required this.downPaymentPercent,
    required this.mortgageApr,
    required this.housingAppreciateRate,
    required this.propertyTaxRate,
    required this.insurancePrice,
    required this.hoaPrice,
  })  : type = ResidenceType.buy,
        rent = null;

  ResidenceConfig.rent({
    required this.age,
    required this.rent,
  })  : type = ResidenceType.rent,
        price = null,
        downPaymentPercent = null,
        mortgageApr = null,
        housingAppreciateRate = null,
        propertyTaxRate = null,
        insurancePrice = null,
        hoaPrice = null;

  factory ResidenceConfig.fromJson(Map<String, dynamic> json) {
    final typeName = _requireString(json, 'type').toLowerCase();
    final type = ResidenceType.values.firstWhere(
      (value) => value.name == typeName,
      orElse: () =>
          throw ConfigLoadException('Unknown residence type "$typeName".'),
    );
    final age = _requireInt(json, 'age');
    if (type == ResidenceType.buy) {
      return ResidenceConfig.buy(
        age: age,
        price: _requireDouble(json, 'price'),
        downPaymentPercent: _requireDouble(json, 'downPaymentPercent'),
        mortgageApr: _requireDouble(json, 'mortgageApr'),
        housingAppreciateRate: _requireDouble(json, 'housingAppreciateRate'),
        propertyTaxRate: _requireDouble(json, 'propertyTaxRate'),
        insurancePrice: _requireDouble(json, 'insurancePrice'),
        hoaPrice: _requireDouble(json, 'hoaPrice'),
      );
    }
    return ResidenceConfig.rent(
      age: age,
      rent: _requireDouble(json, 'rent'),
    );
  }

  final ResidenceType type;
  final int age;
  final double? price;
  final double? rent;
  final double? downPaymentPercent;
  final double? mortgageApr;
  final double? housingAppreciateRate;
  final double? propertyTaxRate;
  final double? insurancePrice;
  final double? hoaPrice;
}

/// Extracts metadata from a { value, metadata } wrapper object.
ConfigMetadata _extractMetadata(Map<String, dynamic> map, String key) {
  final wrapper = map[key];
  if (wrapper is! Map<String, dynamic>) return const ConfigMetadata();
  final metaJson = wrapper['metadata'];
  if (metaJson is! Map<String, dynamic>) return const ConfigMetadata();
  return ConfigMetadata.fromJson(metaJson);
}

/// Extracts the "value" field from a { value, metadata } wrapper object.
dynamic _unwrapValue(Map<String, dynamic> map, String key) {
  if (!map.containsKey(key)) {
    throw ConfigLoadException('Missing required key: $key');
  }
  final wrapper = map[key];
  if (wrapper is! Map<String, dynamic>) {
    throw ConfigLoadException(
        '$key must be an object with "value" and optional "metadata".');
  }
  if (!wrapper.containsKey('value')) {
    throw ConfigLoadException('$key must contain a "value" field.');
  }
  return wrapper['value'];
}

int _requireIntWithMeta(Map<String, dynamic> map, String key) =>
    _ensureNum(_unwrapValue(map, key), key).toInt();

double _requireDoubleWithMeta(Map<String, dynamic> map, String key) =>
    _ensureNum(_unwrapValue(map, key), key).toDouble();

Map<String, double> _requireNumericMapWithMeta(
  Map<String, dynamic> map,
  String key,
) {
  final value = _unwrapValue(map, key);
  final rawMap = _ensureJsonMap(value, key);
  return rawMap.map((k, v) => MapEntry(k, _ensureNum(v, key).toDouble()));
}

List<T> _requireList<T>(
  Map<String, dynamic> map,
  String key,
  T Function(dynamic value) parser,
) {
  if (!map.containsKey(key)) {
    throw ConfigLoadException('Missing required key: $key');
  }
  final wrapper = map[key];
  if (wrapper is! Map<String, dynamic>) {
    throw ConfigLoadException(
        '$key must be an object with "value" and optional "metadata".');
  }
  if (!wrapper.containsKey('value')) {
    throw ConfigLoadException('$key must contain a "value" field.');
  }
  final list = _ensureList(wrapper['value'], key);
  return list.map(parser).toList(growable: false);
}

List<dynamic> _ensureList(dynamic value, String context) {
  if (value is! List<dynamic>) {
    throw ConfigLoadException('$context must be a list.');
  }
  return value;
}

Map<String, dynamic> _ensureJsonMap(dynamic value, String context) {
  if (value is! Map<String, dynamic>) {
    throw ConfigLoadException('$context must be an object.');
  }
  return value;
}

String _requireString(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value == null) {
    throw ConfigLoadException('Missing required key: $key');
  }
  return value.toString();
}

int _requireInt(Map<String, dynamic> map, String key) =>
    _ensureNum(_requireValue(map, key), key).toInt();

double _requireDouble(Map<String, dynamic> map, String key) =>
    _ensureNum(_requireValue(map, key), key).toDouble();

dynamic _requireValue(Map<String, dynamic> map, String key) {
  if (!map.containsKey(key) || map[key] == null) {
    throw ConfigLoadException('Missing required key: $key');
  }
  return map[key];
}

num _ensureNum(dynamic value, String context) {
  if (value is num) return value;
  throw ConfigLoadException('$context must be a number.');
}
