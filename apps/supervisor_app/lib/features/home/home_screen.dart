import 'package:authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';

import '../../config/app_config.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(body: LoadingView());
    }

    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(config.homeTitle),
        actions: [
          IconButton(
            onPressed: auth.signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              config.homeSubtitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (user != null) ...[
              Text('Welcome, ${user.displayName}'),
              const SizedBox(height: 8),
              Text('Role: ${user.role.name}'),
              const SizedBox(height: 8),
              Text('Status: ${user.status.name}'),
            ],
            const Spacer(),
            FilledButton.icon(
              onPressed: () => context.go(AuthRoutes.login),
              icon: const Icon(Icons.supervisor_account),
              label: const Text('Supervisor app shell ready'),
            ),
          ],
        ),
      ),
    );
  }
}
