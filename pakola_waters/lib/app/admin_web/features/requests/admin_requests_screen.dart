import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../../../shared/requests/support_requests_screen.dart';

class AdminRequestsScreen extends StatelessWidget {
  const AdminRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SupportRequestsScreen(
      isAdminView: true,
      title: context.l10n.navRequests,
      showCreateButton: false,
      showAppBar: false,
    );
  }
}
