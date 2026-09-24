import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/widgets/app_bottom_nav.dart';
import 'widgets/admin_desktop_header.dart';
import 'widgets/admin_desktop_sidebar.dart';

/// Coquille de navigation Admin :
/// - En mode Desktop/Web (largeur >= 960px) : barre latérale (Sidebar) complète
///   regroupant l'ensemble des modules, plus un en-tête supérieur (TopBar).
/// - En mode Mobile (< 960px) : barre basse standard à 4 onglets.
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
    final isDesktop = MediaQuery.sizeOf(context).width >= 960;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A1628),
        body: Row(
          children: [
            const AdminDesktopSidebar(),
            Expanded(
              child: Column(
                children: [
                  const AdminDesktopHeader(),
                  Expanded(child: navigationShell),
                ],
              ),
            ),
          ],
        ),
      );
    }

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
