import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:repositories/repositories.dart';
import 'package:services/services.dart';

import '../../../shared/push/app_push_controller.dart';
import '../../../shared/push/driver_push_routes.dart';
import '../../../shared/push/local_notification_presenter.dart';
import '../features/notifications/driver_notifications_controller.dart';
import '../features/orders/driver_orders_controller.dart';
import '../../../shared/requests/support_requests_controller.dart';

class AppProvidersResult {
  const AppProvidersResult({
    required this.providers,
    required this.authProvider,
    required this.localeController,
    required this.pushController,
  });

  final List<SingleChildWidget> providers;
  final AuthProvider authProvider;
  final LocaleController localeController;
  final AppPushController pushController;
}

class AppProviders {
  const AppProviders._();

  static Future<AppProvidersResult> create() async {
    final logger = ConsoleLogger();
    final firebaseAuthService = FirebaseAuthService();
    final firestoreService = FirestoreService();
    final messagingService = FirebaseMessagingService();
    final localNotifications = LocalNotificationPresenter();
    final authService = AuthServiceImpl(firebaseAuthService);
    final userService = UserServiceImpl(firestoreService, authService);
    final orderService = OrderServiceImpl(firestoreService);
    final notificationService = NotificationServiceImpl(firestoreService);
    final orderMessageService = OrderMessageServiceImpl(
      firestoreService,
      notificationService,
      userService,
    );
    final supportRequestService = SupportRequestServiceImpl(
      firestoreService,
      notificationService,
    );

    final authRepository = AuthRepositoryImpl(authService);
    final userRepository = UserRepositoryImpl(userService);
    final orderRepository = OrderRepositoryImpl(orderService);
    final notificationRepository =
        NotificationRepositoryImpl(notificationService);
    final orderMessageRepository =
        OrderMessageRepositoryImpl(orderMessageService);
    final supportRequestRepository =
        SupportRequestRepositoryImpl(supportRequestService);

    final authProvider = AuthProvider(
      authRepository: authRepository,
      userRepository: userRepository,
    )..initialize();

    final localeController = LocaleController();
    await localeController.load();

    final pushController = AppPushController(
      userRepository: userRepository,
      messagingService: messagingService,
      localNotifications: localNotifications,
      navigator: DriverPushRoutes.navigator,
    );

    return AppProvidersResult(
      authProvider: authProvider,
      localeController: localeController,
      pushController: pushController,
      providers: [
        Provider<AppLogger>.value(value: logger),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<UserRepository>.value(value: userRepository),
        Provider<OrderRepository>.value(value: orderRepository),
        Provider<NotificationRepository>.value(value: notificationRepository),
        Provider<OrderMessageRepository>.value(value: orderMessageRepository),
        Provider<SupportRequestRepository>.value(
          value: supportRequestRepository,
        ),
        Provider<FirebaseMessagingService>.value(value: messagingService),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<LocaleController>.value(value: localeController),
        ChangeNotifierProxyProvider<AuthProvider, AppPushController>(
          create: (_) => pushController,
          update: (context, auth, previous) {
            final controller = previous ?? pushController;
            controller.bindUser(auth.user);
            return controller;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, SupportRequestsController>(
          create: (_) => SupportRequestsController(
            requestRepository: supportRequestRepository,
          ),
          update: (context, auth, previous) {
            final controller = previous ??
                SupportRequestsController(
                  requestRepository: supportRequestRepository,
                );
            controller.bindUser(auth.user);
            return controller;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, DriverOrdersController>(
          create: (_) => DriverOrdersController(
            orderRepository: orderRepository,
            notificationRepository: notificationRepository,
          ),
          update: (context, auth, previous) {
            final controller = previous ??
                DriverOrdersController(
                  orderRepository: orderRepository,
                  notificationRepository: notificationRepository,
                );
            controller.bindRider(auth.user);
            return controller;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, DriverNotificationsController>(
          create: (_) => DriverNotificationsController(notificationRepository),
          update: (context, auth, previous) {
            final controller = previous ??
                DriverNotificationsController(notificationRepository);
            controller.bindUser(auth.user);
            return controller;
          },
        ),
      ],
    );
  }
}
