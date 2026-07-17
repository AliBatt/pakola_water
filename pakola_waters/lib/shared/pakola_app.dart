import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';

/// Shared MaterialApp shell for all Pakola Waters entrypoints.
class PakolaApp extends StatelessWidget {
  const PakolaApp({
    super.key,
    required this.title,
    required this.router,
    this.debugShowCheckedModeBanner = false,
    this.themeMode = ThemeMode.system,
    this.locale,
  });

  final String title;
  final GoRouter router;
  final bool debugShowCheckedModeBanner;
  final ThemeMode themeMode;
  final Locale? locale;

  static const Size designSize = Size(375, 812);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: title,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
          debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        );
      },
    );
  }
}
