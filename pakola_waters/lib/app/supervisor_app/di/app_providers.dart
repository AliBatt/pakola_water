import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:repositories/repositories.dart';
import 'package:rider_management/rider_management.dart';
import 'package:services/services.dart';

import '../../../shared/push/app_push_controller.dart';
import '../../../shared/push/local_notification_presenter.dart';
import '../../../shared/push/supervisor_push_routes.dart';
import '../features/notifications/supervisor_notifications_controller.dart';
import '../features/orders/supervisor_orders_controller.dart';

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
    final authAdminService = FirebaseAuthAdminService();
    final messagingService = FirebaseMessagingService();
    final localNotifications = LocalNotificationPresenter();
    final authService = AuthServiceImpl(firebaseAuthService);
    final userService = UserServiceImpl(
      firestoreService,
      authService,
      authAdminService: authAdminService,
    );
    final branchService = BranchServiceImpl(firestoreService);
    final orderService = OrderServiceImpl(firestoreService);
    final notificationService = NotificationServiceImpl(firestoreService);
    final orderMessageService = OrderMessageServiceImpl(
      firestoreService,
      notificationService,
      userService,
    );

    final authRepository = AuthRepositoryImpl(authService);
    final userRepository = UserRepositoryImpl(userService);
    final branchRepository = BranchRepositoryImpl(branchService);
    final orderRepository = OrderRepositoryImpl(orderService);
    final notificationRepository =
        NotificationRepositoryImpl(notificationService);
    final orderMessageRepository =
        OrderMessageRepositoryImpl(orderMessageService);

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
      navigator: SupervisorPushRoutes.navigator,
    );

    return AppProvidersResult(
      authProvider: authProvider,
      localeController: localeController,
      pushController: pushController,
      providers: [
        Provider<AppLogger>.value(value: logger),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<UserRepository>.value(value: userRepository),
        Provider<BranchRepository>.value(value: branchRepository),
        Provider<OrderRepository>.value(value: orderRepository),
        Provider<NotificationRepository>.value(value: notificationRepository),
        Provider<OrderMessageRepository>.value(value: orderMessageRepository),
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
        ChangeNotifierProvider(
          create: (_) => RidersController(
            userRepository: userRepository,
            branchRepository: branchRepository,
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, SupervisorOrdersController>(
          create: (_) => SupervisorOrdersController(
            orderRepository: orderRepository,
            userRepository: userRepository,
            notificationRepository: notificationRepository,
          ),
          update: (context, auth, previous) {
            final controller = previous ??
                SupervisorOrdersController(
                  orderRepository: orderRepository,
                  userRepository: userRepository,
                  notificationRepository: notificationRepository,
                );
            controller.bindSupervisor(auth.user);
            return controller;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider,
            SupervisorNotificationsController>(
          create: (_) =>
              SupervisorNotificationsController(notificationRepository),
          update: (context, auth, previous) {
            final controller = previous ??
                SupervisorNotificationsController(notificationRepository);
            controller.bindUser(auth.user);
            return controller;
          },
        ),
      ],
    );
  }
}
