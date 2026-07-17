import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/pakola_app.dart';
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
    return PakolaApp(
      title: config.appName,
      router: router,
      debugShowCheckedModeBanner: config.environment.isDev,
    );
  }
}
