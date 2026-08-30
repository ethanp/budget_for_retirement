import 'package:flutter/material.dart';

class const AppColors._({
  required final Color backgroundDepth1,
  required final Color backgroundDepth2,
  required final Color backgroundDepth3,
  required final Color backgroundDepth4,
  required final Color backgroundDepth5,
  required final Color surfaceAccent,
  required final Color surfaceAccentSuccess,
  required final Color accentPrimary,
  required final Color accentSecondary,
  required final Color accentTertiary,
  required final Color textColor1,
  required final Color textColor2,
  required final Color textColor3,
  required final Color textColor4,
  required final Color borderDepth1,
  required final Color borderDepth2,
  required final Color successColor,
  required final Color dangerColor,
}) {
  static const light = AppColors._(
    backgroundDepth1: Color(0xFFFAFAFA),
    backgroundDepth2: Color(0xFFFFFFFF),
    backgroundDepth3: Color(0xFFF5F5F5),
    backgroundDepth4: Color(0xFFEEEEEE),
    backgroundDepth5: Color(0xFFE0E0E0),
    surfaceAccent: Color(0xFFFBE9E7),
    surfaceAccentSuccess: Color(0xFFE8F5E9),
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
    surfaceAccent: Color(0xFF2A1A1A),
    surfaceAccentSuccess: Color(0xFF1A2E1A),
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

  Color surfaceForHealth({required bool isHealthy}) =>
      isHealthy ? surfaceAccentSuccess : surfaceAccent;
}
