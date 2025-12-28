import 'package:flutter/material.dart';

import 'param_definition.dart';

/// Single source of truth for all simulation parameters.
class ParamRegistry {
  ParamRegistry._();

  // ═══════════════════════════════════════════════════════════════════════════
  // JOB FIELD DEFINITIONS
  // ═══════════════════════════════════════════════════════════════════════════

  static const jobAge = ListFieldDefinition(
    displayName: 'Age hired',
    minimum: 16,
    maximum: 80,
  );
  static const jobSalary = ListFieldDefinition(
    displayName: 'Starting salary',
    minimum: 0,
    maximum: 700e3,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // CHILD FIELD DEFINITIONS
  // ═══════════════════════════════════════════════════════════════════════════

  static const childBirthAge = ListFieldDefinition(
    displayName: 'Birth age',
    minimum: 25,
    maximum: 55,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // RESIDENCE FIELD DEFINITIONS
  // ═══════════════════════════════════════════════════════════════════════════

  static const residenceAge = ListFieldDefinition(
    displayName: 'Age',
    minimum: 20,
    maximum: 95,
  );
  static const residenceDownPayment = ListFieldDefinition(
    displayName: 'Down payment %',
    minimum: 0,
    maximum: 100,
  );
  static const residencePropertyTax = ListFieldDefinition(
    displayName: 'Property tax %',
    minimum: 0.5,
    maximum: 4,
  );
  static const residenceInsurance = ListFieldDefinition(
    displayName: 'Insurance \$/yr',
    minimum: 500,
    maximum: 10000,
  );
  static const residenceHoa = ListFieldDefinition(
    displayName: 'HOA \$/yr',
    minimum: 0,
    maximum: 12000,
  );
  static const residenceMortgageApr = ListFieldDefinition(
    displayName: 'Mortgage %APR',
    minimum: 2,
    maximum: 20,
  );
  static const residenceAppreciation = ListFieldDefinition(
    displayName: '(real) Housing appreciation',
    minimum: -5,
    maximum: 7,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // CAREER PARAMETERS
  // ═══════════════════════════════════════════════════════════════════════════

  static const ageAtRetirement = ParamDefinition<int>(
    key: 'ageAtRetirement',
    displayName: 'Age at retirement',
    type: ParamType.int,
    category: ParamCategory.career,
    defaultValue: 55,
    minimum: 30,
    maximum: 100,
    endsWithNever: true,
  );

  static const effectiveIncomeTaxRate = ParamDefinition<double>(
    key: 'effectiveIncomeTaxRate',
    displayName: 'Effective income tax rate',
    type: ParamType.percent,
    category: ParamCategory.career,
    defaultValue: 22,
    minimum: 0,
    maximum: 50,
  );

  static final initialTaxableInvestmentsGross = ParamDefinition<double>(
    key: 'initialTaxableInvestmentsGross',
    displayName: 'Start \$: Taxable',
    type: ParamType.dollars,
    category: ParamCategory.career,
    defaultValue: 0,
    minimum: 0,
    maximum: 2e6,
    isKiloDollars: true,
    chartName: 'Taxable Investments',
    chartColor: Color(0xFF4CAF50).withOpacity(0.3), // Colors.green
  );

  static final initialTraditionalRetirement = ParamDefinition<double>(
    key: 'initialTraditionalRetirement',
    displayName: 'Start \$: Traditional',
    type: ParamType.dollars,
    category: ParamCategory.career,
    defaultValue: 0,
    minimum: 0,
    maximum: 1e6,
    isKiloDollars: true,
    chartName: 'Traditional (401k/IRA)',
    chartColor: Color(0xFF2196F3).withOpacity(0.3), // Colors.blue
  );

  static final initialRothRetirement = ParamDefinition<double>(
    key: 'initialRothRetirement',
    displayName: 'Start \$: Roth',
    type: ParamType.dollars,
    category: ParamCategory.career,
    defaultValue: 0,
    minimum: 0,
    maximum: 1e6,
    isKiloDollars: true,
    chartName: 'Roth (IRA/HSA)',
    chartColor: Color(0xFF3F51B5).withOpacity(0.3), // Colors.indigo
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // LIFESTYLE PARAMETERS
  // ═══════════════════════════════════════════════════════════════════════════

  static const monthlyNonFoodBudget = ParamDefinition<double>(
    key: 'monthlyNonFoodBudget',
    displayName: 'Non-food / mo',
    type: ParamType.dollars,
    category: ParamCategory.lifestyle,
    defaultValue: 3000,
    minimum: 1e3,
    maximum: 14e3,
  );

  static const monthlyFoodBudget = ParamDefinition<double>(
    key: 'monthlyFoodBudget',
    displayName: 'Food / mo',
    type: ParamType.dollars,
    category: ParamCategory.lifestyle,
    defaultValue: 1400,
    minimum: 300,
    maximum: 3000,
  );

  static const traditionalContributionTarget = ParamDefinition<double>(
    key: 'traditionalContributionTarget',
    displayName: 'Traditional 401k \$/yr',
    type: ParamType.dollars,
    category: ParamCategory.lifestyle,
    defaultValue: 10000,
    minimum: 0,
    maximum: 25e3,
    isKiloDollars: true,
  );

  static const rothContributionTarget = ParamDefinition<double>(
    key: 'rothContributionTarget',
    displayName: 'Roth IRA \$/yr',
    type: ParamType.dollars,
    category: ParamCategory.lifestyle,
    defaultValue: 7000,
    minimum: 0,
    maximum: 10e3,
    isKiloDollars: true,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // CIRCUMSTANCE PARAMETERS
  // ═══════════════════════════════════════════════════════════════════════════

  static const realInvestmentReturns = ParamDefinition<double>(
    key: 'realInvestmentReturns',
    displayName: '(real) Investment returns',
    type: ParamType.percent,
    category: ParamCategory.circumstance,
    defaultValue: 5,
    minimum: -5,
    maximum: 13,
  );

  static const inflationRate = ParamDefinition<double>(
    key: 'inflationRate',
    displayName: 'Inflation rate',
    type: ParamType.percent,
    category: ParamCategory.circumstance,
    defaultValue: 3,
    minimum: -5,
    maximum: 13,
  );

  static const debtApr = ParamDefinition<double>(
    key: 'debtApr',
    displayName: '(real) Debt rate',
    type: ParamType.percent,
    category: ParamCategory.circumstance,
    defaultValue: 7,
    minimum: 0.5,
    maximum: 25,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // CHART-ONLY DEFINITIONS (not sliders, just chart metadata)
  // ═══════════════════════════════════════════════════════════════════════════

  static final homeEquity = ParamDefinition<double>(
    key: 'homeEquity',
    displayName: 'Home equity',
    type: ParamType.dollars,
    category: ParamCategory.career,
    defaultValue: 0,
    isSliderVisible: false,
    chartName: 'Home equity',
    chartColor: Color(0xFF69F0AE).withOpacity(0.6), // Colors.greenAccent
  );

  static const netWorth = ParamDefinition<double>(
    key: 'netWorth',
    displayName: 'Net Worth',
    type: ParamType.dollars,
    category: ParamCategory.career,
    defaultValue: 0,
    isSliderVisible: false,
    chartName: 'Net Worth',
    chartColor: Color(0xDD000000), // Colors.black87
  );

  static final earnings = ParamDefinition<double>(
    key: 'earnings',
    displayName: 'Earnings',
    type: ParamType.dollars,
    category: ParamCategory.career,
    defaultValue: 0,
    isSliderVisible: false,
    chartName: 'Earnings',
    chartColor: Color(0xFF9C27B0).withOpacity(0.3), // Colors.purple
  );

  static final nonHousingExpenses = ParamDefinition<double>(
    key: 'nonHousingExpenses',
    displayName: 'Non-housing expenses',
    type: ParamType.dollars,
    category: ParamCategory.lifestyle,
    defaultValue: 0,
    isSliderVisible: false,
    chartName: 'Non-housing expenses',
    chartColor: Color(0xFFFF9800).withOpacity(0.3), // Colors.orange
  );

  static final housingExpenses = ParamDefinition<double>(
    key: 'housingExpenses',
    displayName: 'Housing expenses',
    type: ParamType.dollars,
    category: ParamCategory.lifestyle,
    defaultValue: 0,
    isSliderVisible: false,
    chartName: 'Housing expenses',
    chartColor: Color(0xFFE91E63).withOpacity(0.3), // Colors.pink
  );

  static const debt = ParamDefinition<double>(
    key: 'debt',
    displayName: '"Bad" debt',
    type: ParamType.dollars,
    category: ParamCategory.circumstance,
    defaultValue: 0,
    isSliderVisible: false,
    chartName: '"Bad" debt',
    chartColor: Color(0xFFE91E63), // Colors.pink
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // HIDDEN PARAMETERS (not shown in sliders, used for chart/simulation)
  // ═══════════════════════════════════════════════════════════════════════════

  static const startingAge = ParamDefinition<int>(
    key: 'startingAge',
    displayName: 'Starting age',
    type: ParamType.int,
    category: ParamCategory.career,
    defaultValue: 35,
    isSliderVisible: false,
  );

  static const simulationStartingAge = ParamDefinition<int>(
    key: 'simulationStartingAge',
    displayName: 'Simulation starting age',
    type: ParamType.int,
    category: ParamCategory.career,
    defaultValue: 35,
    isSliderVisible: false,
  );

  static const endAge = ParamDefinition<int>(
    key: 'endAge',
    displayName: 'End age',
    type: ParamType.int,
    category: ParamCategory.career,
    defaultValue: 95,
    isSliderVisible: false,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // ALL SCALAR PARAMETERS
  // ═══════════════════════════════════════════════════════════════════════════

  static List<ParamDefinition> get allScalar => [
        // Career
        ageAtRetirement,
        effectiveIncomeTaxRate,
        initialTaxableInvestmentsGross,
        initialTraditionalRetirement,
        initialRothRetirement,
        // Lifestyle
        monthlyNonFoodBudget,
        monthlyFoodBudget,
        traditionalContributionTarget,
        rothContributionTarget,
        // Circumstance
        realInvestmentReturns,
        inflationRate,
        debtApr,
        // Hidden
        startingAge,
        simulationStartingAge,
        endAge,
      ];

  static List<ParamDefinition> byCategory(ParamCategory cat) =>
      allScalar.where((p) => p.category == cat && p.isSliderVisible).toList();

  static ParamDefinition? forKey(String key) {
    for (final p in allScalar) {
      if (p.key == key) return p;
    }
    return null;
  }
}
