import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import 'ag_dashboard_screen.dart';
import 'ag_profil_screen.dart';

String _money(num amount) {
  final s = amount.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(s[i]);
  }
  return '${buffer}F';
}

class AgRapportScreen extends StatefulWidget {
  const AgRapportScreen({super.key});

  @override
  State<AgRapportScreen> createState() => _AgRapportScreenState();
}

class _AgRapportScreenState extends State<AgRapportScreen> {
  bool _isLoading = true;
  bool _loadError = false;
  Map<String, dynamic>? _dashboard;
  int _contributionsThisMonth = 0;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  /// Récapitulatif du mois en cours — construit à partir de données réelles
  /// (`/agent/me/dashboard` pour les agrégats, `/agent/me/contributions` pour
  /// le nombre de cotisations). Pas de cadence hebdomadaire ni de note de
  /// satisfaction côté backend : ces indicateurs (auparavant codés en dur)
  /// sont remplacés par des KPI réellement disponibles plutôt que simulés.
  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
      _loadError = false;
    });
    try {
      final dashboardResp = await ApiClient.get('/agent/me/dashboard');
      final dashboard = dashboardResp['data'] as Map<String, dynamic>;

      final contribResp = await ApiClient.get('/agent/me/contributions');
      final contributions = contribResp['data'] as List<dynamic>? ?? const [];
      final now = DateTime.now();
      final count = contributions.where((c) {
        final map = c as Map<String, dynamic>;
        if (map['status'] != 'confirmed') return false;
        final createdAt = DateTime.tryParse(map['created_at'] as String? ?? '');
        return createdAt != null && createdAt.year == now.year && createdAt.month == now.month;
      }).length;

      setState(() {
        _dashboard = dashboard;
        _contributionsThisMonth = count;
      });
    } catch (_) {
      setState(() => _loadError = true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commissions = _dashboard?['commissions'] as Map<String, dynamic>?;
    final now = DateTime.now();
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header avec retour
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
                      'Mon rapport',
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.green))
                : RefreshIndicator(
                    onRefresh: _loadReportData,
                    color: AppColors.green,
                    backgroundColor: AppColors.cardBg,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_loadError)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: AppColors.red, size: 16),
                                  const SizedBox(width: 6),
                                  const Expanded(
                                    child: Text(
                                      'Données indisponibles — tirez pour réessayer',
                                      style: TextStyle(color: AppColors.red, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SectionLabel('RÉCAPITULATIF — ${months[now.month - 1].toUpperCase()} ${now.year}'),

                          // KPI grid
                          GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.8,
                            children: [
                              KpiCard(
                                  value: _loadError ? '—' : '${_dashboard?['new_this_month'] ?? 0}',
                                  label: 'Inscriptions'),
                              KpiCard(
                                  value: _loadError ? '—' : '$_contributionsThisMonth',
                                  label: 'Cotisations',
                                  valueColor: AppColors.green),
                              KpiCard(
                                  value: _loadError ? '—' : _money(_dashboard?['collected_this_month'] ?? 0),
                                  label: 'Montant total'),
                              KpiCard(
                                  value: _loadError ? '—' : _money(commissions?['this_month'] ?? 0),
                                  label: 'Commission',
                                  valueColor: AppColors.gold),
                            ],
                          ),
                          const SizedBox(height: 16),

                          const SectionLabel('SUIVI DU PORTEFEUILLE'),
                          EduCard(
                            child: Column(
                              children: [
                                EduDataRow(
                                    label: 'Clients actifs',
                                    value: _loadError ? '—' : '${_dashboard?['active_clients'] ?? 0}',
                                    valueColor: AppColors.green),
                                EduDataRow(
                                    label: 'Clients en retard',
                                    value: _loadError ? '—' : '${_dashboard?['late_count'] ?? 0}',
                                    valueColor: AppColors.gold,
                                    showDivider: false),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          EduButton.yellow(
                            'Envoyer le rapport',
                            onPressed: () async {
                              try {
                                showEduToast(context, 'Génération en cours...');
                                final response = await ApiClient.post('/agent/me/reports/send', {});
                                final String? whatsappUrl = response['data']['whatsapp_url'];
                                if (whatsappUrl == null || whatsappUrl.isEmpty) {
                                  if (context.mounted) showEduToast(context, 'Numéro du directeur non configuré', isError: true);
                                  return;
                                }
                                final url = Uri.parse(whatsappUrl);

                                try {
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                } catch (e) {
                                  if (context.mounted) showEduToast(context, 'Impossible d\'ouvrir WhatsApp', isError: true);
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  final msg = e is ApiException ? e.message : 'Erreur réseau';
                                  showEduToast(context, 'Erreur: $msg', isError: true);
                                }
                              }
                            },
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
        currentIndex: 3,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const AgDashboardScreen()));
          } else if (i == 3) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const AgProfilScreen()));
          }
        },
      ),
    );
  }
}
