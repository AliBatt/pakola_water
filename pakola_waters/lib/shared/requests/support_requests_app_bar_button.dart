import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:provider/provider.dart';

import 'support_requests_controller.dart';

class SupportRequestsAppBarButton extends StatelessWidget {
  const SupportRequestsAppBarButton({
    super.key,
    required this.route,
  });

  final String route;

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<SupportRequestsController>().unreadCount;

    return IconButton(
      tooltip: context.l10n.navRequests,
      onPressed: () => context.push(route),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text('$unread'),
        child: const Icon(Icons.support_agent_outlined),
      ),
    );
  }
}
