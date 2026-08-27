import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/edupay_logo.dart';
import 'parent_app_state.dart';
import 'parent_scope.dart';

class ParentShell extends StatelessWidget {
  const ParentShell({
    super.key,
    this.child,
    this.title,
    this.navigationShell,
    this.showAppBar = true,
  });

  final Widget? child;
  final String? title;
  final StatefulNavigationShell? navigationShell;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;
    final isTabs = navigationShell != null;

    final scaffold = Scaffold(
      appBar: showAppBar
          ? AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: palette.background,
              foregroundColor: palette.textPrimary,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: null,
              title: const Padding(
                padding: EdgeInsets.only(left: 6),
                child: EduPayLogo(size: 24),
              ),
              centerTitle: false,
              actions: [
                _ThemeToggleButton(state: state, palette: palette),
                IconButton(
                  tooltip: 'Notifications',
                  onPressed: () {
                    if (GoRouterState.of(context).matchedLocation ==
                        '/app/notifications') {
                      return;
                    }
                    context.push('/app/notifications');
                  },
                  icon: _NotificationBellIcon(
                    color: const Color(0xFF00C853),
                    unreadCount: state.unreadNotificationsCount,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,
      body: Stack(
        children: [
          SafeArea(child: child ?? navigationShell!),
          if (state.loading)
            Container(
              color: palette.background.withValues(alpha: .78),
              child: Center(
                child: CircularProgressIndicator(color: palette.accentGreen),
              ),
            ),
        ],
      ),
      bottomNavigationBar: isTabs
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: palette.isDark
                        ? palette.hairline
                        : const Color(0xFFEDF2F7),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: palette.isDark ? .25 : .05,
                      ),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _GlassNavItem(
                      icon: Icons.home_outlined,
                      selectedIcon: Icons.home,
                      label: 'Accueil',
                      isSelected: navigationShell!.currentIndex == 0,
                      onTap: () => navigationShell!.goBranch(0),
                    ),
                    _GlassNavItem(
                      icon: Icons.savings_outlined,
                      selectedIcon: Icons.savings,
                      label: 'Épargnes',
                      isSelected: navigationShell!.currentIndex == 1,
                      onTap: () => navigationShell!.goBranch(1),
                    ),
                    _GlassNavItem(
                      icon: Icons.local_shipping_outlined,
                      selectedIcon: Icons.local_shipping,
                      label: 'Livraison',
                      isSelected: navigationShell!.currentIndex == 2,
                      onTap: () => navigationShell!.goBranch(2),
                    ),
                    _GlassNavItem(
                      icon: Icons.person_outline_rounded,
                      selectedIcon: Icons.person,
                      label: 'Profil',
                      isSelected: navigationShell!.currentIndex == 3,
                      onTap: () => navigationShell!.goBranch(3),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );

    final shell = navigationShell;
    if (shell != null) {
      return PopScope(
        canPop: shell.currentIndex == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) shell.goBranch(0);
        },
        child: scaffold,
      );
    }
    return scaffold;
  }
}

/// Icône de notifications avec badge de compteur non-lu
class _NotificationBellIcon extends StatelessWidget {
  const _NotificationBellIcon({required this.color, required this.unreadCount});

  final Color color;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(Icons.notifications, color: color, size: 26),
        if (unreadCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Bascule de thème dans l'AppBar
class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton({required this.state, required this.palette});

  final ParentAppState state;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final isDark = palette.isDark;
    return IconButton(
      tooltip: isDark ? 'Passer en mode clair' : 'Passer en mode sombre',
      onPressed: () =>
          state.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => RotationTransition(
          turns: Tween(begin: 0.6, end: 1.0).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Icon(
          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          key: ValueKey(isDark),
          color: isDark ? const Color(0xFFCBD5E6) : const Color(0xFFF5A623),
          size: 26,
        ),
      ),
    );
  }
}

class _GlassNavItem extends StatelessWidget {
  const _GlassNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F7EE) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected
                  ? const Color(0xFF00C853)
                  : const Color(0xFF64748B),
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF00C853)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
