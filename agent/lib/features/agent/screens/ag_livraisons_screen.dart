// =============================================================================
// FEATURES/AGENT/SCREENS/AG_LIVRAISONS_SCREEN.DART
// =============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/agent_provider.dart';
import '../../../core/models/livraison_model.dart';
import 'ag_bon_livraison_screen.dart';
import 'package:intl/intl.dart';

class AgLivraisonsScreen extends StatefulWidget {
  const AgLivraisonsScreen({super.key});

  @override
  State<AgLivraisonsScreen> createState() => _AgLivraisonsScreenState();
}

class _AgLivraisonsScreenState extends State<AgLivraisonsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgentProvider>().loadLivraisons();
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE d MMM yyyy', 'fr_FR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final agentState = context.watch<AgentProvider>();
    final livraisons = agentState.livraisons;
    final isLoading = agentState.isLoadingLivraisons;

    final deliveredCount = livraisons.where((l) => l.isDelivered).length;
    final pendingCount = livraisons.where((l) => l.isPending).length;
    final totalCount = livraisons.length;

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
                      'Livraisons du jour',
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                // Badge nombre en attente
                if (pendingCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                    ),
                    child: Text(
                      '$pendingCount en attente',
                      style: GoogleFonts.openSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 22),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<AgentProvider>().loadLivraisons(),
              color: AppColors.green,
              backgroundColor: AppColors.cardBg,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(DateTime.now()).toUpperCase(),
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$deliveredCount livraison${deliveredCount > 1 ? 's' : ''} sur $totalCount terminée${deliveredCount > 1 ? 's' : ''}',
                      style: GoogleFonts.openSans(
                          fontSize: 11, color: AppColors.white50),
                    ),
                    const SizedBox(height: 20),

                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(color: AppColors.green),
                        ),
                      )
                    else if (livraisons.isEmpty)
                      _buildEmptyState()
                    else
                      ...livraisons.map((livraison) => _buildLivraisonCard(livraison)),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Text('📦', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Aucune livraison prévue aujourd\'hui',
              style: GoogleFonts.openSans(
                color: AppColors.white50,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Les livraisons apparaîtront automatiquement\nquand un client atteint son objectif d\'épargne.',
              style: GoogleFonts.openSans(
                color: AppColors.white35,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivraisonCard(LivraisonModel livraison) {
    final isDelivered = livraison.isDelivered;

    return GestureDetector(
      onTap: () async {
        final navigator = Navigator.of(context);
        final provider = context.read<AgentProvider>();
        final result = await navigator.push(
          MaterialPageRoute(
            builder: (_) => AgBonLivraisonScreen(livraisonId: livraison.id),
          ),
        );
        if (result == true) {
          provider.loadLivraisons();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDelivered ? const Color(0x0A00C853) : AppColors.cardBg,
          border: Border.all(
            color: isDelivered
                ? const Color(0x3300C853)
                : AppColors.borderDefault,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Icône statut
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDelivered
                          ? AppColors.green
                          : AppColors.white07,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDelivered ? Icons.check : Icons.local_shipping,
                      color: isDelivered
                          ? AppColors.background
                          : AppColors.white70,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Infos client
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          livraison.clientFullName ?? 'Client inconnu',
                          style: GoogleFonts.openSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        if (livraison.childFirstName != null &&
                            livraison.childFirstName!.isNotEmpty)
                          Text(
                            '👦 ${livraison.childFirstName}',
                            style: GoogleFonts.openSans(
                              fontSize: 10,
                              color: AppColors.white50,
                            ),
                          ),
                        if (livraison.childSchool != null &&
                            livraison.childSchool!.isNotEmpty)
                          Text(
                            '🏫 ${livraison.childSchool}',
                            style: GoogleFonts.openSans(
                              fontSize: 10,
                              color: AppColors.white35,
                            ),
                          )
                        else
                          Text(
                            'Réf: ${livraison.reference}',
                            style: GoogleFonts.openSans(
                              fontSize: 10,
                              color: AppColors.white50,
                            ),
                          ),
                      ],
                    ),
                  ),

                  Icon(
                    Icons.arrow_forward_ios,
                    color: isDelivered ? AppColors.green : AppColors.white35,
                    size: 14,
                  ),
                ],
              ),
            ),

            // Badge statut textuel en bas de carte
            if (!isDelivered)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.06),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.gold.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Text(
                  livraison.statusLabel,
                  style: GoogleFonts.openSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            if (isDelivered)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  border: Border(
                    top: BorderSide(color: AppColors.green.withOpacity(0.2)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '✅ Kit livré — Client notifié',
                      style: GoogleFonts.openSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
