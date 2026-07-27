import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
    appName: 'Pakola Waters — Customer',
    requiredRole: AppRole.customer,
    homeTitle: 'Customer Dashboard',
    homeSubtitle: 'Place and track your water delivery orders.',
    environment: AppEnvironment.dev,
  );

  await FirebaseBootstrap.initialize(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  final providers = await AppProviders.create();
  final authProvider = providers.authProvider;
  final router = createAppRouter(config: config, authProvider: authProvider);
  providers.pushController.attachRouter(router);

  runApp(
    MultiProvider(
      providers: providers.providers,
      child: CustomerApp(config: config, router: router),
    ),
  );
}
