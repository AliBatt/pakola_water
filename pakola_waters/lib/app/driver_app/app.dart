import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:provider/provider.dart';

import '../../shared/pakola_app.dart';
import 'config/app_config.dart';

class DriverApp extends StatelessWidget {
  const DriverApp({
    super.key,
    required this.config,
    required this.router,
  });

  final AppConfig config;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>().locale;
    return PakolaApp(
      title: config.appName,
      router: router,
      locale: locale,
      debugShowCheckedModeBanner: config.environment.isDev,
    );
  }
}
