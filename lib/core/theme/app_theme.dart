// lib/core/theme/app_theme.dart
// Builds light and dark ThemeData from AppColors and AppTextStyles.
// Uses useMaterial3: true with an explicit ColorScheme so exact hex values are kept.
// design.md section 14 says: do NOT use ColorScheme.fromSeed here.

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  // ── Shared shape theme ─────────────────────────────────────────────────────
  // Radius values from design.md section 6.
  static final _shapes = {
    'card': const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    'chip': const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    'dialog': const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
    ),
  };

  // ── Text theme ─────────────────────────────────────────────────────────────
  // Maps AppTextStyles onto Flutter's named text roles.
  // Widgets use Theme.of(context).textTheme.xxx — never hard-coded styles.
  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: AppTextStyles.display.copyWith(color: textColor),
      headlineMedium: AppTextStyles.headline.copyWith(color: textColor),
      titleLarge: AppTextStyles.title.copyWith(color: textColor),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: textColor),
      bodyMedium: AppTextStyles.body.copyWith(color: textColor),
      labelLarge: AppTextStyles.label.copyWith(color: textColor),
      bodySmall: AppTextStyles.caption.copyWith(color: textColor),
      // titleSmall is reused for the data style (coordinates, distances).
      titleSmall: AppTextStyles.data.copyWith(color: textColor),
    );
  }

  // ── Light theme ────────────────────────────────────────────────────────────
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      // Explicit ColorScheme — no fromSeed, so the exact design.md hex values are used.
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.primary, // same teal for simplicity
        onSecondary: AppColors.onPrimary,
        secondaryContainer: AppColors.primaryContainer,
        onSecondaryContainer: AppColors.onPrimaryContainer,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.inkMuted,
        outline: AppColors.outline,
        error: AppColors.errorLight,
        onError: AppColors.onPrimary,
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),
        scrim: Color(0xFF000000),
        shadow: Color(0xFF000000),
        inverseSurface: AppColors.ink,
        onInverseSurface: AppColors.surface,
        inversePrimary: AppColors.primaryContainer,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _buildTextTheme(AppColors.ink),
      // Card uses 1dp border, no shadow (design.md section 6).
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: _shapes['card'],
        margin: EdgeInsets.zero,
      ),
      // NavigationBar (bottom nav) uses surface background.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(AppTextStyles.label),
      ),
      // Chip defaults
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primaryContainer,
        labelStyle: AppTextStyles.label,
        shape: _shapes['chip'] as OutlinedBorder,
      ),
      // Dialog shape
      dialogTheme: DialogThemeData(shape: _shapes['dialog']),
    );
  }

  // ── Dark theme ─────────────────────────────────────────────────────────────
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkOnPrimary,
        primaryContainer: AppColors.darkPrimaryContainer,
        onPrimaryContainer: AppColors.darkOnPrimaryContainer,
        secondary: AppColors.darkPrimary,
        onSecondary: AppColors.darkOnPrimary,
        secondaryContainer: AppColors.darkPrimaryContainer,
        onSecondaryContainer: AppColors.darkOnPrimaryContainer,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkInk,
        surfaceContainerHighest: AppColors.darkSurfaceVariant,
        onSurfaceVariant: AppColors.darkInkMuted,
        outline: AppColors.darkOutline,
        error: AppColors.errorDark,
        onError: AppColors.darkOnPrimary,
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        scrim: Color(0xFF000000),
        shadow: Color(0xFF000000),
        inverseSurface: AppColors.darkInk,
        onInverseSurface: AppColors.darkSurface,
        inversePrimary: AppColors.darkPrimaryContainer,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: _buildTextTheme(AppColors.darkInk),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: _shapes['card'],
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.darkPrimaryContainer,
        labelTextStyle: WidgetStateProperty.all(
          AppTextStyles.label.copyWith(color: AppColors.darkInk),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        selectedColor: AppColors.darkPrimaryContainer,
        labelStyle: AppTextStyles.label.copyWith(color: AppColors.darkInk),
        shape: _shapes['chip'] as OutlinedBorder,
      ),
      dialogTheme: DialogThemeData(shape: _shapes['dialog']),
    );
  }
}
