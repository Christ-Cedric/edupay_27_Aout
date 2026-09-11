// =============================================================================
// FEATURES/AGENT/SCREENS/AG_PROFIL_SCREEN.DART
// =============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_client.dart';
import 'ag_dashboard_screen.dart';
import 'ag_clients_screen.dart';
import 'ag_encaisser_screen.dart';
import 'ag_rapport_screen.dart';
import 'ag_login_screen.dart';
import 'ag_qr_scanner_screen.dart';

class AgProfilScreen extends StatefulWidget {
  const AgProfilScreen({super.key});

  @override
  State<AgProfilScreen> createState() => _AgProfilScreenState();
}

class _AgProfilScreenState extends State<AgProfilScreen> {
  Map<String, dynamic>? _commissions;
  bool _isLoading = false;
  // `true` uniquement si le dernier chargement a échoué — distingue « pas
  // encore chargé »/« vraiment à 0 » d'un échec réseau, pour ne jamais
  // laisser l'agent croire qu'il n'a touché aucune commission alors que la
  // donnée n'a simplement pas pu être récupérée.
  bool _loadError = false;

  @override
  void initState() {
    super.initState();
    _loadCommissions();
  }

  Future<void> _loadCommissions() async {
    setState(() {
      _isLoading = true;
      _loadError = false;
    });
    try {
      // NB: `/agent/me/commissions` renvoie une LISTE de commissions
      // individuelles ({data: [...]}), pas un agrégat — on réutilise plutôt
      // `/agent/me/dashboard`, qui calcule déjà ce mois/mois dernier/saison
      // côté serveur (`agent.service.ts::getDashboard`).
      final response = await ApiClient.get('/agent/me/dashboard');
      final commissions = (response['data'] as Map<String, dynamic>)['commissions'] as Map<String, dynamic>;
      setState(() => _commissions = {
        'thisMonth': commissions['this_month'],
        'lastMonth': commissions['last_month'],
        'total': commissions['total_season'],
      });
    } catch (_) {
      setState(() {
        _commissions = null;
        _loadError = true;
      });
      if (mounted) {
        showEduToast(context, 'Impossible de charger vos commissions', isError: true);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final agent = auth.agent;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header EduPay Logo
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 1)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [EduPayLogo(fontSize: 18)],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadCommissions,
              color: AppColors.green,
              backgroundColor: AppColors.cardBg,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    // Avatar centré
                    Column(
                      children: [
                        InitialsAvatar(
                          initials: agent?.initials ?? '??',
                          size: 52,
                          backgroundColor: AppColors.gold,
                          textColor: AppColors.background,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          agent?.fullName ?? 'Utilisateur Inconnu',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          'Agent terrain — ${agent?.zone ?? ''}',
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, 
                              fontSize: 10, color: AppColors.white50),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Commissions
                    const SectionLabel('MES COMMISSIONS'),
                    if (_isLoading)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: AppColors.green),
                      ))
                    else
                      EduCard(
                        child: Column(
                          children: [
                            if (_loadError)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: AppColors.red, size: 16),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Données indisponibles — tirez pour réessayer',
                                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            EduDataRow(
                                label: 'Ce mois',
                                value: _loadError ? '—' : '${_commissions?['thisMonth'] ?? 0} FCFA',
                                valueColor: AppColors.gold),
                            EduDataRow(
                                label: 'Mois dernier',
                                value: _loadError ? '—' : '${_commissions?['lastMonth'] ?? 0} FCFA'),
                            EduDataRow(
                                label: 'Total saison',
                                value: _loadError ? '—' : '${_commissions?['total'] ?? 0} FCFA',
                                valueColor: AppColors.green,
                                showDivider: false),
                          ],
                        ),
                      ),

                    const EduDivider(),

                    // ── SCANNER QR ── bouton principal premium
                    _qrScannerMenuItem(),

                    const EduDivider(),

                    // Menu items
                    _menuItem(
                      'Rapport hebdomadaire',
                      color: AppColors.gold,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AgRapportScreen()),
                      ),
                    ),
                    _menuItem(
                      'Contacter le directeur',
                      color: AppColors.gold,
                      onTap: () => _showContactOptions(context),
                    ),
                    _menuItem(
                      'Déconnexion',
                      color: AppColors.white35,
                      onTap: () async {
                        await auth.logout(context);
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const AgLoginScreen()),
                            (route) => false,
                          );
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
          } else if (i == 1) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const AgClientsScreen()));
          } else if (i == 2) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const AgEncaisserScreen()));
          }
        },
      ),
    );
  }

  Widget _qrScannerMenuItem() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AgQrScannerScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.green.withValues(alpha: 0.15),
              AppColors.green.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.green.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icône scanner
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.green, Color(0xFF00897B)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.green.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Scanner QR Client',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'NOUVEAU',
                          style: GoogleFonts.montserrat(
                            fontSize: 7,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Scanner la carte du client pour encaisser',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, 
                        fontSize: 10, color: AppColors.white50),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: AppColors.green, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(String label,
      {required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border:
              Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, 
                  fontSize: 12, color: AppColors.white70),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 14),
          ],
        ),
      ),
    );
  }


  void _showContactOptions(BuildContext context) async {
    showEduToast(context, 'Chargement des contacts...');
    try {
      final response = await ApiClient.get('/agent/me/contact-director');
      final data = response['data'];
      
      if (!context.mounted) return;
      
      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.cardBg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contacter le directeur',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.chat, color: AppColors.green),
                  title: Text('Message WhatsApp', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: AppColors.white)),
                  onTap: () async {
                    Navigator.pop(context);
                    final String? whatsappUrl = data['whatsapp_url'];
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
                  },
                ),
                const Divider(color: AppColors.divider),
                ListTile(
                  leading: const Icon(Icons.phone, color: AppColors.gold),
                  title: Text('Appel direct', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: AppColors.white)),
                  onTap: () async {
                    Navigator.pop(context);
                    final String? phoneNumber = data['phone_number'];
                    if (phoneNumber == null || phoneNumber.isEmpty) {
                      if (context.mounted) showEduToast(context, 'Numéro du directeur non configuré', isError: true);
                      return;
                    }
                    final url = Uri.parse('tel:$phoneNumber');
                    try {
                      await launchUrl(url);
                    } catch (e) {
                      if (context.mounted) showEduToast(context, 'Impossible de lancer l\'appel', isError: true);
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (context.mounted) {
        final msg = e is ApiException ? e.message : 'Erreur réseau';
        showEduToast(context, 'Erreur de chargement: $msg', isError: true);
      }
    }
  }
}
