import 'package:flutter/material.dart';
import 'neo_colors.dart';
import 'neo_spacing.dart';
import 'neo_typography.dart';

abstract final class NeoTheme {
  static ThemeData get lightTheme {
    final textTheme = TextTheme(
      headlineLarge: NeoTypography.headlineLg,
      headlineMedium: NeoTypography.headlineMd,
      headlineSmall: NeoTypography.headlineSm,
      titleLarge: NeoTypography.headlineMd,
      titleMedium: NeoTypography.headlineSm,
      titleSmall: NeoTypography.bodyLg,
      bodyLarge: NeoTypography.bodyLg,
      bodyMedium: NeoTypography.bodyMd,
      bodySmall: NeoTypography.bodySm,
      labelLarge: NeoTypography.labelMd,
      labelMedium: NeoTypography.labelSm,
      labelSmall: NeoTypography.labelSm,
    );

    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: NeoColors.primary,
      onPrimary: NeoColors.onPrimary,
      primaryContainer: NeoColors.primaryContainer,
      onPrimaryContainer: NeoColors.onPrimaryContainer,
      secondary: NeoColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: NeoColors.secondaryContainer,
      onSecondaryContainer: NeoColors.primary,
      surface: NeoColors.surface,
      onSurface: NeoColors.onSurface,
      surfaceContainerLowest: NeoColors.surfaceContainerLowest,
      surfaceContainerLow: NeoColors.surfaceContainerLow,
      surfaceContainer: NeoColors.surfaceContainer,
      surfaceContainerHigh: NeoColors.surfaceContainerHigh,
      surfaceContainerHighest: NeoColors.surfaceContainerHighest,
      error: NeoColors.error,
      onError: NeoColors.onError,
      outline: NeoColors.outline,
      outlineVariant: NeoColors.borderWhisper,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: NeoColors.surface,
      canvasColor: NeoColors.surface,
      textTheme: textTheme,
      dividerColor: NeoColors.borderWhisper,
      dividerTheme: const DividerThemeData(
        color: NeoColors.borderWhisper,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: NeoColors.surface,
        foregroundColor: NeoColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: NeoTypography.headlineSm,
        shape: const Border(
          bottom: BorderSide(color: NeoColors.borderWhisper, width: 1),
        ),
      ),
      cardTheme: const CardThemeData(
        color: NeoColors.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: NeoColors.borderWhisper, width: 1),
          borderRadius: NeoSpacing.roundedLg,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NeoColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: NeoSpacing.roundedSm,
          borderSide: const BorderSide(color: NeoColors.borderWhisper, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: NeoSpacing.roundedSm,
          borderSide: const BorderSide(color: NeoColors.borderWhisper, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: NeoSpacing.roundedSm,
          borderSide: const BorderSide(color: NeoColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: NeoSpacing.roundedSm,
          borderSide: const BorderSide(color: NeoColors.error, width: 1),
        ),
        hintStyle: NeoTypography.bodyMd.copyWith(color: NeoColors.subdued),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NeoColors.primary,
          foregroundColor: NeoColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: const RoundedRectangleBorder(
            borderRadius: NeoSpacing.roundedSm,
          ),
          textStyle: NeoTypography.headlineSm.copyWith(
            fontSize: 13,
            color: NeoColors.onPrimary,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NeoColors.primary,
          backgroundColor: Colors.transparent,
          elevation: 0,
          side: const BorderSide(color: NeoColors.borderWhisper, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: const RoundedRectangleBorder(
            borderRadius: NeoSpacing.roundedSm,
          ),
          textStyle: NeoTypography.headlineSm.copyWith(
            fontSize: 13,
            color: NeoColors.primary,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: NeoColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: const RoundedRectangleBorder(
            borderRadius: NeoSpacing.roundedSm,
          ),
        ),
      ),
    );
  }
}
