import 'package:flutter/material.dart';

/// Brand and semantic color tokens for Pakola Waters.
class AppColors {
  const AppColors._();

  // Brand
  static const Color primary = Color(0xFF0277BD);
  static const Color primaryDark = Color(0xFF01579B);
  static const Color primaryLight = Color(0xFF58A5F0);
  static const Color secondary = Color(0xFF00ACC1);
  static const Color secondaryDark = Color(0xFF00838F);
  static const Color secondaryLight = Color(0xFF5DDEF4);

  // Semantic
  static const Color error = Color(0xFFD32F2F);
  static const Color errorDark = Color(0xFFEF5350);
  static const Color success = Color(0xFF388E3C);
  static const Color successDark = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningDark = Color(0xFFFFA726);
  static const Color info = Color(0xFF0288D1);
  static const Color infoDark = Color(0xFF4FC3F7);

  // Neutrals — light
  static const Color backgroundLight = Color(0xFFF5F9FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFE3F2FD);
  static const Color onSurfaceLight = Color(0xFF1A2332);
  static const Color onSurfaceVariantLight = Color(0xFF5A6A7A);
  static const Color outlineLight = Color(0xFFC5D0DB);

  // Neutrals — dark
  static const Color backgroundDark = Color(0xFF0B1219);
  static const Color surfaceDark = Color(0xFF15202B);
  static const Color surfaceVariantDark = Color(0xFF1E2A38);
  static const Color onSurfaceDark = Color(0xFFE8EEF4);
  static const Color onSurfaceVariantDark = Color(0xFFA8B8C8);
  static const Color outlineDark = Color(0xFF3A4A5A);

  static ColorScheme lightColorScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFB3E5FC),
      onPrimaryContainer: primaryDark,
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFB2EBF2),
      onSecondaryContainer: secondaryDark,
      tertiary: info,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFB3E5FC),
      onTertiaryContainer: Color(0xFF01579B),
      error: error,
      onError: Colors.white,
      errorContainer: Color(0xFFFFCDD2),
      onErrorContainer: Color(0xFFB71C1C),
      surface: surfaceLight,
      onSurface: onSurfaceLight,
      surfaceContainerHighest: surfaceVariantLight,
      onSurfaceVariant: onSurfaceVariantLight,
      outline: outlineLight,
      outlineVariant: Color(0xFFE0E7EE),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: surfaceDark,
      onInverseSurface: onSurfaceDark,
      inversePrimary: primaryLight,
    );
  }

  static ColorScheme darkColorScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: primaryLight,
      onPrimary: Color(0xFF003258),
      primaryContainer: primaryDark,
      onPrimaryContainer: Color(0xFFB3E5FC),
      secondary: secondaryLight,
      onSecondary: Color(0xFF00363D),
      secondaryContainer: secondaryDark,
      onSecondaryContainer: Color(0xFFB2EBF2),
      tertiary: infoDark,
      onTertiary: Color(0xFF003258),
      tertiaryContainer: Color(0xFF01579B),
      onTertiaryContainer: Color(0xFFB3E5FC),
      error: errorDark,
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: surfaceDark,
      onSurface: onSurfaceDark,
      surfaceContainerHighest: surfaceVariantDark,
      onSurfaceVariant: onSurfaceVariantDark,
      outline: outlineDark,
      outlineVariant: Color(0xFF2A3A4A),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: surfaceLight,
      onInverseSurface: onSurfaceLight,
      inversePrimary: primary,
    );
  }
}
