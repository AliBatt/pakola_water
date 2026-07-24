import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:provider/provider.dart';

import '../../routing/customer_routes.dart';
import 'notifications_controller.dart';

class NotificationsBellButton extends StatelessWidget {
  const NotificationsBellButton({super.key});

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotificationsController>().unreadCount;
    final l10n = context.l10n;

    return IconButton(
      tooltip: l10n.navNotifications,
      onPressed: () => context.push(CustomerRoutes.notifications),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text(unread > 99 ? '99+' : '$unread'),
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}
