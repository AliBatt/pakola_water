import 'package:authentication/authentication.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:provider/provider.dart';

import 'admin_nav_destinations.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  static const double _sidebarWidth = 260;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthProvider>();
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = AdminNavDestination.indexForLocation(location);
    final selected = AdminNavDestination.items[selectedIndex];
    final wide = MediaQuery.sizeOf(context).width >= 900;

    final sidebar = _AdminSidebar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        final route = AdminNavDestination.items[index].route;
        if (route != location) {
          context.go(route);
        }
        if (!wide && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      onSignOut: auth.signOut,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(selected.labelBuilder(l10n)),
        actions: [
          if (auth.user != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Center(
                child: Text(
                  auth.user!.displayName,
                  style: context.texts.bodyMedium,
                ),
              ),
            ),
          IconButton(
            onPressed: auth.signOut,
            tooltip: l10n.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: wide ? null : Drawer(child: sidebar),
      body: Row(
        children: [
          if (wide)
            SizedBox(
              width: _sidebarWidth,
              child: Material(
                color: context.colors.surface,
                elevation: 0,
                child: sidebar,
              ),
            ),
          if (wide)
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: context.colors.outlineVariant,
            ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onSignOut,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 36,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.appTitle,
                    style: context.texts.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: AdminNavDestination.items.length,
              itemBuilder: (context, index) {
                final item = AdminNavDestination.items[index];
                final selected = index == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  child: ListTile(
                    selected: selected,
                    selectedTileColor: colors.primaryContainer.withValues(
                      alpha: 0.55,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    leading: Icon(
                      selected ? item.selectedIcon : item.icon,
                      color: selected
                          ? colors.primary
                          : colors.onSurfaceVariant,
                    ),
                    title: Text(
                      item.labelBuilder(l10n),
                      style: context.texts.bodyMedium?.copyWith(
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                        color: selected ? colors.primary : colors.onSurface,
                      ),
                    ),
                    onTap: () => onDestinationSelected(index),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              leading: Icon(Icons.logout, color: colors.error),
              title: Text(
                l10n.logout,
                style: TextStyle(color: colors.error),
              ),
              onTap: onSignOut,
            ),
          ),
        ],
      ),
    );
  }
}
