import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:repositories/repositories.dart';
import 'package:services/services.dart';

import '../features/notifications/notifications_controller.dart';
import '../features/orders/orders_controller.dart';
import '../features/products/products_controller.dart';

class AppProvidersResult {
  const AppProvidersResult({
    required this.providers,
    required this.authProvider,
    required this.localeController,
  });

  final List<SingleChildWidget> providers;
  final AuthProvider authProvider;
  final LocaleController localeController;
}

class AppProviders {
  const AppProviders._();

  static Future<AppProvidersResult> create() async {
    final logger = ConsoleLogger();
    final firebaseAuthService = FirebaseAuthService();
    final firestoreService = FirestoreService();
    final authService = AuthServiceImpl(firebaseAuthService);
    final userService = UserServiceImpl(firestoreService, authService);
    final productService = ProductServiceImpl(firestoreService);
    final branchService = BranchServiceImpl(firestoreService);
    final orderService = OrderServiceImpl(firestoreService);
    final notificationService = NotificationServiceImpl(firestoreService);

    final authRepository = AuthRepositoryImpl(authService);
    final userRepository = UserRepositoryImpl(userService);
    final productRepository = ProductRepositoryImpl(productService);
    final branchRepository = BranchRepositoryImpl(branchService);
    final orderRepository = OrderRepositoryImpl(orderService);
    final notificationRepository =
        NotificationRepositoryImpl(notificationService);

    final authProvider = AuthProvider(
      authRepository: authRepository,
      userRepository: userRepository,
    )..initialize();

    final localeController = LocaleController();
    await localeController.load();

    return AppProvidersResult(
      authProvider: authProvider,
      localeController: localeController,
      providers: [
        Provider<AppLogger>.value(value: logger),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<UserRepository>.value(value: userRepository),
        Provider<ProductRepository>.value(value: productRepository),
        Provider<BranchRepository>.value(value: branchRepository),
        Provider<OrderRepository>.value(value: orderRepository),
        Provider<NotificationRepository>.value(value: notificationRepository),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<LocaleController>.value(value: localeController),
        ChangeNotifierProvider(
          create: (_) => ProductsController(productRepository),
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrdersController>(
          create: (context) => OrdersController(
            orderRepository: orderRepository,
            branchRepository: branchRepository,
          ),
          update: (context, auth, previous) {
            final controller = previous ??
                OrdersController(
                  orderRepository: orderRepository,
                  branchRepository: branchRepository,
                );
            controller.bindUser(auth.user);
            return controller;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, NotificationsController>(
          create: (_) => NotificationsController(notificationRepository),
          update: (context, auth, previous) {
            final controller = previous ??
                NotificationsController(notificationRepository);
            controller.bindUser(auth.user);
            return controller;
          },
        ),
      ],
    );
  }
}
