import 'package:flutter/material.dart';

enum ParamType() {
  int,
  double,
  percent,
  dollars,
  dollarMap,
  list,
}

enum ParamCategory() {
  career,
  children,
  residences,
  lifestyle,
  circumstance,
}

extension ParamCategoryExt on ParamCategory {
  String get displayName => name[0].toUpperCase() + name.substring(1);
}

class const ParamDefinition<T>({
  required final String key,
  required final String displayName,
  required final ParamType type,
  required final ParamCategory category,
  required final T defaultValue,
  final double? minimum,
  final double? maximum,
  final bool isSliderVisible = true,
  final bool endsWithNever = false,
  final String? chartName,
  final Color? chartColor,

  /// If true, values from config are in thousands (e.g., 143.6 means $143,600)
  final bool isKiloDollars = false,
});

/// Field definition for list item fields (Jobs, Residences, Children).
/// Stores displayName and slider constraints. Defaults are in createSubsequent
/// methods since new items inherit from previous items.
class const ListFieldDefinition({
  required final String displayName,
  required final double minimum,
  required final double maximum,
});
