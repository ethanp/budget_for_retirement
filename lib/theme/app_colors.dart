import 'package:flutter/material.dart';

class AppColors {
  const AppColors._({
    required this.backgroundDepth1,
    required this.backgroundDepth2,
    required this.backgroundDepth3,
    required this.backgroundDepth4,
    required this.backgroundDepth5,
    required this.surfaceAccent,
    required this.accentPrimary,
    required this.accentSecondary,
    required this.accentTertiary,
    required this.textColor1,
    required this.textColor2,
    required this.textColor3,
    required this.textColor4,
    required this.borderDepth1,
    required this.borderDepth2,
    required this.successColor,
    required this.dangerColor,
  });

  final Color backgroundDepth1;
  final Color backgroundDepth2;
  final Color backgroundDepth3;
  final Color backgroundDepth4;
  final Color backgroundDepth5;
  final Color surfaceAccent;
  final Color accentPrimary;
  final Color accentSecondary;
  final Color accentTertiary;
  final Color textColor1;
  final Color textColor2;
  final Color textColor3;
  final Color textColor4;
  final Color borderDepth1;
  final Color borderDepth2;
  final Color successColor;
  final Color dangerColor;

  static const light = AppColors._(
    backgroundDepth1: Color(0xFFFAFAFA),
    backgroundDepth2: Color(0xFFFFFFFF),
    backgroundDepth3: Color(0xFFF5F5F5),
    backgroundDepth4: Color(0xFFEEEEEE),
    backgroundDepth5: Color(0xFFE0E0E0),
    surfaceAccent: Color(0xFFFBE9E7),
    accentPrimary: Color(0xFF00A896),
    accentSecondary: Color(0xFF00897B),
    accentTertiary: Color(0xFF00695C),
    textColor1: Color(0xFF1A1A1A),
    textColor2: Color(0xFF4A4A4A),
    textColor3: Color(0xFF808080),
    textColor4: Color(0xFFB3B3B3),
    borderDepth1: Color(0xFFE0E0E0),
    borderDepth2: Color(0xFFD0D0D0),
    successColor: Color(0xFF2E7D32),
    dangerColor: Color(0xFFC62828),
  );

  static const dark = AppColors._(
    backgroundDepth1: Color(0xFF0D0D0D),
    backgroundDepth2: Color(0xFF141414),
    backgroundDepth3: Color(0xFF1A1A1A),
    backgroundDepth4: Color(0xFF222222),
    backgroundDepth5: Color(0xFF2A2A2A),
    surfaceAccent: Color(0xFF1A2A2A),
    accentPrimary: Color(0xFF00D9B5),
    accentSecondary: Color(0xFF00A896),
    accentTertiary: Color(0xFF007A6E),
    textColor1: Color(0xFFE0E0E0),
    textColor2: Color(0xFFB3B3B3),
    textColor3: Color(0xFF808080),
    textColor4: Color(0xFF4D4D4D),
    borderDepth1: Color(0xFF2A2A2A),
    borderDepth2: Color(0xFF333333),
    successColor: Color(0xFF00D9B5),
    dangerColor: Color(0xFFFF6B6B),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

