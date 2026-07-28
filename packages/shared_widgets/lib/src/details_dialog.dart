import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_snackbar.dart';

class DetailField {
  const DetailField({
    required this.label,
    required this.value,
    this.copyable = false,
    this.icon,
    this.monospace = false,
  });

  final String label;
  final String value;
  final bool copyable;
  final IconData? icon;

  /// Prefer for IDs, codes, plates, CNIC, coordinates.
  final bool monospace;
}

Future<void> showDetailsDialog({
  required BuildContext context,
  required String title,
  required List<DetailField> fields,
  VoidCallback? onEdit,
  Widget? header,
  String? subtitle,
}) {
  final visibleFields =
      fields.where((field) => field.value.trim().isNotEmpty).toList();

  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.sm,
          0,
        ),
        contentPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  if (subtitle != null && subtitle.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle,
                        style: context.texts.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Close',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (header != null) ...[
                  header,
                  const SizedBox(height: AppSpacing.md),
                ],
                if (visibleFields.isEmpty)
                  Text(
                    'No details available.',
                    style: context.texts.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  )
                else
                  ...visibleFields.map(
                    (field) => _DetailFieldTile(field: field),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          if (onEdit != null)
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onEdit();
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit'),
            )
          else
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          if (onEdit != null)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
        ],
      );
    },
  );
}

class _DetailFieldTile extends StatelessWidget {
  const _DetailFieldTile({required this.field});

  final DetailField field;

  Future<void> _copy(BuildContext context) async {
    final value = field.value.trim();
    if (value.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) {
      AppSnackBar.success(context, '${field.label} copied');
    }
  }

  @override
  Widget build(BuildContext context) {
    final valueStyle = context.texts.bodyLarge?.copyWith(
      fontWeight: FontWeight.w600,
      fontFamily: field.monospace ? 'monospace' : null,
      letterSpacing: field.monospace ? 0.2 : null,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: field.copyable ? () => _copy(context) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (field.icon != null) ...[
                  Icon(
                    field.icon,
                    size: 18,
                    color: context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        field.label,
                        style: context.texts.labelMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      SelectableText(field.value, style: valueStyle),
                    ],
                  ),
                ),
                if (field.copyable)
                  IconButton(
                    tooltip: 'Copy ${field.label.toLowerCase()}',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _copy(context),
                    icon: const Icon(Icons.copy_outlined, size: 18),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact copy action used in list rows for phone/email/code.
class CopyValueButton extends StatelessWidget {
  const CopyValueButton({
    super.key,
    required this.value,
    required this.label,
    this.icon = Icons.copy_outlined,
  });

  final String value;
  final String label;
  final IconData icon;

  static Future<void> copy(
    BuildContext context, {
    required String value,
    required String label,
  }) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: trimmed));
    if (context.mounted) {
      AppSnackBar.success(context, '$label copied');
    }
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return const SizedBox.shrink();

    return IconButton(
      tooltip: 'Copy $label',
      visualDensity: VisualDensity.compact,
      onPressed: () => copy(context, value: trimmed, label: label),
      icon: Icon(icon, size: 18),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();
    final Color color;
    switch (normalized) {
      case 'active':
        color = AppColors.success;
      case 'inactive':
        color = context.colors.outline;
      case 'suspended':
        color = context.colors.error;
      case 'pending':
        color = AppColors.warning;
      default:
        color = context.colors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        status,
        style: context.texts.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
