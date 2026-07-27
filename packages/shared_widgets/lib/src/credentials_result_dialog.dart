import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_snackbar.dart';

Future<void> showCredentialsResultDialog({
  required BuildContext context,
  required String title,
  required String email,
  required String password,
  bool generatedEmail = false,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => CredentialsResultDialog(
      title: title,
      email: email,
      password: password,
      generatedEmail: generatedEmail,
    ),
  );
}

class CredentialsResultDialog extends StatelessWidget {
  const CredentialsResultDialog({
    super.key,
    required this.title,
    required this.email,
    required this.password,
    this.generatedEmail = false,
  });

  final String title;
  final String email;
  final String password;
  final bool generatedEmail;

  Future<void> _copy(BuildContext context, String label, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) {
      AppSnackBar.success(context, '$label copied');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Share these credentials securely. The password is shown once.',
            style: context.texts.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _CredentialRow(
            label: 'Login email',
            value: email,
            onCopy: () => _copy(context, 'Email', email),
          ),
          const SizedBox(height: AppSpacing.sm),
          _CredentialRow(
            label: 'Temporary password',
            value: password,
            onCopy: () => _copy(context, 'Password', password),
          ),
          if (generatedEmail) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Email was auto-generated from phone number.',
              style: context.texts.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      actions: [
        OutlinedButton.icon(
          onPressed: () async {
            await Clipboard.setData(
              ClipboardData(text: 'Email: $email\nPassword: $password'),
            );
            if (context.mounted) {
              AppSnackBar.success(context, 'Credentials copied');
            }
          },
          icon: const Icon(Icons.copy_all),
          label: const Text('Copy all'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

class _CredentialRow extends StatelessWidget {
  const _CredentialRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  final String label;
  final String value;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.texts.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: context.texts.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Copy',
            onPressed: onCopy,
            icon: const Icon(Icons.copy_outlined),
          ),
        ],
      ),
    );
  }
}
