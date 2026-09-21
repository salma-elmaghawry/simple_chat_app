import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_chat_app/core/theme/app_colors.dart';
import 'package:simple_chat_app/core/utils/app_text_styles.dart';

class AppTheme {
  static ThemeData get light => _build(
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.third,
      surface: AppColors.surfaceLight,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimaryLight,
      onSurfaceVariant: AppColors.textSecondaryLight,
      outline: AppColors.outlineLight,
    ),
    background: AppColors.backgroundLight,
  );

  static ThemeData get dark => _build(
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryOnDark,
      secondary: AppColors.secondaryOnDark,
      tertiary: AppColors.third,
      surface: AppColors.surfaceDark,
      error: AppColors.errorOnDark,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: AppColors.textPrimaryDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      outline: AppColors.outlineDark,
    ),
    background: AppColors.backgroundDark,
  );

  static ThemeData _build({
    required ColorScheme colorScheme,
    required Color background,
  }) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      fontFamily: AppTextStyles.fontFamily,
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme,
      textTheme:
          TextTheme(
            headlineLarge: AppTextStyles.font34Bold,
            headlineMedium: AppTextStyles.font23Bold,
            titleLarge: AppTextStyles.font17Bold,
            bodyLarge: AppTextStyles.font14Normal,
            bodyMedium: AppTextStyles.font14Point4Normal,
            bodySmall: AppTextStyles.font11Normal,
          ).apply(
            bodyColor: colorScheme.onSurface,
            displayColor: colorScheme.onSurface,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorScheme.primary,
      ),
      inputDecorationTheme: InputDecorationThemeData(
        constraints: BoxConstraints(minHeight: 48.h),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        border: _inputBorder(colorScheme.outline),
        enabledBorder: _inputBorder(colorScheme.outline),
        focusedBorder: _inputBorder(colorScheme.primary),
        errorBorder: _inputBorder(colorScheme.error),
        focusedErrorBorder: _inputBorder(colorScheme.error),
        errorStyle: AppTextStyles.font11Normal.copyWith(
          color: colorScheme.error,
        ),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16.r),
    borderSide: BorderSide(color: color, width: 1.5),
  );
}
