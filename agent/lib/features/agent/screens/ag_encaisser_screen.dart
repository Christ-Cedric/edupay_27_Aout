// =============================================================================
// FEATURES/AGENT/SCREENS/AG_ENCAISSER_SCREEN.DART
// =============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/providers/agent_provider.dart';
import '../../../core/models/client_model.dart';
import '../../../core/services/api_client.dart';
import 'ag_recu_screen.dart';
import 'ag_dashboard_screen.dart';
import 'ag_livraisons_screen.dart';
import 'ag_clients_screen.dart';
import 'ag_profil_screen.dart';

class AgEncaisserScreen extends StatefulWidget {
  final ClientModel? preselectedClient;
  const AgEncaisserScreen({super.key, this.preselectedClient});

  @override
  State<AgEncaisserScreen> createState() => _AgEncaisserScreenState();
}

class _AgEncaisserScreenState extends State<AgEncaisserScreen> {
  String _modeCollecte = 'CASH';
  ClientModel? _selectedClient;
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _modes = [
    {'id': 'CASH', 'bg': AppColors.green, 'ico': '💵', 'label': 'Espèces en main', 'textDark': true},
  ];

  @override
  void initState() {
    super.initState();
    _selectedClient = widget.preselectedClient;
    // We no longer have a fixed savingPlan amount, the agent will manually enter the amount.

    // Charger les clients de l'agent si pas encore chargés
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final agentState = context.read<AgentProvider>();
      if (agentState.clients.isEmpty) {
        agentState.loadClients();
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitCotisation() async {
    if (_selectedClient == null) {
      showEduToast(context, 'Veuillez sélectionner un client', isError: true);
      return;
    }

    final amountStr = _amountController.text.trim();
    final amount = double.tryParse(amountStr);

    if (amount == null || amount <= 0) {
      showEduToast(context, 'Montant invalide', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.post('/agent/me/families/${_selectedClient!.id}/contributions', {
        'amount': amount,
      });

      if (!mounted) return;

      // Rafraîchir les données du dashboard
      context.read<AgentProvider>().loadDashboard();

      // Vérifier si l'objectif est atteint (livraison auto-créée)
      final data = response['data'];
      final bool objectifAtteint = data?['isObjectifAtteint'] == true;
      final livraisonCreee = data?['livraisonCreee'];

      if (objectifAtteint && livraisonCreee != null) {
        // Rafraîchir les livraisons
        context.read<AgentProvider>().loadLivraisons();
        // Afficher le dialogue de félicitations
        await _showObjectifAtteintDialog(livraisonCreee);
      } else {
        showEduToast(context, 'Encaissement validé avec succès');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AgRecuScreen(
              modeCollecte: _modeCollecte,
              clientName: _selectedClient!.fullName,
              amount: amount,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errMsg = e is ApiException ? e.message : e.toString();
        showEduToast(context, 'Erreur: $errMsg', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Dialogue premium affiché quand l'objectif d'épargne est atteint
  Future<void> _showObjectifAtteintDialog(Map<String, dynamic> livraison) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.green.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: AppColors.green.withOpacity(0.15),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône succès animée
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.green, width: 2),
                ),
                child: const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Épargne Complète !',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                '${_selectedClient?.fullName ?? 'Le client'} a atteint son objectif d\'épargne.',
                style: GoogleFonts.openSans(
                  fontSize: 12,
                  color: AppColors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Badge livraison créée
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.white05,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Column(
                  children: [
                    const Text('📦', style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(
                      'Une livraison a été créée automatiquement',
                      style: GoogleFonts.openSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Réf: ${livraison['reference'] ?? ''}',
                      style: GoogleFonts.openSans(
                        fontSize: 10,
                        color: AppColors.white50,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Info notification
              Text(
                '💬 Le client a été notifié par WhatsApp',
                style: GoogleFonts.openSans(
                  fontSize: 10,
                  color: AppColors.white50,
                ),
              ),
              const SizedBox(height: 20),

              // Boutons
              EduButton.green(
                '📦 Voir les livraisons du jour',
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AgLivraisonsScreen()),
                  );
                },
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AgRecuScreen(
                        modeCollecte: _modeCollecte,
                        clientName: _selectedClient!.fullName,
                        amount: double.tryParse(
                              _amountController.text.trim(),
                            ) ??
                            0,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Voir le reçu',
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    color: AppColors.white50,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final agentState = context.watch<AgentProvider>();
    final clients = agentState.clients;

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
                      'Encaisser',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sélecteur de client
                  GestureDetector(
                    onTap: () => _showClientSelector(clients),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.white05,
                        border: Border.all(color: AppColors.borderDefault),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          InitialsAvatar(
                            initials: _selectedClient == null ? '?' : _selectedClient!.initials,
                            size: 32,
                            backgroundColor: _selectedClient == null ? AppColors.gold : AppColors.green,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedClient == null ? 'Sélectionner un client' : _selectedClient!.fullName,
                                  style: GoogleFonts.openSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                  ),
                                ),
                                Text(
                                  _selectedClient == null ? 'Appuyez pour choisir' : 'Plan ${_selectedClient!.plan}',
                                  style: GoogleFonts.openSans(
                                      fontSize: 10, color: AppColors.white50),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: AppColors.white50),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Montant
                  EduCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Montant à encaisser (FCFA)',
                          style: GoogleFonts.openSans(
                              fontSize: 10, color: AppColors.white50),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gold,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: TextStyle(color: AppColors.white10),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SectionLabel('MODE DE COLLECTE'),

                  ..._modes.map((mode) {
                    final isSelected = _modeCollecte == mode['id'];
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _modeCollecte = mode['id'] as String),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 11),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0x0F00C853)
                              : AppColors.white05,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.green
                                : AppColors.borderDefault,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: mode['bg'] as Color,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Center(
                                child: Text(
                                  mode['ico'] as String,
                                  style: GoogleFonts.openSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: (mode['textDark'] as bool)
                                        ? AppColors.background
                                        : AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                mode['label'] as String,
                                style: GoogleFonts.openSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  color: AppColors.green, size: 18),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(color: AppColors.green),
                    )
                  else
                    EduButton.green(
                      'Valider l\'encaissement',
                      onPressed: _submitCotisation,
                    ),
                  const SizedBox(height: 8),
                  EduButton.outlined(
                    '📦 Voir les livraisons du jour',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AgLivraisonsScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Le client est notifié automatiquement par WhatsApp',
                      style: GoogleFonts.openSans(
                          fontSize: 10, color: AppColors.white35),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AgentBottomNav(
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const AgDashboardScreen()));
          } else if (i == 1) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const AgClientsScreen()));
          } else if (i == 3) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const AgProfilScreen()));
          }
        },
      ),
    );
  }

  void _showClientSelector(List<ClientModel> clients) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Sélectionner un client',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ...clients.map((client) => ListTile(
                        leading: InitialsAvatar(
                            initials: client.initials, size: 36),
                        title: Text(client.fullName,
                            style: GoogleFonts.openSans(
                                color: AppColors.white)),
                        subtitle: Text(
                            'Plan ${client.plan}',
                            style: GoogleFonts.openSans(
                                color: AppColors.white50, fontSize: 10)),
                        onTap: () {
                          setState(() {
                            _selectedClient = client;
                            final remaining = client.targetAmount - client.balance;
                            _amountController.text = remaining > 0 ? remaining.toInt().toString() : '0';
                          });
                          Navigator.pop(context);
                        },
                      )),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
