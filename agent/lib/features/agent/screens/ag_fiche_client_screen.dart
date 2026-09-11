import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/models/client_model.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/services/api_client.dart';
import '../../../core/providers/agent_provider.dart';
import 'ag_encaisser_screen.dart';
import 'ag_qr_code_client_screen.dart';
import 'ag_personnaliser_kit_screen.dart';
import 'ag_scolarite_screen.dart';
import 'ag_transport_screen.dart';

class AgFicheClientScreen extends StatefulWidget {
  final ClientModel client;
  const AgFicheClientScreen({super.key, required this.client});

  @override
  State<AgFicheClientScreen> createState() => _AgFicheClientScreenState();
}

class _AgFicheClientScreenState extends State<AgFicheClientScreen> {
  late ClientModel _client;
  List<dynamic> _savingPlans = [];

  @override
  void initState() {
    super.initState();
    _client = widget.client;
    // Charger les notifications au chargement de la fiche
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgentProvider>().loadNotifications(_client.id);
    });
    _loadSavingPlans();
  }

  Future<void> _loadSavingPlans() async {
    try {
      final response = await ApiClient.get('/catalog/kits');
      if (mounted) setState(() => _savingPlans = response['data'] as List<dynamic>);
    } catch (e) {
      if (mounted) showEduToast(context, 'Impossible de charger les kits d\'épargne', isError: true);
    }
  }

  Future<void> _refreshClient() async {
    try {
      final response = await ApiClient.get('/agent/me/families/${_client.id}');
      final newClient = ClientModel.fromJson(response['data']);
      if (mounted) {
        setState(() => _client = newClient);
      }
      if (mounted) {
        context.read<AgentProvider>().loadClients();
        context.read<AgentProvider>().loadDashboard();
      }
    } catch (e) {
      if (mounted) showEduToast(context, 'Erreur lors du rafraîchissement', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = _client;
    final balance = client.balance;
    final targetAmount = client.targetAmount;
    final progress =
        targetAmount > 0 ? (balance / targetAmount).clamp(0.0, 1.0) : 0.0;

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
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back,
                      color: AppColors.white70, size: 22),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Fiche Famille',
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
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info client
                  Row(
                    children: [
                      InitialsAvatar(
                        initials: client.initials,
                        size: 44,
                        backgroundColor:
                            client.isCompleted ? AppColors.green : client.isLate ? AppColors.red : AppColors.green,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.fullName,
                            style: GoogleFonts.openSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                          Text(
                            '${client.phone} — ${client.city}',
                            style: GoogleFonts.openSans(
                                fontSize: 10, color: AppColors.white50),
                          ),
                          if (client.familyCode != null && client.familyCode!.isNotEmpty)
                            Text(
                              client.familyCode!,
                              style: GoogleFonts.openSans(
                                  fontSize: 9,
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w700),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Badge épargne complète
                  if (client.isCompleted)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: AppColors.green.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🎉 ', style: TextStyle(fontSize: 14)),
                          Text(
                            'Épargne complète — Kit(s) livrable(s)',
                            style: GoogleFonts.openSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Carte données épargne
                  EduCard(
                    child: Column(
                      children: [
                        EduDataRow(
                          label: 'Montant cotis.',
                          value: '${balance.toStringAsFixed(0)} FCFA',
                          valueColor: AppColors.gold,
                        ),
                        EduDataRow(
                            label: 'Objectif Global',
                            value: '${targetAmount.toStringAsFixed(0)} FCFA'),
                        EduDataRow(
                          label: 'Progression',
                          value:
                              '${(progress * 100).toStringAsFixed(1)}%',
                          valueColor: AppColors.green,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Barre progression
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.white10,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: client.isLate ? AppColors.red : AppColors.green,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                  ),

                  if (client.isLate) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0x1FE53935),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        '⚠ En retard de ${client.lateWeeks} semaine(s)',
                        style: GoogleFonts.openSans(
                            fontSize: 10, color: AppColors.red),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Liste des enfants
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Enfants inscrits',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showAddChildModal,
                        child: Text(
                          '+ Ajouter un enfant',
                          style: GoogleFonts.openSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (client.children == null || client.children!.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white05,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderDefault),
                      ),
                      child: Center(
                        child: Text(
                          'Aucun enfant inscrit pour le moment.\nVeuillez en ajouter un pour définir l\'objectif financier.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.openSans(
                            color: AppColors.white50,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    )
                  else
                    ...client.children!.map((c) => _buildChildCard(c)),

                  const SizedBox(height: 16),

                  EduButton.green(
                    '💵 Encaisser une cotisation',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              AgEncaisserScreen(preselectedClient: client)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  EduButton.yellow(
                    '📋 Voir l\'historique',
                    onPressed: () => _showHistory(context),
                  ),
                  const SizedBox(height: 8),
                  EduButton.outlined(
                    '🔔 Notifications envoyées',
                    onPressed: () => _showNotifications(context),
                  ),
                  const SizedBox(height: 8),
                  EduButton.outlined(
                    '📱 Voir le QR Code',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AgQrCodeClientScreen(
                            client: client,
                            isFromRegistration: false,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  EduButton.outlined(
                    '📞 Appeler ce client',
                    onPressed: () async {
                      final phone =
                          client.phone.replaceAll(' ', '').replaceAll('+', '');
                      final url = Uri.parse('tel:$phone');
                      try {
                        await launchUrl(url);
                      } catch (_) {
                        if (!context.mounted) return;
                        showEduToast(context, 'Impossible de lancer l\'appel',
                            isError: true);
                      }
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AgentBottomNav(
        currentIndex: 1,
        onTap: (i) {
          if (i == 1) Navigator.pop(context);
        },
      ),
    );
  }

  void _showAddChildModal() {
    if (_savingPlans.isEmpty) {
      // Afficher le modal quand même avec un message pour charger
      _loadSavingPlans().then((_) {
        if (mounted && _savingPlans.isNotEmpty) {
          _showAddChildModal();
        } else if (mounted) {
          showEduToast(context, 'Aucun kit d\'épargne disponible', isError: true);
        }
      });
      return;
    }

    final firstNameCtrl = TextEditingController();
    final schoolNameCtrl = TextEditingController();

    // Classes disponibles = valeurs distinctes de `level_scope` sur le
    // catalogue complet — une fois le vrai catalogue importé (28 classes),
    // ceci permet de ne proposer que les 3 kits (basic/intermediate/premium)
    // de LA classe de l'enfant, au lieu de tout le catalogue de la saison.
    final availableClasses = [
      'CP1', 'CP2', 'CE1', 'CE2', 'CM1', 'CM2',
      '6e', '5e', '4e', '3e', '2nde', '1ere', 'Tle A', 'Tle D'
    ];

    String? selectedClass = availableClasses.isNotEmpty ? availableClasses.first : null;
    List<dynamic> kitsForClass = selectedClass == null
        ? _savingPlans
        : _savingPlans.where((p) => p['level_scope'] == selectedClass).toList();
    if (kitsForClass.isEmpty) {
      kitsForClass = _savingPlans;
    }
    String? selectedPlanId = (kitsForClass.isNotEmpty && kitsForClass.first['id'] != null)
        ? kitsForClass.first['id'] as String
        : null;
    bool isSubmitting = false;
    // Liste des articles personnalisés choisis dans le catalogue
    List<Map<String, dynamic>>? customSelectedItems;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                  top: 20,
                  left: 20,
                  right: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                    'Ajouter un enfant',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('PRÉNOM DE L\'ENFANT'),
                  _buildInput(firstNameCtrl, 'Ex: Aminata'),
                  _buildLabel('ÉCOLE (Optionnel)'),
                  _buildInput(schoolNameCtrl, 'Ex: Lycée Zinda'),
                  if (availableClasses.isNotEmpty) ...[
                    _buildLabel('CLASSE'),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.white07,
                        border: Border.all(color: AppColors.borderDefault),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedClass,
                          isExpanded: true,
                          dropdownColor: AppColors.cardBg,
                          style: GoogleFonts.openSans(fontSize: 13, color: AppColors.white),
                          items: availableClasses
                              .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) {
                            setModalState(() {
                              selectedClass = v;
                              kitsForClass = v == null
                                  ? _savingPlans
                                  : _savingPlans.where((p) => p['level_scope'] == v).toList();
                              if (kitsForClass.isEmpty) {
                                kitsForClass = _savingPlans;
                              }
                              selectedPlanId = (kitsForClass.isNotEmpty && kitsForClass.first['id'] != null)
                                  ? kitsForClass.first['id'] as String
                                  : null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                  _buildLabel('KIT SCOLAIRE'),
                  const SizedBox(height: 10),
                  // ── 4 kits fixes en grille 2×2 ──
                  Builder(builder: (ctx2) {
                    // Mapper les niveaux backend vers les IDs disponibles
                    String? idBasic, idEssential, idPremium;
                    for (final p in kitsForClass) {
                      final lvl = (p['level'] as String? ?? '').toLowerCase();
                      final pid = p['id'] as String? ?? '';
                      if (lvl == 'basic') {
                        idBasic = pid;
                      } else if (lvl == 'intermediate' || lvl == 'essential') {
                        idEssential = pid;
                      } else if (lvl == 'premium') {
                        idPremium = pid;
                      }
                    }
                    // Si on a peu de kits on tente d'allouer par ordre
                    if (kitsForClass.isNotEmpty && idBasic == null) {
                      idBasic = kitsForClass[0]['id'] as String?;
                    }
                    if (kitsForClass.length >= 2 && idEssential == null) {
                      idEssential = kitsForClass[1]['id'] as String?;
                    }
                    if (kitsForClass.length >= 3 && idPremium == null) {
                      idPremium = kitsForClass[2]['id'] as String?;
                    }

                    // Récupérer les prix affichés
                    String priceOf(String? id) {
                      if (id == null) return '';
                      final p = kitsForClass.firstWhere((x) => x['id'] == id, orElse: () => <String,dynamic>{});
                      final price = p['price'];
                      return price != null ? '${(price as num).toInt()} F' : '';
                    }

                    // Définition des 4 kits (ordre : Basique | Essentiel / Premium | Personnaliser)
                    final List<Map<String, dynamic>> kits = [
                      {
                        'id': idBasic ?? '',
                        'label': 'Kit Basique',
                        'icon': Icons.school_outlined,
                        'price': priceOf(idBasic),
                        'selectable': idBasic != null,
                        'custom': false,
                      },
                      {
                        'id': idEssential ?? '',
                        'label': 'Kit Essentiel',
                        'icon': Icons.shopping_bag_outlined,
                        'price': priceOf(idEssential),
                        'selectable': idEssential != null,
                        'custom': false,
                      },
                      {
                        'id': idPremium ?? '',
                        'label': 'Kit Premium',
                        'icon': Icons.workspace_premium_outlined,
                        'price': priceOf(idPremium),
                        'selectable': idPremium != null,
                        'custom': false,
                      },
                      {
                        'id': '__custom__',
                        'label': 'Personnaliser',
                        'icon': Icons.tune_outlined,
                        'price': 'À définir',
                        'selectable': true,
                        'custom': true,
                      },
                    ];

                    Widget buildKitCard(Map<String, dynamic> kit, {bool addRightMargin = false}) {
                      final kitId = kit['id'] as String;
                      final isSelected = selectedPlanId == kitId && kitId.isNotEmpty;
                      final price = kit['price'] as String;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => selectedPlanId = kitId),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: EdgeInsets.only(right: addRightMargin ? 9 : 0, bottom: 10),
                            padding: const EdgeInsets.fromLTRB(6, 14, 6, 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF00C853).withValues(alpha: 0.13)
                                  : const Color(0x0DFFFFFF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF00C853)
                                    : const Color(0x26FFFFFF),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icône du kit
                                Icon(
                                  kit['icon'] as IconData,
                                  color: isSelected
                                      ? const Color(0xFF00C853)
                                      : const Color(0x99FFFFFF),
                                  size: 26,
                                ),
                                const SizedBox(height: 6),
                                // Nom du kit
                                Text(
                                  kit['label'] as String,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.openSans(
                                    fontSize: 10,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected
                                        ? const Color(0xFF00C853)
                                        : const Color(0xCCFFFFFF),
                                  ),
                                ),
                                // Prix ou "À définir"
                                if (price.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      price,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.openSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? const Color(0xFF00C853)
                                            : const Color(0x55FFFFFF),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                // Case à cocher circulaire
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? const Color(0xFF00C853)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF00C853)
                                          : const Color(0x55FFFFFF),
                                      width: 1.8,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check_rounded,
                                          color: Colors.white, size: 12)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        // Ligne 1 : Kit Basique | Kit Essentiel
                        Row(children: [
                          buildKitCard(kits[0], addRightMargin: true),
                          buildKitCard(kits[1]),
                        ]),
                        // Ligne 2 : Kit Premium | Personnaliser
                        Row(children: [
                          buildKitCard(kits[2], addRightMargin: true),
                          buildKitCard(kits[3]),
                        ]),
                      ],
                    );
                  }),
                  const SizedBox(height: 4),
                       // ── Aperçu kit standard OU formulaire kit personnalisé ──
                  Builder(builder: (_) {
                    // ── Kit Personnaliser sélectionné ──
                    if (selectedPlanId == '__custom__') {
                      int customTotal = 0;
                      if (customSelectedItems != null) {
                        for (var item in customSelectedItems!) {
                          customTotal += (item['qty'] as int) * (item['price'] as int);
                        }
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1D34),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0x26FFFFFF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.tune_outlined, color: Color(0xFF00C853), size: 15),
                                const SizedBox(width: 6),
                                Text(
                                  'Composition du kit personnalisé',
                                  style: GoogleFonts.openSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF00C853),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            if (customSelectedItems == null || customSelectedItems!.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.shopping_basket_outlined, color: AppColors.white35, size: 32),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Aucun article sélectionné',
                                        style: GoogleFonts.openSans(fontSize: 11, color: AppColors.white50),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else ...[
                              // En-tête colonnes
                              Row(
                                children: [
                                  Expanded(flex: 4, child: Text('Article', style: GoogleFonts.openSans(fontSize: 9, color: const Color(0x80FFFFFF), fontWeight: FontWeight.w600))),
                                  const SizedBox(width: 4),
                                  SizedBox(width: 30, child: Text('Qté', textAlign: TextAlign.center, style: GoogleFonts.openSans(fontSize: 9, color: const Color(0x80FFFFFF), fontWeight: FontWeight.w600))),
                                  const SizedBox(width: 4),
                                  SizedBox(width: 50, child: Text('Total', textAlign: TextAlign.right, style: GoogleFonts.openSans(fontSize: 9, color: const Color(0x80FFFFFF), fontWeight: FontWeight.w600))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Divider(color: Color(0x26FFFFFF), height: 1),
                              const SizedBox(height: 8),
                              // Lignes d'articles
                              ...List.generate(customSelectedItems!.length, (idx) {
                                final item = customSelectedItems![idx];
                                final subtotal = (item['qty'] as int) * (item['price'] as int);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          item['name'],
                                          style: GoogleFonts.openSans(fontSize: 11, color: const Color(0xFFFFFFFF)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      SizedBox(
                                        width: 30,
                                        child: Text(
                                          item['qty'].toString(),
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.openSans(fontSize: 11, color: const Color(0xFFFFFFFF), fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      SizedBox(
                                        width: 50,
                                        child: Text(
                                          subtotal.toString(),
                                          textAlign: TextAlign.right,
                                          style: GoogleFonts.openSans(fontSize: 11, color: const Color(0xFF00C853), fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 8),
                              const Divider(color: Color(0x26FFFFFF), height: 1),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total estimé:', style: GoogleFonts.openSans(fontSize: 11, color: AppColors.white70)),
                                  Text('$customTotal F', style: GoogleFonts.montserrat(fontSize: 14, color: AppColors.gold, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ],

                            const SizedBox(height: 16),
                            // Bouton pour ouvrir le catalogue
                            EduButton.outlined(
                              customSelectedItems == null || customSelectedItems!.isEmpty 
                                ? 'Ouvrir le catalogue pour personnaliser' 
                                : 'Modifier la sélection',
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AgPersonnaliserKitScreen(
                                      selectedClass: selectedClass ?? 'CP1',
                                    ),
                                  ),
                                );
                                if (result != null && result is List<Map<String, dynamic>>) {
                                  setModalState(() {
                                    customSelectedItems = result;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }
                    // ── Aperçu kit standard ──
                    if (selectedPlanId == null) return const SizedBox.shrink();
                    final selKit = kitsForClass.firstWhere(
                      (p) => p['id'] == selectedPlanId,
                      orElse: () => null,
                    );
                    if (selKit == null) return const SizedBox.shrink();
                    final items = selKit['items'] as List<dynamic>? ?? [];
                    final description = selKit['description'] as String? ?? '';
                    if (items.isEmpty && description.isEmpty) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853).withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF00C853).withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Text('✨ ', style: TextStyle(fontSize: 12)),
                                  Expanded(
                                    child: Text(
                                      description,
                                      style: GoogleFonts.openSans(fontSize: 10, color: const Color(0xB3FFFFFF), fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ...items.take(3).map((item) {
                            final name = item['name'] as String? ?? item['item_name'] as String? ?? item.toString();
                            final qty = item['quantity'] ?? item['qty'];
                            final itemPrice = item['price'] ?? item['unit_price'];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline, color: Color(0xFF00C853), size: 13),
                                  const SizedBox(width: 6),
                                  Expanded(child: Text(qty != null ? '$qty × $name' : name, style: GoogleFonts.openSans(fontSize: 10, color: const Color(0xB3FFFFFF)))),
                                  if (itemPrice != null)
                                    Text('${(itemPrice as num).toInt()} F', style: GoogleFonts.openSans(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0x80FFFFFF))),
                                ],
                              ),
                            );
                          }),
                          if (items.length > 3)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('Voir plus (${items.length - 3} articles)', style: GoogleFonts.openSans(fontSize: 10, color: const Color(0xFF00C853), fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                    );
                  }),
                  if (isSubmitting)
                    const Center(child: CircularProgressIndicator(color: AppColors.green))
                  else
                    EduButton.green('Ajouter', onPressed: () async {
                      if (firstNameCtrl.text.trim().isEmpty) {
                        showEduToast(ctx, 'Le prénom est obligatoire', isError: true);
                        return;
                      }
                      if (selectedPlanId == null) {
                        showEduToast(ctx, 'Veuillez choisir un kit', isError: true);
                        return;
                      }
                      // Validation kit personnalisé
                      if (selectedPlanId == '__custom__') {
                        if (customSelectedItems == null || customSelectedItems!.isEmpty) {
                          showEduToast(ctx, 'Ajoutez au moins un article au kit', isError: true);
                          return;
                        }
                      }
                      setModalState(() => isSubmitting = true);
                      try {
                        final existingChildIds =
                            (_client.children ?? const <ChildModel>[])
                                .map((child) => child.id)
                                .toSet();
                        final resp = await ApiClient.post('/agent/me/families/${_client.id}/children', {
                          'first_name': firstNameCtrl.text.trim(),
                          'school': schoolNameCtrl.text.trim(),
                          'level': selectedClass,
                        });
                        final Map<String, dynamic> data = resp['data'] ?? {};
                        final List children = data['children'] ?? [];
                        final newChild = children
                            .whereType<Map<String, dynamic>>()
                            .where((child) =>
                                !existingChildIds.contains(child['id']))
                            .cast<Map<String, dynamic>?>()
                            .firstOrNull;
                        final newChildId = newChild?['id'] as String?;

                        if (newChildId == null) {
                          throw ApiException(
                            500,
                            'Enfant créé, mais impossible de retrouver son identifiant pour assigner le kit.',
                          );
                        }

                        if (selectedPlanId != '__custom__') {
                          await ApiClient.post('/agent/me/families/${_client.id}/children/$newChildId/kit', {
                            'kit_id': selectedPlanId,
                          });
                        } else {
                          final validItems = customSelectedItems!.map((i) => {
                                'name': i['name'],
                                'quantity': i['qty'],
                                'price': i['price'],
                              }).toList();
                          await ApiClient.post('/agent/me/families/${_client.id}/children/$newChildId/kit', {
                            'custom': true,
                            'items': validItems,
                          });
                        }
                        if (!mounted || !ctx.mounted) return;
                        Navigator.pop(ctx);
                        showEduToast(context, 'Enfant ajouté avec succès');
                        _refreshClient();
                      } catch (e) {
                        if (!ctx.mounted) return;
                        setModalState(() => isSubmitting = false);
                        showEduToast(ctx, 'Erreur: $e', isError: true);
                      }
                    }),
                ],
              ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChildCard(ChildModel c) {
    final initials = c.firstName.isNotEmpty ? c.firstName[0].toUpperCase() : '?';
    final hasKit = c.kitId != null && c.kitId!.isNotEmpty;
    final kitLabel = hasKit ? 'Kit assigné' : 'Kit non assigné';

    // Déduire le label du kit depuis _savingPlans
    String kitDisplayLabel = kitLabel;
    if (hasKit) {
      final plan = _savingPlans.firstWhere(
        (p) => p['id'] == c.kitId,
        orElse: () => null,
      );
      if (plan != null) {
        final level = plan['level'] as String? ?? '';
        final price = plan['price'];
        final priceStr = price != null ? ' — ${(price as num).toInt()} F' : '';
        kitDisplayLabel = level == 'basic'
            ? 'Kit Basique$priceStr'
            : level == 'intermediate'
                ? 'Kit Essentiel$priceStr'
                : level == 'premium'
                    ? 'Kit Premium$priceStr'
                    : 'Kit$priceStr';
      }
    }

    return GestureDetector(
      onTap: () => _showChildOptions(context, c),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white05,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          // Avatar initiale
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Infos enfant
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.firstName,
                  style: GoogleFonts.openSans(
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    fontSize: 13,
                  ),
                ),
                if (c.level != null && c.level!.isNotEmpty ||
                    c.school != null && c.school!.isNotEmpty)
                  Text(
                    [
                      if (c.level != null && c.level!.isNotEmpty) c.level!,
                      if (c.school != null && c.school!.isNotEmpty) c.school!,
                    ].join(' · '),
                    style: GoogleFonts.openSans(
                      color: AppColors.white50,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          // Badge kit + montant
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (c.targetAmount != null && c.targetAmount! > 0)
                Text(
                  '${c.targetAmount!.toStringAsFixed(0)} F',
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: hasKit
                      ? AppColors.green.withValues(alpha: 0.12)
                      : AppColors.white10,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: hasKit
                        ? AppColors.green.withValues(alpha: 0.4)
                        : AppColors.borderDefault,
                  ),
                ),
                child: Text(
                  kitDisplayLabel,
                  style: GoogleFonts.openSans(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: hasKit ? AppColors.green : AppColors.white35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  void _showChildOptions(BuildContext context, ChildModel child) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Options pour ${child.firstName}',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.school_outlined, color: AppColors.green),
                title: Text('Scolarité', style: GoogleFonts.openSans(color: AppColors.white, fontWeight: FontWeight.w600)),
                subtitle: Text('Gérer le paiement de la scolarité', style: GoogleFonts.openSans(color: AppColors.white50, fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AgScolariteScreen(
                        familyId: _client.id,
                        child: child,
                      ),
                    ),
                  ).then((_) => _refreshClient());
                },
              ),
              ListTile(
                leading: const Icon(Icons.directions_bus_outlined, color: AppColors.gold),
                title: Text('Transport', style: GoogleFonts.openSans(color: AppColors.white, fontWeight: FontWeight.w600)),
                subtitle: Text('Gérer les abonnements de transport', style: GoogleFonts.openSans(color: AppColors.white50, fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AgTransportScreen(
                        familyId: _client.id,
                        child: child,
                      ),
                    ),
                  ).then((_) => _refreshClient());
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, top: 2),
      child: Text(
        text,
        style: GoogleFonts.openSans(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: AppColors.green,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String hint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        style: GoogleFonts.openSans(fontSize: 13, color: AppColors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.openSans(fontSize: 13, color: AppColors.white35),
          filled: true,
          fillColor: AppColors.white07,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: AppColors.borderDefault),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: AppColors.green),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  // ─── Historique des cotisations ──────────────────────────────────────────
  void _showHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return FutureBuilder<Map<String, dynamic>>(
          future: ApiClient.get('/agent/me/families/${_client.id}/contributions'),
          builder: (ctx, snapshot) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Historique des cotisations',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.green))
                  else if (snapshot.hasError)
                    Text('Impossible de charger l\'historique.',
                        style: GoogleFonts.openSans(color: AppColors.red))
                  else if (!snapshot.hasData ||
                      (snapshot.data!['data'] as List).isEmpty)
                    Text('Aucune cotisation enregistrée.',
                        style: GoogleFonts.openSans(color: AppColors.white50))
                  else
                    ...(snapshot.data!['data'] as List).take(10).map((tx) {
                      final amount =
                          double.tryParse(tx['amount']?.toString() ?? '0') ??
                              0;
                      final status = tx['status'] ?? '';
                      final createdAt = tx['createdAt']?.toString() ?? '';
                      final date = createdAt.length >= 10
                          ? createdAt.substring(0, 10)
                          : createdAt;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: EduDataRow(
                          label: '$date — ${tx['mode'] ?? ''}',
                          value: '+ ${amount.toStringAsFixed(0)} FCFA',
                          valueColor: status == 'COMPLETED'
                              ? AppColors.green
                              : AppColors.gold,
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── Historique des notifications ────────────────────────────────────────
  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (ctx, scrollController) {
            return Consumer<AgentProvider>(
              builder: (ctx, provider, _) {
                final notifications = provider.notifications;
                final isLoading = provider.isLoadingNotifications;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.white35,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        '🔔 Notifications envoyées',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SMS reçus par ${_client.fullName}',
                        style: GoogleFonts.openSans(
                          fontSize: 10,
                          color: AppColors.white50,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (isLoading)
                        const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.green),
                          ),
                        )
                      else if (notifications.isEmpty)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('📭',
                                    style: TextStyle(fontSize: 40)),
                                const SizedBox(height: 8),
                                Text(
                                  'Aucune notification envoyée',
                                  style: GoogleFonts.openSans(
                                    fontSize: 13,
                                    color: AppColors.white50,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            controller: scrollController,
                            itemCount: notifications.length,
                            separatorBuilder: (_, _) => const Divider(
                              color: AppColors.divider,
                              height: 1,
                            ),
                            itemBuilder: (ctx, i) {
                              return _buildNotificationTile(notifications[i]);
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationTile(NotificationModel notif) {
    final formattedDate =
        DateFormat('dd/MM/yyyy HH:mm').format(notif.createdAt);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: notif.isSent
                  ? AppColors.green.withValues(alpha: 0.12)
                  : AppColors.white05,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(notif.icon, style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),

          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notif.shortLabel,
                        style: GoogleFonts.openSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    // Badge statut
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: notif.isSent
                            ? AppColors.green.withValues(alpha: 0.12)
                            : AppColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        notif.isSent ? 'Envoyé' : 'En attente',
                        style: GoogleFonts.openSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: notif.isSent
                              ? AppColors.green
                              : AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  notif.body.length > 80
                      ? '${notif.body.substring(0, 80)}...'
                      : notif.body,
                  style: GoogleFonts.openSans(
                    fontSize: 10,
                    color: AppColors.white50,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$formattedDate — ${notif.channel}',
                  style: GoogleFonts.openSans(
                    fontSize: 9,
                    color: AppColors.white35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
