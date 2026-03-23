import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_radius.dart';

class AppTheme {
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.actionPrimary,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.actionPrimary,
        secondary: AppColors.actionPrimaryHover,
        surface: AppColors.surface,
        error: AppColors.roseSolid,
        onPrimary: AppColors.actionPrimaryText,
        onSecondary: AppColors.actionPrimaryText,
        onSurface: AppColors.textPrimary,
        onError: AppColors.surface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        titleTextStyle: AppTextStyles.headingXl.copyWith(color: AppColors.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.violetSolid,
        selectionColor: AppColors.violetMuted,
        selectionHandleColor: AppColors.violetSolid,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgTertiary,
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.borderDefault, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.borderDefault, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.violetSolid, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.roseSolid, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.roseSolid, width: 1.5),
        ),
        floatingLabelStyle: AppTextStyles.labelSm.copyWith(color: AppColors.violetSolid),
        labelStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.actionPrimary,
          foregroundColor: AppColors.actionPrimaryText,
          textStyle: AppTextStyles.labelLg,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.actionSecondaryText,
          side: const BorderSide(color: AppColors.actionSecondaryBorder, width: 1.5),
          textStyle: AppTextStyles.labelLg,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.actionGhostText,
          textStyle: AppTextStyles.labelLg,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.darkActionPrimary,
      scaffoldBackgroundColor: AppColors.darkBgPrimary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkActionPrimary,
        secondary: AppColors.darkBgSecondary,
        surface: AppColors.darkSurface,
        error: AppColors.darkActionDestructive,
        onPrimary: AppColors.darkActionPrimaryText,
        onSecondary: AppColors.darkActionPrimaryText,
        onSurface: AppColors.darkTextPrimary,
        onError: AppColors.darkSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkTextSecondary),
        titleTextStyle: AppTextStyles.headingXl.copyWith(color: AppColors.darkTextPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.violetSolid,
        selectionColor: AppColors.darkVioletBorder,
        selectionHandleColor: AppColors.violetSolid,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkBgTertiary,
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.darkBorderDefault, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.darkBorderDefault, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.violetSolid, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.darkActionDestructive, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.darkActionDestructive, width: 1.5),
        ),
        floatingLabelStyle: AppTextStyles.labelSm.copyWith(color: AppColors.violetSolid),
        labelStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.darkTextMuted),
        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.darkTextMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkActionPrimary,
          foregroundColor: AppColors.darkActionPrimaryText,
          textStyle: AppTextStyles.labelLg,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkActionSecondaryText,
          side: const BorderSide(color: AppColors.darkActionSecondaryBorder, width: 1.5),
          textStyle: AppTextStyles.labelLg,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkActionGhostText,
          textStyle: AppTextStyles.labelLg,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
        ),
      ),
    );
  }
}
