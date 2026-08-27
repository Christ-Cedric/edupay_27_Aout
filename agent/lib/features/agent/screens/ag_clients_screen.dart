// =============================================================================
// FEATURES/AGENT/SCREENS/AG_CLIENTS_SCREEN.DART — Liste clients via API
// =============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/providers/agent_provider.dart';
import '../../../core/models/client_model.dart';
import 'ag_dashboard_screen.dart';
import 'ag_fiche_client_screen.dart';
import 'ag_inscrire_screen.dart';
import 'ag_encaisser_screen.dart';
import 'ag_profil_screen.dart';

class AgClientsScreen extends StatefulWidget {
  const AgClientsScreen({super.key});

  @override
  State<AgClientsScreen> createState() => _AgClientsScreenState();
}

class _AgClientsScreenState extends State<AgClientsScreen> {
  String _searchQuery = '';
  String _activeFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgentProvider>().loadClients();
    });
  }

  List<ClientModel> get _filtered {
    final agentState = context.read<AgentProvider>();
    var list = agentState.clients;

    if (_searchQuery.isNotEmpty) {
      list = list
          .where((c) =>
              c.fullName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              c.phone.contains(_searchQuery))
          .toList();
    }

    if (_activeFilter == 'LATE') {
      list = list.where((c) => c.isLate).toList();
    } else if (_activeFilter == 'COMPLETED') {
      list = list.where((c) => c.isCompleted).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final agentState = context.watch<AgentProvider>();
    final all = agentState.clients;
    final lateCount = all.where((c) => c.isLate).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border:
                  Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                Text(
                  'Mes Clients',
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const AgInscrireScreen())),
                  child: const Icon(Icons.add, color: AppColors.gold, size: 24),
                ),
              ],
            ),
          ),

          // Contenu
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<AgentProvider>().loadClients(),
              color: AppColors.green,
              backgroundColor: AppColors.cardBg,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barre de recherche
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.white07,
                        border:
                            Border.all(color: AppColors.borderDefault),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(Icons.search,
                                color: AppColors.white50, size: 18),
                          ),
                          Expanded(
                            child: TextField(
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                              style: GoogleFonts.openSans(
                                  fontSize: 12, color: AppColors.white),
                              decoration: InputDecoration(
                                hintText: 'Rechercher un client...',
                                hintStyle: GoogleFonts.openSans(
                                    fontSize: 12,
                                    color: AppColors.white50),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Filtres
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              setState(() => _activeFilter = 'ALL'),
                          child: StatusTag.green(
                              'Tous (${all.length})'),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _activeFilter = 'LATE'),
                          child:
                              StatusTag.red('Impayés ($lateCount)'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Loader
                    if (agentState.isLoadingClients)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(30),
                          child: CircularProgressIndicator(
                              color: AppColors.green),
                        ),
                      )
                    else if (_filtered.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: Text(
                            'Aucun client trouvé',
                            style: GoogleFonts.openSans(
                                color: AppColors.white50),
                          ),
                        ),
                      )
                    else
                      ..._filtered.map(
                        (client) => _ClientItem(
                          client: client,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AgFicheClientScreen(client: client),
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
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(
                    builder: (_) => const AgDashboardScreen()));
          } else if (i == 2) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(
                    builder: (_) => const AgEncaisserScreen()));
          } else if (i == 3) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const AgProfilScreen()));
          }
        },
      ),
    );
  }
}

class _ClientItem extends StatelessWidget {
  final ClientModel client;
  final VoidCallback onTap;

  const _ClientItem({required this.client, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLate = client.isLate;
    final balance = client.balance;
    final goal = client.targetAmount;

    String info;
    if (isLate) {
      info = 'Plan ${client.plan} — en retard ${client.lateWeeks} sem.';
    } else if (client.isCompleted) {
      info = 'Plan ${client.plan} — 100% ✓';
    } else {
      info = 'Plan ${client.plan} — ${balance.toStringAsFixed(0)}F / ${goal.toStringAsFixed(0)}F';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(color: AppColors.divider, width: 1)),
          ),
          child: Row(
            children: [
              InitialsAvatar(
                initials: client.initials,
                size: 32,
                backgroundColor: isLate ? AppColors.red : AppColors.green,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.fullName,
                      style: GoogleFonts.openSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      info,
                      style: GoogleFonts.openSans(
                          fontSize: 10, color: AppColors.white50),
                    ),
                  ],
                ),
              ),
              isLate
                  ? StatusTag.red('⚠')
                  : client.isCompleted
                      ? StatusTag.blue('Complet')
                      : StatusTag.green('Actif'),
            ],
          ),
        ),
      ),
    );
  }
}
