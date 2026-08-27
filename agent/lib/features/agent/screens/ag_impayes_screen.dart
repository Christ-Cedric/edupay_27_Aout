// =============================================================================
// FEATURES/AGENT/SCREENS/AG_IMPAYES_SCREEN.DART
// =============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/providers/agent_provider.dart';
import 'ag_dashboard_screen.dart';

class AgImpayesScreen extends StatelessWidget {
  const AgImpayesScreen({super.key});

  Future<void> _sendReminders(BuildContext context, List<String> phones) async {
    if (phones.isEmpty) {
      showEduToast(context, 'Aucun client en retard.');
      return;
    }
    final phonesList = phones
        .map((p) => p.replaceAll(' ', '').replaceAll('+', ''))
        .where((p) => p.isNotEmpty)
        .join(',');
    final message = Uri.encodeComponent('Bonjour, ceci est un rappel pour le règlement de votre cotisation EduPay. Merci !');
    final url = Uri.parse('sms:$phonesList?body=$message');
    try {
      await launchUrl(url);
    } catch (e) {
      if (context.mounted) {
        showEduToast(context, 'Impossible d\'ouvrir l\'application SMS', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final agentState = context.watch<AgentProvider>();
    final clients = agentState.clients.where((c) => c.isLate).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 1)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back,
                      color: AppColors.white70, size: 22),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Impayés à relancer',
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 22),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<AgentProvider>().loadClients(),
              color: AppColors.green,
              backgroundColor: AppColors.cardBg,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    // Alerte rouge
                    EduCard(
                      borderColor: const Color(0x4DE53935),
                      bgColor: const Color(0x1FE53935),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '⚠ ${clients.length} client(s) en retard de paiement',
                            style: GoogleFonts.openSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Contactez-les pour régulariser',
                            style: GoogleFonts.openSans(
                                fontSize: 10, color: AppColors.white50),
                          ),
                        ],
                      ),
                    ),

                    // Liste clients
                    if (clients.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(30),
                        child: Text(
                          'Aucun impayé ! Félicitations.',
                          style: GoogleFonts.openSans(color: AppColors.white50),
                        ),
                      )
                    else
                      ...clients.map((c) => Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom:
                                      BorderSide(color: AppColors.divider, width: 1)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.fullName,
                                        style: GoogleFonts.openSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.white,
                                        ),
                                      ),
                                      Text(
                                        'En retard de ${c.lateWeeks} sem.',
                                        style: GoogleFonts.openSans(
                                            fontSize: 10, color: AppColors.red),
                                      ),
                                    ],
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () async {
                                      final phone = c.phone.replaceAll(' ', '').replaceAll('+', '');
                                      final url = Uri.parse('tel:$phone');
                                      try {
                                        await launchUrl(url);
                                      } catch (e) {
                                        if (context.mounted) {
                                          showEduToast(context, 'Impossible de lancer l\'appel', isError: true);
                                        }
                                      }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(Icons.phone,
                                          color: AppColors.gold, size: 22),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    const SizedBox(height: 20),

                    EduButton.red(
                      '📢 Envoyer SMS de relance groupe',
                      onPressed: () => _sendReminders(context, clients.map((c) => c.phone).toList()),
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
          if (i == 0) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const AgDashboardScreen()));
          }
        },
      ),
    );
  }
}
