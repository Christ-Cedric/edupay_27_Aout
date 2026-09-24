import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../features/dashboard/presentation/providers/dashboard_providers.dart';
import '../../../features/notifications/presentation/providers/notifications_providers.dart';

/// Barre supérieure pour l'environnement Web / Desktop d'EduP@y Admin.
///
/// Affiche la localisation courante, les actions directes et le profil.
class AdminDesktopHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AdminDesktopHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  String _resolveTitle(String location) {
    if (location.startsWith('/admin/dashboard/alerts')) return 'Alertes de retard & Impayés';
    if (location.startsWith('/admin/dashboard/notifications')) return 'Centre de notifications';
    if (location.startsWith('/admin/dashboard')) return 'Tableau de bord';
    if (location.startsWith('/admin/families/enroll')) return 'Nouvelle inscription';
    if (location.startsWith('/admin/families/pending')) return 'Validations en attente';
    if (location.startsWith('/admin/families')) return 'Gestion des Familles';
    if (location.startsWith('/admin/finances/reports')) return 'Rapports Financiers';
    if (location.startsWith('/admin/finances/refunds')) return 'Gestion des Remboursements';
    if (location.startsWith('/admin/finances/deliveries')) return 'Livraisons de Kits';
    if (location.startsWith('/admin/finances')) return 'Supervision Financière';
    if (location.startsWith('/admin/settings/agents')) return 'Équipe des Agents';
    if (location.startsWith('/admin/settings/kits/supplies')) return 'Fournitures scolaires';
    if (location.startsWith('/admin/settings/kits/stats')) return 'Statistiques des Kits';
    if (location.startsWith('/admin/settings/kits')) return 'Catalogue des Kits';
    if (location.startsWith('/admin/settings/seasons')) return 'Saisons Scolaires';
    if (location.startsWith('/admin/settings/audit-logs')) return "Journaux d'Audit";
    if (location.startsWith('/admin/settings/account')) return 'Mon Profil & Sécurité';
    if (location.startsWith('/admin/settings')) return 'Paramètres du Système';
    return 'Administration';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final pageTitle = _resolveTitle(location);
    final session = ref.watch(sessionControllerProvider).value;
    final unreadNotifications = ref
            .watch(notificationsListProvider)
            .value
            ?.where((n) => !n.isRead)
            .length ??
        0;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceBorder),
        ),
      ),
      child: Row(
        children: [
          // Titre de la page active avec icône
          Text(
            pageTitle,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),

          const Spacer(),

          // Bouton d'actualisation rapide des données
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 20),
            tooltip: 'Actualiser les données',
            onPressed: () {
              ref.invalidate(dashboardSummaryProvider);
              ref.invalidate(notificationsListProvider);
            },
          ),

          const SizedBox(width: AppSpacing.sm),

          // Bouton notification avec badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                tooltip: 'Notifications',
                onPressed: () => context.go('/admin/dashboard/notifications'),
              ),
              if (unreadNotifications > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      unreadNotifications > 9 ? '9+' : '$unreadNotifications',
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
          ),

          const SizedBox(width: AppSpacing.md),

          // Action rapide : Nouvelle inscription
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: AppColors.navy,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.card),
              ),
            ),
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
            label: const Text(
              'Nouvelle Inscription',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
            onPressed: () => context.go('/admin/families/enroll'),
          ),

          const SizedBox(width: AppSpacing.lg),
          const VerticalDivider(
            color: AppColors.surfaceBorder,
            indent: 14,
            endIndent: 14,
            width: 1,
          ),
          const SizedBox(width: AppSpacing.lg),

          // Puce profil admin
          InkWell(
            onTap: () => context.go('/admin/settings/account'),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.gold.withValues(alpha: 0.2),
                    child: Text(
                      session?.displayName.isNotEmpty == true
                          ? session!.displayName[0].toUpperCase()
                          : 'A',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    session?.displayName.isNotEmpty == true
                        ? session!.displayName
                        : 'Admin',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppColors.textTertiary,
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
