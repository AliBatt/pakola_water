import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:models/models.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:repositories/repositories.dart';

import 'app_push_navigator.dart';
import 'local_notification_presenter.dart';

/// Registers FCM tokens and handles push open navigation for any mobile role.
class AppPushController extends ChangeNotifier {
  AppPushController({
    required UserRepository userRepository,
    required FirebaseMessagingService messagingService,
    required LocalNotificationPresenter localNotifications,
    required this.navigator,
  })  : _userRepository = userRepository,
        _messaging = messagingService,
        _localNotifications = localNotifications;

  final UserRepository _userRepository;
  final FirebaseMessagingService _messaging;
  final LocalNotificationPresenter _localNotifications;
  final AppPushNavigator navigator;

  GoRouter? _router;
  AppUser? _user;
  String? _token;
  bool _started = false;
  bool _starting = false;
  bool _permissionGranted = false;
  String? _lastError;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;

  bool get isRegistered => _token != null && _token!.isNotEmpty;
  bool get permissionGranted => _permissionGranted;
  String? get tokenPreview => _token == null || _token!.length < 12
      ? _token
      : '${_token!.substring(0, 12)}…';
  String? get lastError => _lastError;

  void attachRouter(GoRouter router) {
    _router = router;
  }

  void bindUser(AppUser? user) {
    if (user == null) {
      unawaited(_clearToken());
      _user = null;
      _started = false;
      _permissionGranted = false;
      _lastError = null;
      notifyListeners();
      return;
    }

    final switched = _user?.id != user.id;
    _user = user;
    if (switched) {
      _started = false;
      _token = null;
      _lastError = null;
    }
  }

  Future<void> ensureStarted({bool forcePermissionPrompt = false}) async {
    if (!AppPushNavigator.supportsPush) return;
    if (_user == null) return;
    if (_starting) return;
    if (_started && !forcePermissionPrompt && isRegistered) return;

    _starting = true;
    _lastError = null;
    notifyListeners();

    try {
      await _start(forcePermissionPrompt: forcePermissionPrompt);
      _started = true;
    } catch (error, stack) {
      _lastError = error.toString();
      debugPrint('[Push] start failed: $error\n$stack');
    } finally {
      _starting = false;
      notifyListeners();
    }
  }

  Future<void> _start({required bool forcePermissionPrompt}) async {
    await _localNotifications.initialize(
      onTap: (payload) {
        final router = _router;
        if (router == null) return;
        navigator.openFromPayload(router, payload);
      },
    );

    _permissionGranted = await _requestPermissions(
      forcePrompt: forcePermissionPrompt,
    );
    if (!_permissionGranted) {
      _lastError = 'Notification permission was not granted';
      debugPrint('[Push] permission denied');
      return;
    }

    await _messaging.setForegroundPresentationOptions();
    await _registerCurrentToken();
    await _listenForMessages();
  }

  Future<bool> _requestPermissions({required bool forcePrompt}) async {
    if (!kIsWeb && Platform.isAndroid) {
      var status = await Permission.notification.status;
      debugPrint('[Push] Android notification status: $status');
      if (status.isDenied || status.isRestricted || forcePrompt) {
        status = await Permission.notification.request();
        debugPrint('[Push] Android notification after request: $status');
      }
      if (status.isPermanentlyDenied) {
        if (forcePrompt) {
          await openAppSettings();
        }
        return false;
      }
      if (!status.isGranted) return false;
    }

    final settings = await _messaging.requestPermission();
    debugPrint('[Push] FCM authorization: ${settings.authorizationStatus}');
    final authorized =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;

    await _localNotifications.requestPermission();

    return authorized || (!kIsWeb && Platform.isAndroid);
  }

  Future<void> _listenForMessages() async {
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _messaging.onTokenRefresh.listen((token) async {
      _token = token;
      final user = _user;
      if (user == null) return;
      await _userRepository.registerFcmToken(userId: user.id, token: token);
      notifyListeners();
    });

    await _foregroundSub?.cancel();
    _foregroundSub = _messaging.onMessage.listen((message) async {
      final title = message.notification?.title ??
          message.data['title']?.toString() ??
          'Pakola Waters';
      final body = message.notification?.body ??
          message.data['body']?.toString() ??
          '';
      await _localNotifications.show(
        title: title,
        body: body,
        data: AppPushNavigator.dataFromMessage(message),
      );
    });

    await _openedSub?.cancel();
    _openedSub = _messaging.onMessageOpenedApp.listen((message) {
      final router = _router;
      if (router == null) return;
      navigator.openFromRemoteMessage(router, message);
    });

    final initial = await _messaging.getInitialMessage();
    if (initial != null && _router != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final router = _router;
        if (router == null) return;
        navigator.openFromRemoteMessage(router, initial);
      });
    }
  }

  Future<void> _registerCurrentToken() async {
    final user = _user;
    if (user == null) return;

    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) {
      _lastError = 'Could not get FCM token';
      debugPrint('[Push] no FCM token');
      return;
    }

    _token = token;
    final result = await _userRepository.registerFcmToken(
      userId: user.id,
      token: token,
    );
    switch (result) {
      case Success():
        debugPrint('[Push] FCM token saved for user ${user.id}');
        _lastError = null;
      case FailureResult(:final failure):
        _lastError = failure.message;
        debugPrint('[Push] FCM token save failed: ${failure.message}');
    }
  }

  Future<void> _clearToken() async {
    final user = _user;
    final token = _token;
    if (user != null && token != null && token.isNotEmpty) {
      await _userRepository.unregisterFcmToken(userId: user.id, token: token);
    }
    _token = null;
  }

  @override
  void dispose() {
    _tokenRefreshSub?.cancel();
    _foregroundSub?.cancel();
    _openedSub?.cancel();
    super.dispose();
  }
}
