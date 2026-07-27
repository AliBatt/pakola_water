import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../routing/driver_routes.dart';
import 'driver_notifications_controller.dart';

class DriverNotificationsBellButton extends StatelessWidget {
  const DriverNotificationsBellButton({super.key});

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<DriverNotificationsController>().unreadCount;
    return IconButton(
      tooltip: 'Notifications',
      onPressed: () => context.push(DriverRoutes.notifications),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text(unread > 9 ? '9+' : '$unread'),
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}
