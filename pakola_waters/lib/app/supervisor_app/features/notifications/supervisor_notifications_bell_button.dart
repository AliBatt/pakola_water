import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:provider/provider.dart';

import '../../routing/supervisor_routes.dart';
import 'supervisor_notifications_controller.dart';

class SupervisorNotificationsBellButton extends StatelessWidget {
  const SupervisorNotificationsBellButton({super.key});

  @override
  Widget build(BuildContext context) {
    final unread =
        context.watch<SupervisorNotificationsController>().unreadCount;
    final l10n = context.l10n;

    return IconButton(
      tooltip: l10n.navNotifications,
      onPressed: () => context.push(SupervisorRoutes.notifications),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text(unread > 99 ? '99+' : '$unread'),
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}
