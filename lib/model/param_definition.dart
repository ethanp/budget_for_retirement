import 'package:flutter/material.dart';

enum ParamType { int, double, percent, dollars, dollarMap, list }

enum ParamCategory { career, children, residences, lifestyle, circumstance }

extension ParamCategoryExt on ParamCategory {
  String get displayName => name[0].toUpperCase() + name.substring(1);
}

class ParamDefinition<T> {
  final String key;
  final String displayName;
  final ParamType type;
  final ParamCategory category;
  final T defaultValue;
  final double? minimum;
  final double? maximum;
  final bool isSliderVisible;
  final bool endsWithNever;
  final String? chartName;
  final Color? chartColor;

  /// If true, values from config are in thousands (e.g., 143.6 means $143,600)
  final bool isKiloDollars;

  const ParamDefinition({
    required this.key,
    required this.displayName,
    required this.type,
    required this.category,
    required this.defaultValue,
    this.minimum,
    this.maximum,
    this.isSliderVisible = true,
    this.endsWithNever = false,
    this.chartName,
    this.chartColor,
    this.isKiloDollars = false,
  });
}

/// Field definition for list item fields (Jobs, Residences, Children).
/// Stores displayName and slider constraints. Defaults are in createSubsequent
/// methods since new items inherit from previous items.
class ListFieldDefinition {
  final String displayName;
  final double minimum;
  final double maximum;

  const ListFieldDefinition({
    required this.displayName,
    required this.minimum,
    required this.maximum,
  });
}
