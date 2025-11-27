import 'dart:math' as math;

import 'package:budget_for_retirement/util/extensions.dart';

/// Holds the mutable value for a single [SimulatorArgumentSlider].
abstract class MutableSimulatorArg<T> {
  MutableSimulatorArg(this._now);

  T _now;

  void updateTo(T newValue) => _now = newValue;

  /// For debugging purposes. Use [serialize] for storage purposes.
  @override
  String toString() => _now.toString();

  /// For storage purposes. Use [toString] for debugging purposes.
  String get serialize => _now.toString();
}

class SlidableSimulatorArg<T extends num> extends MutableSimulatorArg<T> {
  SlidableSimulatorArg(super.now);

  T get now => _now;

  void slideTo(double newValue) => updateTo(newValue as T);

  bool operator <=(SlidableSimulatorArg other) => now <= other.now;
}

class Double extends SlidableSimulatorArg<double> {
  Double(super.now);

  factory Double.deserialize(String idx) => Double(double.parse(idx));
}

class Int extends SlidableSimulatorArg<int> {
  Int(super.now);

  factory Int.deserialize(String line) => Int(int.parse(line));

  @override
  void slideTo(double newValue) => _now = newValue.toInt();

  double toDouble() => now.toDouble();
}

class Dollars extends Double {
  Dollars(super.now);

  factory Dollars.deserialize(String idx) => Dollars(double.parse(idx));

  @override
  String toString() => now.asCompactDollars();

  Dollars operator +(Dollars other) {
    return Dollars(now + other.now);
  }
}

class Percent extends Double {
  Percent(super.now);

  factory Percent.deserialize(String idx) => Percent(double.parse(idx));

  factory Percent.unscaled(double amt) => Percent(amt * 100);

  double get asDouble => now / 100;

  Percent operator +(Percent other) => Percent(now + other.now);

  Percent operator -(Percent other) => Percent(now - other.now);

  double of(double amt) => asDouble * amt;

  double takeFrom(double amt) => amt - of(amt);

  Percent toScaleFor(int numPeriods, {bool? inverted}) {
    final bool shouldInvert = inverted ?? false;
    final double growthFactor = shouldInvert ? 1 - asDouble : 1 + asDouble;
    final double scaledAmount = math.pow(growthFactor, numPeriods).toDouble();
    return Percent.unscaled(scaledAmount);
  }

  double get asGrowthFactor => asDouble - 1;

  @override
  String toString() => '${now.toStringAsFixed(2)}%';
}

class Children extends MutableSimulatorArg<List<Int>> {
  Children(super.now);

  List<int> get currentAges => _now.mapL((i) => i.now);

  int get count => _now.length;

  /// This list is immutable.
  List<Int> get sliders => _now.toList(growable: false);

  void addOne() =>
      _now.isEmpty ? _now.add(Int(34)) : _now.add(Int(_now.last.now + 3));

  void removeOne() {
    if (_now.isNotEmpty) _now.removeLast();
  }

  @override
  String get serialize => _now.map((age) => age.serialize).join(',');

  factory Children.deserialize(String line) =>
      Children(line.split(',').mapL((age) => Int.deserialize(age)));
}

abstract class Subsequentable<T> {
  T get createSubsequent;
}

abstract class SubsequentableArg<T extends Subsequentable>
    extends MutableSimulatorArg<List<T>> {
  SubsequentableArg(super.now);

  void addOneAfter(int idx) => _now.insert(idx + 1, _now[idx].createSubsequent);

  void remove(T residence) => _now.remove(residence);

  List<T> get listInOrder;
}

class PrimaryResidences extends SubsequentableArg<PrimaryResidence> {
  PrimaryResidences(super.now);

  /// Internally, the ordering reflects the user's input, but callers still
  /// always receive the [listInOrder] in order of increasing starting
  /// [PrimaryResidence.age].
  @override
  List<PrimaryResidence> get listInOrder => _now.sortOn((c) => c.age.now);
}

class Jobs extends SubsequentableArg<Job> {
  Jobs(super.now);

  @override
  List<Job> get listInOrder => _now.sortOn((c) => c.age.now);
}

