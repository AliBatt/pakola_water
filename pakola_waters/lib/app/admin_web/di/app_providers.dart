import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:repositories/repositories.dart';
import 'package:rider_management/rider_management.dart';
import 'package:services/services.dart';

import '../features/branches/branches_controller.dart';
import '../features/products/products_controller.dart';
import '../features/supervisors/supervisors_controller.dart';

class AppProvidersResult {
  const AppProvidersResult({
    required this.providers,
    required this.authProvider,
  });

  final List<SingleChildWidget> providers;
  final AuthProvider authProvider;
}

class AppProviders {
  const AppProviders._();

  static AppProvidersResult create() {
    final logger = ConsoleLogger();
    final firebaseAuthService = FirebaseAuthService();
    final firestoreService = FirestoreService();
    final authAdminService = FirebaseAuthAdminService();
    final authService = AuthServiceImpl(firebaseAuthService);
    final userService = UserServiceImpl(
      firestoreService,
      authService,
      authAdminService: authAdminService,
    );
    final branchService = BranchServiceImpl(firestoreService);
    final productService = ProductServiceImpl(firestoreService);
    final notificationService = NotificationServiceImpl(firestoreService);
    final authRepository = AuthRepositoryImpl(authService);
    final userRepository = UserRepositoryImpl(userService);
    final branchRepository = BranchRepositoryImpl(branchService);
    final productRepository = ProductRepositoryImpl(productService);
    final notificationRepository =
        NotificationRepositoryImpl(notificationService);

    final authProvider = AuthProvider(
      authRepository: authRepository,
      userRepository: userRepository,
    )..initialize();

    return AppProvidersResult(
      authProvider: authProvider,
      providers: [
        Provider<AppLogger>.value(value: logger),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<UserRepository>.value(value: userRepository),
        Provider<BranchRepository>.value(value: branchRepository),
        Provider<ProductRepository>.value(value: productRepository),
        Provider<NotificationRepository>.value(value: notificationRepository),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider(
          create: (_) => SupervisorsController(
            userRepository: userRepository,
            branchRepository: branchRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => BranchesController(
            branchRepository: branchRepository,
            userRepository: userRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => RidersController(
            userRepository: userRepository,
            branchRepository: branchRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductsController(
            productRepository: productRepository,
          ),
        ),
      ],
    );
  }
}
