import 'dart:convert';

import 'package:budget_for_retirement/model/simulation_params.dart';
import 'package:flutter/services.dart' show rootBundle;

class ConfigLoadException implements Exception {
  ConfigLoadException(this.message);

  final String message;

  @override
  String toString() => 'ConfigLoadException: $message';
}

class ConfigLoader {
  /// Loads and parses config.json, returning the raw JSON for reset functionality.
  Future<Map<String, dynamic>> load() async {
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

    // Validate by parsing (throws if invalid)
    try {
      SimulationParams.fromJson(parsed);
    } on ConfigParseException catch (e) {
      throw ConfigLoadException(e.message);
    }

    return parsed;
  }
}
