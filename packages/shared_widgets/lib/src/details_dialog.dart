import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class DetailField {
  const DetailField({required this.label, required this.value});

  final String label;
  final String value;
}

Future<void> showDetailsDialog({
  required BuildContext context,
  required String title,
  required List<DetailField> fields,
  VoidCallback? onEdit,
  Widget? header,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (header != null) ...[
                  header,
                  const SizedBox(height: AppSpacing.md),
                ],
                ...fields.map(
                  (field) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          field.label,
                          style: context.texts.labelMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          field.value.isEmpty ? '—' : field.value,
                          style: context.texts.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (onEdit != null)
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                onEdit();
              },
              child: const Text('Edit'),
            ),
        ],
      );
    },
  );
}
