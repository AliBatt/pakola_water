import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:rider_management/rider_management.dart';

class SupervisorRidersScreen extends StatelessWidget {
  const SupervisorRidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.navRiders)),
      body: const RidersScreen(),
    );
  }
}
