import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';

abstract final class AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: appFontFamily,
    scaffoldBackgroundColor: AppColors.mintCream,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.darkTeal,
      onPrimary: AppColors.mintCream,
      secondary: AppColors.strongCyan,
      onSecondary: AppColors.ink,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      outline: AppColors.border,
      error: AppColors.error,
      onError: Colors.white,
    ),
    dividerColor: AppColors.divider,
  );
}
