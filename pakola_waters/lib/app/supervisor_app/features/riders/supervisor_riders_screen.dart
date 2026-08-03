import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:rider_management/rider_management.dart';

import '../../../../shared/requests/support_requests_app_bar_button.dart';
import '../../routing/supervisor_routes.dart';
import '../notifications/supervisor_notifications_bell_button.dart';

class SupervisorRidersScreen extends StatelessWidget {
  const SupervisorRidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SupportRequestsAppBarButton(
          route: SupervisorRoutes.requests,
        ),
        title: Text(context.l10n.navRiders),
        actions: const [SupervisorNotificationsBellButton()],
      ),
      body: const RidersScreen(),
    );
  }
}
