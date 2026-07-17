import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';

import '../../firebase_options.dart';
import 'app.dart';
import 'config/app_config.dart';
import 'di/app_providers.dart';
import 'routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const config = AppConfig(
    appName: 'Pakola Waters — Supervisor',
    requiredRole: AppRole.supervisor,
    homeTitle: 'Supervisor Dashboard',
    homeSubtitle: 'Manage branch orders, drivers, and inventory.',
    environment: AppEnvironment.dev,
  );

  await FirebaseBootstrap.initialize(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final providers = AppProviders.create();
  final authProvider = providers.authProvider;
  final router = createAppRouter(config: config, authProvider: authProvider);

  runApp(
    MultiProvider(
      providers: providers.providers,
      child: SupervisorApp(config: config, router: router),
    ),
  );
}
