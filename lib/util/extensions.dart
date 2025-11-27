import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'mutable_simulator_arg.dart';

/// The goal of this package is to provide methods that "satisfying" in the
/// way using Ruby on Rails is "satisfying". In part, it's that feeling that
/// there are people out there with good design sense.

extension IterableT<T> on Iterable<T> {
  List<U> mapL<U>(U Function(T) f) => map(f).toList(growable: false);

  List<T> whereL(bool Function(T) f) => where(f).toList(growable: false);

  bool all(bool Function(T) f) => !any((e) => !f(e));

  T? get maybeLast => isEmpty ? null : last;

  double sumBy(double Function(T) fn) => map(fn).sum;

  double avgBy(double Function(T) fn) => map(fn).sum / length;

  U max<U extends Comparable>(U Function(T) fn) => fn(maxBy(fn));

  U min<U extends Comparable>(U Function(T) fn) => fn(minBy(fn));

  T minBy<U extends Comparable>(U Function(T) fn) => _most(fn, (x) => x < 0);

  T maxBy<U extends Comparable>(U Function(T) fn) => _most(fn, (x) => x > 0);

  T _most<U extends Comparable>(U Function(T) fn, bool Function(int) op) {
    T bestSoFar = first;
    for (T curr in skip(1)) {
      if (op(fn(curr).compareTo(fn(bestSoFar)))) {
        bestSoFar = curr;
      }
    }
    return bestSoFar;
  }

  Iterable<U> mapWithIdx<U>(U Function(T, int) fn) sync* {
    int i = 0;
    for (final item in this) yield fn(item, i++);
  }

  Iterable<int> get indices sync* {
    int i = 0;
    for (final _ in this) yield i++;
  }

  List<T> separatedBy(T separator) =>
      expand((e) => [e, separator]).toList()..removeLast();
}

extension Flattenable<T> on Iterable<Iterable<T>> {
  Iterable<T> get flatten => expand((e) => e);
}

extension ListT<T> on List<T> {
  List<T> sortOn<U extends Comparable>(U Function(T) fn) =>
      this..sort((a, b) => fn(a).compareTo(fn(b)));

  List<T> keepLast({required int atMost}) =>
      sublist(math.max(length - atMost, 0));

  Map<U, List<T>> groupBy<U>(U Function(T) f) {
    final ret = <U, List<T>>{};
    for (final elem in this) {
      final key = f(elem);
      ret.putIfAbsent(key, () => []);
      ret[key]!.add(elem);
    }
    return Map.unmodifiable(ret);
  }
}

extension CompactCurrency on double {
  String asCompactDollars() {
    return NumberFormat.compactCurrency(
      locale: 'en_US',
      symbol: '\$',
    ).format(this);
  }
}

extension Summation on Iterable<double> {
  double get sum => isEmpty ? 0 : reduce((a, b) => a + b);
}

/// Eg. 1 => '1st', 2 => '2nd', 3 => '3rd', 4 => '4th', etc.
String ith({required int place}) {
  String suffix;
  if (place == 1 || place > 20 && place % 10 == 1)
    suffix = 'st';
  else if (place == 2 || place > 20 && place % 10 == 2)
    suffix = 'nd';
  else if (place == 3 || place > 20 && place % 10 == 3)
    suffix = 'rd';
  else
    suffix = 'th';
  return '$place$suffix';
}

extension WithIdx<T> on Iterable<T> {
  Iterable<R> withIdx<R>(R Function(int, T) f) sync* {
    var idx = 0;
    for (final elem in this) yield f(idx++, elem);
  }
}

extension ToPI on num {
  Percent get percent => Percent(toDouble());
  Dollars get kiloDollars => Dollars(toDouble() * 1000);
}

extension EColor on Color? {
  Color lerpWith(Color? other, double propB) => Color.lerp(this, other, propB)!;
}
