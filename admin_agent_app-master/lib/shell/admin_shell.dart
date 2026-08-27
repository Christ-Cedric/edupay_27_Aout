import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/widgets/app_bottom_nav.dart';

/// Coquille de navigation Admin : barre basse à 4 onglets (Dashboard /
/// Familles / Finances / Params), pile de navigation indépendante par
/// onglet via [StatefulShellRoute.indexedStack] (voir `app_router.dart`).
///
/// Point d'extension pour le module Agent terrain : un futur coéquipier
/// ajoutera un `AgentShell` frère avec ses propres onglets, sans toucher à
/// ce fichier.
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    AppBottomNavItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
    AppBottomNavItem(icon: Icons.groups_outlined, label: 'Familles'),
    AppBottomNavItem(icon: Icons.payments_outlined, label: 'Finances'),
    AppBottomNavItem(icon: Icons.settings_outlined, label: 'Params'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        items: _items,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
