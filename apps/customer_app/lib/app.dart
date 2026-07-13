import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'config/app_config.dart';

class CustomerApp extends StatelessWidget {
  const CustomerApp({
    super.key,
    required this.config,
    required this.router,
  });

  final AppConfig config;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: config.appName,
      theme: AppTheme.light(),
      routerConfig: router,
      debugShowCheckedModeBanner: config.environment.isDev,
    );
  }
}
