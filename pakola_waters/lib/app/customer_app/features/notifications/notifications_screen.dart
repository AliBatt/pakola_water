import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:utilities/utilities.dart';

import '../../../../shared/push/customer_push_navigator.dart';
import 'notifications_controller.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NotificationsController>();
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navNotifications),
        actions: [
          if (controller.unreadCount > 0)
            TextButton(
              onPressed: () async {
                final result = await controller.markAllRead();
                if (!context.mounted) return;
                if (result case FailureResult(:final failure)) {
                  AppSnackBar.error(context, failure.message);
                }
              },
              child: Text(l10n.markAllRead),
            ),
        ],
      ),
      body: controller.notifications.isEmpty
          ? EmptyStateView(
              title: l10n.notificationsEmpty,
              subtitle: l10n.notificationsEmptySubtitle,
              icon: Icons.notifications_none,
            )
          : ListView.separated(
              itemCount: controller.notifications.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = controller.notifications[index];
                return _NotificationTile(
                  notification: notification,
                  timestamp: DateTimeFormatter.format(notification.createdAt),
                  onTap: () async {
                    if (!notification.read) {
                      await controller.markRead(notification.id);
                    }
                    if (!context.mounted) return;
                    CustomerPushNavigator.openFromData(
                      GoRouter.of(context),
                      {
                        'type': notification.type,
                        'orderId': notification.orderId ?? '',
                        'route': CustomerPushNavigator.routeForType(
                          notification.type,
                        ),
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.timestamp,
    required this.onTap,
  });

  final AppNotification notification;
  final String timestamp;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final from = notification.createdByName?.isNotEmpty == true
        ? notification.createdByName!
        : notification.createdByRole;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: notification.read
            ? context.colors.surfaceContainerHighest
            : context.colors.primaryContainer,
        child: Icon(
          Icons.notifications,
          color: notification.read
              ? context.colors.onSurfaceVariant
              : context.colors.onPrimaryContainer,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.read ? FontWeight.w500 : FontWeight.w700,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(notification.body),
          const SizedBox(height: 4),
          Text(
            [
              l10n.fromLabel(from),
              if (timestamp.isNotEmpty) timestamp,
              if (!notification.read) l10n.unread,
            ].join(' · '),
            style: context.texts.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
      isThreeLine: true,
    );
  }
}
