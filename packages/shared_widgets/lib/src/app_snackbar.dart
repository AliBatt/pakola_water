import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Centralized snackbar helpers aligned with [AppTheme].
class AppSnackBar {
  const AppSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _show(
      context,
      message,
      backgroundColor: Theme.of(context).colorScheme.inverseSurface,
      textColor: Theme.of(context).colorScheme.onInverseSurface,
      duration: duration,
      action: action,
    );
  }

  static void success(BuildContext context, String message) {
    _show(
      context,
      message,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
      icon: Icons.check_circle_outline,
    );
  }

  static void error(BuildContext context, String message) {
    final scheme = Theme.of(context).colorScheme;
    _show(
      context,
      message,
      backgroundColor: scheme.error,
      textColor: scheme.onError,
      icon: Icons.error_outline,
      duration: const Duration(seconds: 4),
    );
  }

  static void warning(BuildContext context, String message) {
    _show(
      context,
      message,
      backgroundColor: AppColors.warning,
      textColor: Colors.white,
      icon: Icons.warning_amber_rounded,
    );
  }

  static void info(BuildContext context, String message) {
    _show(
      context,
      message,
      backgroundColor: AppColors.info,
      textColor: Colors.white,
      icon: Icons.info_outline,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: backgroundColor,
        action: action,
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
