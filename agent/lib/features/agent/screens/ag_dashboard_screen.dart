// =============================================================================
// FEATURES/AGENT/SCREENS/AG_DASHBOARD_SCREEN.DART — Dashboard réel via API
// =============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/agent_provider.dart';
import 'ag_clients_screen.dart';
import 'ag_inscrire_screen.dart';
import 'ag_encaisser_screen.dart';
import 'ag_impayes_screen.dart';
import 'ag_notifications_screen.dart';
import 'ag_profil_screen.dart';

class AgDashboardScreen extends StatefulWidget {
  const AgDashboardScreen({super.key});

  @override
  State<AgDashboardScreen> createState() => _AgDashboardScreenState();
}

class _AgDashboardScreenState extends State<AgDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgentProvider>().loadDashboard();
      context.read<AgentProvider>().loadMyNotifications();
    });
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M FCFA';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k FCFA';
    }
    return '${amount.toStringAsFixed(0)} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final agentState = context.watch<AgentProvider>();
    final agent = auth.agent;
    final stats = agentState.dashboard;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header vert agent
          Container(
            color: AppColors.green,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'EduP@y — Agent',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.background,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AgNotificationsScreen()),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_outlined,
                          color: AppColors.background, size: 24),
                      if (agentState.unreadMyNotificationsCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.red,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.green, width: 1.5),
                            ),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              '${agentState.unreadMyNotificationsCount}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppColors.white, fontSize: 9, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contenu scrollable
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<AgentProvider>().loadDashboard(),
              color: AppColors.green,
              backgroundColor: AppColors.cardBg,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Salutation dynamique
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, 
                            fontSize: 11, color: AppColors.white50),
                        children: [
                          const TextSpan(text: 'Bonjour '),
                          TextSpan(
                            text: agent?.fullName ?? '...',
                            style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                              text:
                                  ' — ${agent?.zone ?? ''}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // KPI Grid
                    if (agentState.isLoadingDashboard)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                              color: AppColors.green),
                        ),
                      )
                    else
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.8,
                        children: [
                          KpiCard(
                            value: '${stats?['clients']?['active'] ?? 0}',
                            label: 'Clients actifs',
                          ),
                          KpiCard(
                            value: '${stats?['clients']?['newThisMonth'] ?? 0}',
                            label: 'Inscriptions ce mois',
                            valueColor: AppColors.green,
                          ),
                          KpiCard(
                            value: stats != null
                                ? _formatAmount(double.tryParse(stats['collections']?['amountThisMonth']?.toString() ?? '0') ?? 0)
                                : '0F',
                            label: 'Collectes ce mois',
                          ),
                          KpiCard(
                            value: '${stats?['impayes']?['count'] ?? 0}',
                            label: 'Impayés',
                            valueColor: (int.tryParse(stats?['impayes']?['count']?.toString() ?? '0') ?? 0) > 0
                                ? AppColors.red
                                : AppColors.white,
                          ),
                        ],
                      ),
                    const SizedBox(height: 14),

                    const SectionLabel('ACTIONS RAPIDES'),
                    EduButton.green(
                      '+ Inscrire une famille',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AgInscrireScreen()),
                      ),
                    ),
                    const SizedBox(height: 8),
                    EduButton.yellow(
                      '💵 Encaisser une cotisation',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AgEncaisserScreen()),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Alerte impayés (dynamique)
                    if ((int.tryParse(stats?['impayes']?['count']?.toString() ?? '0') ?? 0) > 0)
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AgImpayesScreen()),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0x1FE53935),
                            border: Border.all(
                                color: const Color(0x4DE53935), width: 1),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Center(
                            child: Text(
                              '⚠ Relancer les impayés (${stats?['impayes']?['count'] ?? 0})',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AgentBottomNav(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const AgClientsScreen()));
          } else if (i == 2) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const AgEncaisserScreen()));
          } else if (i == 3) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const AgProfilScreen()));
          }
        },
      ),
    );
  }
}
