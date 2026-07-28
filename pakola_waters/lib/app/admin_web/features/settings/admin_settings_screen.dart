import 'package:authentication/authentication.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';

import '../../config/app_config.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  Future<void> _resetPassword(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final email = auth.user?.email;
    if (email == null || email.isEmpty) {
      AppSnackBar.warning(context, 'No email found for this account');
      return;
    }

    final success = await auth.sendPasswordResetEmail(email);
    if (!context.mounted) return;
    if (success) {
      AppSnackBar.success(context, 'Password reset email sent to $email');
    } else if (auth.errorMessage != null) {
      AppSnackBar.error(context, auth.errorMessage!);
    } else {
      AppSnackBar.error(context, 'Could not send password reset email');
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<AuthProvider>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final config = context.watch<AppConfig>();
    final user = auth.user;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: ListView(
        children: [
          Text(
            'Settings',
            style: context.texts.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Account details and admin console preferences.',
            style: context.texts.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: context.colors.primaryContainer,
                        child: Text(
                          (user?.displayName.isNotEmpty == true
                                  ? user!.displayName.characters.first
                                  : '?')
                              .toUpperCase(),
                          style: context.texts.titleLarge?.copyWith(
                            color: context.colors.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? 'Admin',
                              style: context.texts.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (user != null)
                              StatusBadge(status: user.status.name),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _CopyRow(
                    label: 'Email',
                    value: user?.email ?? '—',
                    icon: Icons.email_outlined,
                  ),
                  _CopyRow(
                    label: 'Phone',
                    value: user?.phone ?? '—',
                    icon: Icons.call_outlined,
                  ),
                  _CopyRow(
                    label: 'Role',
                    value: user?.role.name ?? 'admin',
                    icon: Icons.admin_panel_settings_outlined,
                  ),
                  _CopyRow(
                    label: 'User ID',
                    value: user?.id ?? '—',
                    icon: Icons.fingerprint,
                    monospace: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_reset_outlined),
                  title: const Text('Reset password'),
                  subtitle: Text(
                    user?.email == null
                        ? 'No email on this account'
                        : 'Send a reset link to ${user!.email}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _resetPassword(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: context.colors.error,
                  ),
                  title: Text(
                    'Sign out',
                    style: TextStyle(color: context.colors.error),
                  ),
                  subtitle: const Text('End this admin session'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _signOut(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: context.texts.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _InfoLine(label: 'App', value: config.appName),
                  _InfoLine(
                    label: 'Environment',
                    value: config.environment.name,
                  ),
                  const _InfoLine(label: 'Version', value: '0.1.0+1'),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Manage branches, staff, products, orders, payments, and reports from this console.',
                    style: context.texts.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyRow extends StatelessWidget {
  const _CopyRow({
    required this.label,
    required this.value,
    required this.icon,
    this.monospace = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final canCopy = value.trim().isNotEmpty && value != '—';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: !canCopy
              ? null
              : () async {
                  await Clipboard.setData(ClipboardData(text: value));
                  if (context.mounted) {
                    AppSnackBar.success(context, '$label copied');
                  }
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: context.colors.onSurfaceVariant),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: context.texts.labelMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      SelectableText(
                        value,
                        style: context.texts.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontFamily: monospace ? 'monospace' : null,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canCopy)
                  Icon(
                    Icons.copy_outlined,
                    size: 18,
                    color: context.colors.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: context.texts.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.texts.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