class PliantContractType extends MutableSimulatorArg<ResidenceContractType> {
  PliantContractType(super.now);

  ResidenceContractType get now => _now;

  factory PliantContractType.rent() =>
      PliantContractType(ResidenceContractType.RentalContract);

  factory PliantContractType.buy() =>
      PliantContractType(ResidenceContractType.HomeOwnership);
}

enum ResidenceContractType {
  HomeOwnership(name: 'House', minimum: 2e5, maximum: 2e6, defaultValue: 4e5),
  RentalContract(name: 'Rent', minimum: 500, maximum: 7000, defaultValue: 3000);

  const ResidenceContractType({
    required this.name,
    required this.minimum,
    required this.maximum,
    required this.defaultValue,
  });

  final String name;
  final double minimum;
  final double maximum;
  final double defaultValue;

  bool get isRental => this == ResidenceContractType.RentalContract;

  String get serialize => name;

  factory ResidenceContractType.deserialize(String s) =>
      ResidenceContractType.values.firstWhere((element) => element.name == s);
}

class PrimaryResidence implements Subsequentable {
  const PrimaryResidence({
    required this.age,
    required this.value,
    required this.contractType,
    required this.downPayment,
    required this.mortgageApr,
    required this.housingAppreciateRate,
    required this.propertyTaxRate,
    required this.insurancePrice,
    required this.hoaPrice,
  });

  final Int age;
  final Dollars value;
  final Percent downPayment;
  final PliantContractType contractType;
  final Percent mortgageApr;
  final Percent housingAppreciateRate;
  final Percent propertyTaxRate;
  final Dollars insurancePrice;
  final Dollars hoaPrice;

  factory PrimaryResidence.buy({
    required int age,
    required Dollars price,
    required Percent downPayment,
    required Percent mortgageApr,
    required Percent housingAppreciateRate,
    required Percent propertyTaxRate,
    required Dollars insurancePrice,
    required Dollars hoaPrice,
  }) =>
      PrimaryResidence(
        age: Int(age),
        value: price,
        contractType: PliantContractType.buy(),
        downPayment: downPayment,
        mortgageApr: mortgageApr,
        housingAppreciateRate: housingAppreciateRate,
        propertyTaxRate: propertyTaxRate,
        insurancePrice: insurancePrice,
        hoaPrice: hoaPrice,
      );

  factory PrimaryResidence.rent({
    required int age,
    required Dollars rent,
  }) =>
      PrimaryResidence(
        age: Int(age),
        value: rent,
        contractType: PliantContractType.rent(),
        downPayment: 0.percent,
        mortgageApr: 0.percent,
        housingAppreciateRate: 0.percent,
        propertyTaxRate: 0.percent,
        insurancePrice: Dollars(0),
        hoaPrice: Dollars(0),
      );

  PrimaryResidence get createSubsequent => PrimaryResidence.buy(
        age: age.now + 5,
        price: isRental ? 400.kiloDollars : value + 300.kiloDollars,
        downPayment: 20.percent,
        mortgageApr: mortgageApr,
        housingAppreciateRate: housingAppreciateRate,
        propertyTaxRate: propertyTaxRate,
        insurancePrice: insurancePrice,
        hoaPrice: hoaPrice,
      );

  bool get isRental => contractType.now.isRental;

  double get price {
    assert(!isRental);
    return value.now;
  }

  double get monthlyRent {
    assert(isRental);
    return value.now;
  }

  void updateType(bool toRent) {
    if (isRental == toRent) return;

    final newType = toRent
        ? ResidenceContractType.RentalContract
        : ResidenceContractType.HomeOwnership;
    contractType.updateTo(newType);
    value.updateTo(newType.minimum);
  }

  @override
  String toString() => '${contractType.now.name} $value';
}

class Job implements Subsequentable {
  const Job({required this.age, required this.salary});

  factory Job.create({required int age, required Dollars salary}) =>
      Job(age: Int(age), salary: salary);

  final Int age;

  final Dollars salary;

  Job get createSubsequent =>
      Job.create(age: age.now + 4, salary: salary + 30.kiloDollars);
}
