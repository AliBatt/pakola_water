import 'package:authentication/authentication.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';

import '../../../../shared/push/app_push_controller.dart';
import '../notifications/supervisor_notifications_bell_button.dart';

class SupervisorSettingsScreen extends StatelessWidget {
  const SupervisorSettingsScreen({super.key});

  Future<void> _resetPassword(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final l10n = context.l10n;
    final email = auth.user?.email;
    if (email == null || email.isEmpty) {
      AppSnackBar.warning(context, l10n.errorGeneric);
      return;
    }

    final success = await auth.sendPasswordResetEmail(email);
    if (!context.mounted) return;
    if (success) {
      AppSnackBar.success(context, '${l10n.resetPassword}: $email');
    } else if (auth.errorMessage != null) {
      AppSnackBar.error(context, auth.errorMessage!);
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccountConfirmTitle),
        content: Text(l10n.deleteAccountConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteAccount),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.deleteAccount();
    if (!context.mounted) return;
    if (success) {
      AppSnackBar.success(context, l10n.deleteAccountSuccess);
    } else {
      final message = auth.errorMessage ?? '';
      if (message.contains('requires-recent-login') ||
          message.contains('recent')) {
        AppSnackBar.warning(context, l10n.deleteAccountReauthRequired);
      } else {
        AppSnackBar.error(context, message.isEmpty ? l10n.errorGeneric : message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final localeController = context.watch<LocaleController>();
    final push = context.watch<AppPushController>();
    final user = auth.user;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navSettings),
        actions: const [SupervisorNotificationsBellButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (user != null) ...[
            Text(
              user.displayName,
              style: context.texts.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(user.email),
            if (user.phone != null) Text(user.phone!),
            if (user.primaryBranchId != null)
              Text('Branch: ${user.primaryBranchId}'),
            const Divider(height: AppSpacing.xl),
          ],
          ListTile(
            leading: Icon(
              push.permissionGranted && push.isRegistered
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
            ),
            title: const Text('Push notifications'),
            subtitle: Text(
              push.isRegistered
                  ? 'Enabled · token ${push.tokenPreview}'
                  : (push.lastError ??
                      'Disabled — tap Enable to allow notifications'),
            ),
            trailing: push.isRegistered
                ? null
                : TextButton(
                    onPressed: () async {
                      await context
                          .read<AppPushController>()
                          .ensureStarted(forcePermissionPrompt: true);
                      if (!context.mounted) return;
                      final current = context.read<AppPushController>();
                      if (current.isRegistered) {
                        AppSnackBar.success(context, 'Notifications enabled');
                      } else {
                        AppSnackBar.warning(
                          context,
                          current.lastError ??
                              'Could not enable notifications',
                        );
                      }
                    },
                    child: const Text('Enable'),
                  ),
          ),
          const Divider(height: AppSpacing.xl),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(l10n.languageSubtitle),
          ),
          RadioListTile<String>(
            value: 'en',
            groupValue: localeController.locale.languageCode,
            title: Text(l10n.languageEnglish),
            onChanged: (_) => localeController.setEnglish(),
          ),
          RadioListTile<String>(
            value: 'ur',
            groupValue: localeController.locale.languageCode,
            title: Text(l10n.languageUrdu),
            onChanged: (_) => localeController.setUrdu(),
          ),
          const Divider(height: AppSpacing.xl),
          ListTile(
            leading: const Icon(Icons.lock_reset_outlined),
            title: Text(l10n.resetPassword),
            subtitle: Text(l10n.resetPasswordSubtitle),
            onTap: () => _resetPassword(context),
          ),
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: context.colors.error),
            title: Text(
              l10n.deleteAccount,
              style: TextStyle(color: context.colors.error),
            ),
            subtitle: Text(l10n.deleteAccountSubtitle),
            onTap: () => _deleteAccount(context),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: context.colors.error),
            title: Text(
              l10n.logout,
              style: TextStyle(color: context.colors.error),
            ),
            onTap: () => auth.signOut(),
          ),
        ],
      ),
    );
  }
}
