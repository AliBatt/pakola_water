import 'package:flutter/material.dart';

/// Shared text styles built on Material 3 type scale.
class AppTypography {
  const AppTypography._();

  static TextTheme textTheme(ColorScheme colorScheme) {
    final base = Typography.material2021(
      platform: TargetPlatform.android,
    );
    final scheme = colorScheme.brightness == Brightness.light
        ? base.black
        : base.white;

    return scheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
  }
}
