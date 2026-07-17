import 'package:flutter/material.dart';

/// Convenient theme / media accessors on [BuildContext].
extension AppContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => theme.colorScheme;

  TextTheme get texts => theme.textTheme;

  bool get isDark => theme.brightness == Brightness.dark;

  MediaQueryData get mq => MediaQuery.of(this);

  Size get screenSize => mq.size;

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  bool get isPhone => screenWidth < 600;

  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;

  bool get isDesktop => screenWidth >= 1024;

  EdgeInsets get padding => mq.padding;

  EdgeInsets get viewInsets => mq.viewInsets;
}
