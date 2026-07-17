import 'package:authentication/authentication.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';

import '../../config/app_config.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final l10n = context.l10n;

    if (auth.isLoading) {
      return const Scaffold(body: LoadingView());
    }

    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminHomeTitle),
        actions: [
          IconButton(
            onPressed: auth.signOut,
            icon: const Icon(Icons.logout),
            tooltip: l10n.logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.adminHomeSubtitle,
              style: context.texts.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            if (user != null) ...[
              Text(l10n.welcomeUser(user.displayName)),
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.roleLabel(user.role.name)),
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.statusLabel(user.status.name)),
            ],
            const Spacer(),
            FilledButton.icon(
              onPressed: () => context.go(AuthRoutes.login),
              icon: const Icon(Icons.admin_panel_settings),
              label: Text(l10n.adminAppTitle),
            ),
          ],
        ),
      ),
    );
  }
}
