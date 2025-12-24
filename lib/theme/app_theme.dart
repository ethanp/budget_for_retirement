import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    final colors = AppColors.light;
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.backgroundDepth1,
      cardColor: colors.backgroundDepth2,
      primaryColor: colors.accentPrimary,
      colorScheme: ColorScheme.light(
        primary: colors.accentPrimary,
        secondary: colors.accentSecondary,
        surface: colors.backgroundDepth2,
        error: colors.dangerColor,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.accentPrimary,
        inactiveTrackColor: colors.backgroundDepth4,
        thumbColor: colors.accentSecondary,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: colors.textColor1),
        bodyMedium: TextStyle(color: colors.textColor2),
        bodySmall: TextStyle(color: colors.textColor3),
      ),
      dividerColor: colors.borderDepth1,
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: colors.accentPrimary,
        barBackgroundColor: colors.backgroundDepth2,
      ),
    );
  }

  static ThemeData dark() {
    final colors = AppColors.dark;
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.backgroundDepth1,
      cardColor: colors.backgroundDepth2,
      primaryColor: colors.accentPrimary,
      colorScheme: ColorScheme.dark(
        primary: colors.accentPrimary,
        secondary: colors.accentSecondary,
        surface: colors.backgroundDepth2,
        error: colors.dangerColor,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.accentPrimary,
        inactiveTrackColor: colors.backgroundDepth4,
        thumbColor: colors.accentSecondary,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: colors.textColor1),
        bodyMedium: TextStyle(color: colors.textColor2),
        bodySmall: TextStyle(color: colors.textColor3),
      ),
      dividerColor: colors.borderDepth1,
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: colors.accentPrimary,
        barBackgroundColor: colors.backgroundDepth2,
      ),
    );
  }
}
