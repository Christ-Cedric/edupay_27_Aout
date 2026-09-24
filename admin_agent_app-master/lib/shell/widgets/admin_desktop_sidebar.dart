import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../features/notifications/presentation/providers/notifications_providers.dart';

/// Barre latérale de navigation pour la version Web / Desktop d'EduP@y Admin.
///
/// Regroupe l'intégralité des fonctionnalités administratives en sections
/// claires et hiérarchisées avec indicateur visuel de la route active.
class AdminDesktopSidebar extends ConsumerWidget {
  const AdminDesktopSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final session = ref.watch(sessionControllerProvider).value;
    final unreadNotifications = ref
            .watch(notificationsListProvider)
            .value
            ?.where((n) => !n.isRead)
            .length ??
        0;

    return Container(
      width: 270,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.surfaceBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête : Logo & Titre
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    border: Border.all(
                      color: AppColors.green.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: AppColors.green,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'EduP@y',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ADMIN',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w800,
                                fontSize: 9,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Portail de Gestion',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Badge statut système & saison
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(AppRadii.input),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Saison 2026-2027',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Actif',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.surfaceBorder, height: 1),

          // Menu de navigation défilant
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 2,
                vertical: AppSpacing.sm,
              ),
              children: [
                // SECTION 1 : VUE D'ENSEMBLE
                const _SidebarSectionTitle(title: "VUE D'ENSEMBLE"),
                _SidebarNavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Tableau de bord',
                  route: '/admin/dashboard',
                  isActive: location == '/admin/dashboard',
                ),
                _SidebarNavItem(
                  icon: Icons.warning_amber_rounded,
                  label: 'Alertes & Impayés',
                  route: '/admin/dashboard/alerts',
                  isActive: location == '/admin/dashboard/alerts',
                ),
                _SidebarNavItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  route: '/admin/dashboard/notifications',
                  isActive: location == '/admin/dashboard/notifications',
                  badgeCount: unreadNotifications,
                ),

                const SizedBox(height: AppSpacing.sm),

                // SECTION 2 : FAMILLES
                const _SidebarSectionTitle(title: 'GESTION DES FAMILLES'),
                _SidebarNavItem(
                  icon: Icons.groups_rounded,
                  label: 'Liste des Familles',
                  route: '/admin/families',
                  isActive: location == '/admin/families' ||
                      (location.startsWith('/admin/families/') &&
                          !location.startsWith('/admin/families/enroll') &&
                          !location.startsWith('/admin/families/pending')),
                ),
                _SidebarNavItem(
                  icon: Icons.person_add_alt_1_rounded,
                  label: 'Nouvelle Inscription',
                  route: '/admin/families/enroll',
                  isActive: location.startsWith('/admin/families/enroll'),
                ),
                _SidebarNavItem(
                  icon: Icons.pending_actions_rounded,
                  label: 'Validations en attente',
                  route: '/admin/families/pending',
                  isActive: location == '/admin/families/pending',
                ),

                const SizedBox(height: AppSpacing.sm),

                // SECTION 3 : FINANCES
                const _SidebarSectionTitle(title: 'FINANCES & LOGISTIQUE'),
                _SidebarNavItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Vue Financière',
                  route: '/admin/finances',
                  isActive: location == '/admin/finances',
                ),
                _SidebarNavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Rapports & Statistiques',
                  route: '/admin/finances/reports',
                  isActive: location == '/admin/finances/reports',
                ),
                _SidebarNavItem(
                  icon: Icons.replay_rounded,
                  label: 'Remboursements',
                  route: '/admin/finances/refunds',
                  isActive: location.startsWith('/admin/finances/refunds'),
                ),
                _SidebarNavItem(
                  icon: Icons.local_shipping_rounded,
                  label: 'Livraisons de Kits',
                  route: '/admin/finances/deliveries',
                  isActive: location == '/admin/finances/deliveries',
                ),

                const SizedBox(height: AppSpacing.sm),

                // SECTION 4 : AGENTS
                const _SidebarSectionTitle(title: 'AGENTS DE TERRAIN'),
                _SidebarNavItem(
                  icon: Icons.badge_rounded,
                  label: 'Équipe des Agents',
                  route: '/admin/settings/agents',
                  isActive: location == '/admin/settings/agents' ||
                      (location.startsWith('/admin/settings/agents/') &&
                          !location.startsWith('/admin/settings/agents/new')),
                ),
                _SidebarNavItem(
                  icon: Icons.person_add_rounded,
                  label: 'Recruter un Agent',
                  route: '/admin/settings/agents/new',
                  isActive: location == '/admin/settings/agents/new',
                ),

                const SizedBox(height: AppSpacing.sm),

                // SECTION 5 : CATALOGUE
                const _SidebarSectionTitle(title: 'CATALOGUE & FOURNITURES'),
                _SidebarNavItem(
                  icon: Icons.inventory_2_rounded,
                  label: 'Catalogue des Kits',
                  route: '/admin/settings/kits',
                  isActive: location == '/admin/settings/kits' ||
                      (location.startsWith('/admin/settings/kits/') &&
                          !location.startsWith('/admin/settings/kits/supplies') &&
                          !location.startsWith('/admin/settings/kits/stats')),
                ),
                _SidebarNavItem(
                  icon: Icons.auto_stories_rounded,
                  label: 'Fournitures scolaires',
                  route: '/admin/settings/kits/supplies',
                  isActive: location.startsWith('/admin/settings/kits/supplies'),
                ),
                _SidebarNavItem(
                  icon: Icons.two_wheeler_rounded,
                  label: 'Moyens de déplacement',
                  route: '/admin/settings/vehicles',
                  isActive: location.startsWith('/admin/settings/vehicles'),
                ),
                _SidebarNavItem(
                  icon: Icons.analytics_rounded,
                  label: 'Statistiques des Kits',
                  route: '/admin/settings/kits/stats',
                  isActive: location == '/admin/settings/kits/stats',
                ),

                const SizedBox(height: AppSpacing.sm),

                // SECTION 6 : CONFIGURATION
                const _SidebarSectionTitle(title: 'SYSTÈME & PARAMÈTRES'),
                _SidebarNavItem(
                  icon: Icons.calendar_month_rounded,
                  label: 'Saisons Scolaires',
                  route: '/admin/settings/seasons',
                  isActive: location.startsWith('/admin/settings/seasons'),
                ),
                _SidebarNavItem(
                  icon: Icons.history_rounded,
                  label: "Journaux d'Audit",
                  route: '/admin/settings/audit-logs',
                  isActive: location == '/admin/settings/audit-logs',
                ),
                _SidebarNavItem(
                  icon: Icons.tune_rounded,
                  label: 'Paramètres de Saison',
                  route: '/admin/settings',
                  isActive: location == '/admin/settings',
                ),
                _SidebarNavItem(
                  icon: Icons.manage_accounts_rounded,
                  label: 'Mon Profil & Sécurité',
                  route: '/admin/settings/account',
                  isActive: location == '/admin/settings/account',
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.surfaceBorder, height: 1),

          // Profil utilisateur & Déconnexion
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(AppRadii.card),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.green.withValues(alpha: 0.2),
                    child: Text(
                      session?.displayName.isNotEmpty == true
                          ? session!.displayName[0].toUpperCase()
                          : 'A',
                      style: const TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm + 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          session?.displayName.isNotEmpty == true
                              ? session!.displayName
                              : 'Administrateur',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          'Super Admin',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.textTertiary,
                      size: 18,
                    ),
                    tooltip: 'Se déconnecter',
                    onPressed: () =>
                        ref.read(sessionControllerProvider.notifier).logout(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarSectionTitle extends StatelessWidget {
  const _SidebarSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _SidebarNavItem extends StatefulWidget {
  const _SidebarNavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
    this.badgeCount,
  });

  final IconData icon;
  final String label;
  final String route;
  final bool isActive;
  final int? badgeCount;

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isActive;
    final backgroundColor = active
        ? AppColors.green.withValues(alpha: 0.15)
        : _isHovered
            ? AppColors.surfaceSubtle
            : Colors.transparent;

    final foregroundColor = active
        ? AppColors.green
        : _isHovered
            ? AppColors.textPrimary
            : AppColors.textSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppRadii.input),
            border: Border.all(
              color: active
                  ? AppColors.green.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: foregroundColor,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: foregroundColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.badgeCount != null && widget.badgeCount! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.badgeCount}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
