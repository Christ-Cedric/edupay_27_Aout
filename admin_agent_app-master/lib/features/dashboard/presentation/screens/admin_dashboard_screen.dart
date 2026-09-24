import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/app_toast.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../domain/models/dashboard_alert.dart';
import '../../domain/models/dashboard_summary.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/dashboard_alerts_section.dart';
import '../widgets/dashboard_kpi_section.dart';

import 'admin_desktop_dashboard_view.dart';

/// Numéro WhatsApp du support (même contact que "Message WhatsApp" côté
/// profil agent) — pas de canal support dédié distinct dans ce projet.
const _supportWhatsAppNumber = '22656095425';

/// Tableau de bord Admin (motif `ad_d` du prototype) — en-tête vert
/// distinctif propre aux écrans d'accueil Admin/Agent (`.ah` dans le CSS
/// source), à la différence du header navy standard utilisé ailleurs.
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  DateTime? _lastUpdated;

  Future<void> _refresh() async {
    ref.invalidate(dashboardSummaryProvider);
    await ref.read(dashboardSummaryProvider.future);
  }

  Future<void> _contactSupport() async {
    final url = Uri.parse('https://wa.me/$_supportWhatsAppNumber');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        showAppToast(
          context,
          "Impossible d'ouvrir WhatsApp",
          type: AppToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Le dashboard ne se recharge jamais tout seul une fois affiché (l'onglet
    // reste vivant dans l'`IndexedStack` de l'AdminShell) — on retient donc
    // l'heure du dernier chargement réussi pour l'afficher, seul repère que
    // l'admin a pour juger si ce qu'il voit est encore frais.
    ref.listen(dashboardSummaryProvider, (previous, next) {
      if (next.hasValue) setState(() => _lastUpdated = DateTime.now());
    });
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final unreadNotifications = ref
            .watch(notificationsListProvider)
            .value
            ?.where((n) => !n.isRead)
            .length ??
        0;

    final isDesktop = MediaQuery.sizeOf(context).width >= 960;

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: isDesktop
          ? null
          : AppHeader(
              title: 'Admin - EduP@y',
              backgroundColor: AppColors.green,
              foregroundColor: AppColors.navy,
              trailing: IconButton(
                icon: _NotificationBellIcon(unreadCount: unreadNotifications),
                onPressed: () => context.push('/admin/dashboard/notifications'),
              ),
            ),
      body: summaryAsync.when(
        data: (summary) => isDesktop
            ? AdminDesktopDashboardView(
                summary: summary,
                lastUpdated: _lastUpdated,
                onRefresh: _refresh,
              )
            : RefreshIndicator(
                onRefresh: _refresh,
                child: _DashboardBody(summary: summary, lastUpdated: _lastUpdated),
              ),
        loading: () => const LoadingScreen(),
        error: (error, stackTrace) => ErrorScreen(
          onRetry: () => ref.invalidate(dashboardSummaryProvider),
          onContactSupport: _contactSupport,
        ),
      ),
    );
  }
}

/// Icône de notifications avec badge de compteur non-lu (harmonisée avec les
/// apps agent/client).
class _NotificationBellIcon extends StatelessWidget {
  const _NotificationBellIcon({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_outlined, color: AppColors.navy, size: 18),
        if (unreadCount > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.summary, required this.lastUpdated});

  final DashboardSummary summary;
  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      // Requis par RefreshIndicator pour rester "tirable" même quand le
      // contenu est plus court que le viewport.
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        InkWell(
          onTap: () => context.push('/admin/settings'),
          child: Text(
            summary.season.isEmpty ? 'Saison' : 'Saison ${summary.season}',
            style: AppTextStyles.caption,
          ),
        ),
        if (lastUpdated != null) ...[
          const SizedBox(height: 2),
          Text(
            'Mis à jour à ${DateFormat.Hm().format(lastUpdated!)}',
            style: AppTextStyles.caption,
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        DashboardKpiSection(
          summary: summary,
          onFamiliesTap: () => context.push('/admin/families'),
          onFinancesTap: () => context.push('/admin/finances'),
          onOverdueTap: () => context.push('/admin/dashboard/alerts'),
          onAgentsTap: () => context.push('/admin/settings/agents'),
          onDeliveriesTap: () => context.push('/admin/finances/deliveries'),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text('ALERTES', style: AppTextStyles.sectionLabel),
        const SizedBox(height: AppSpacing.sm),
        DashboardAlertsSection(
          alerts: summary.alerts,
          // Chaque carte navigue vers l'écran pertinent, quel que soit son
          // niveau de gravité — routage par `kind` (identifiant stable),
          // jamais par le texte affiché.
          onAlertTap: (alert) {
            switch (alert.kind) {
              case DashboardAlertKind.pendingValidation:
                context.push('/admin/families/pending');
              case DashboardAlertKind.overduePayments:
                context.push('/admin/dashboard/alerts');
              case DashboardAlertKind.pendingDeliveries:
                context.push('/admin/finances/deliveries');
              case DashboardAlertKind.seasonProgress:
                context.push('/admin/settings');
              case DashboardAlertKind.other:
                break;
            }
          },
        ),
      ],
    );
  }
}
