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
      if (mounted)
        setState(() => _savingPlans = response['data'] as List<dynamic>);
    } catch (e) {
      if (mounted)
        showEduToast(
          context,
          'Impossible de charger les kits d\'épargne',
          isError: true,
        );
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
      if (mounted)
        showEduToast(context, 'Erreur lors du rafraîchissement', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = _client;
    final balance = client.balance;
    final targetAmount = client.targetAmount;
    final progress = targetAmount > 0
        ? (balance / targetAmount).clamp(0.0, 1.0)
        : 0.0;

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
                bottom: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.white70,
                    size: 22,
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Fiche Famille',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
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
                        backgroundColor: client.isCompleted
                            ? AppColors.green
                            : client.isLate
                            ? AppColors.red
                            : AppColors.green,
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
                              fontSize: 10,
                              color: AppColors.white50,
                            ),
                          ),
                          if (client.familyCode != null &&
                              client.familyCode!.isNotEmpty)
                            Text(
                              client.familyCode!,
                              style: GoogleFonts.openSans(
                                fontSize: 9,
                                color: AppColors.gold,
                                fontWeight: FontWeight.w700,
                              ),
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
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.green.withOpacity(0.3),
                        ),
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
                          value: '${targetAmount.toStringAsFixed(0)} FCFA',
                        ),
                        EduDataRow(
                          label: 'Progression',
                          value: '${(progress * 100).toStringAsFixed(1)}%',
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
                          color: client.isLate
                              ? AppColors.red
                              : AppColors.green,
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
                          fontSize: 10,
                          color: AppColors.red,
                        ),
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
                    ...client.children!.map(
                      (c) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white05,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderDefault),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.firstName,
                              style: GoogleFonts.openSans(
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                                fontSize: 13,
                              ),
                            ),
                            if (c.school != null && c.school!.isNotEmpty)
                              Text(
                                'École: ${c.school}',
                                style: GoogleFonts.openSans(
                                  color: AppColors.white50,
                                  fontSize: 11,
                                ),
                              ),
                            if (c.targetAmount != null && c.targetAmount! > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Objectif - ${c.targetAmount!.toStringAsFixed(0)} FCFA',
                                  style: GoogleFonts.openSans(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  EduButton.green(
                    ' Encaisser une cotisation',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AgEncaisserScreen(preselectedClient: client),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  EduButton.yellow(
                    ' Voir l\'historique',
                    onPressed: () => _showHistory(context),
                  ),
                  const SizedBox(height: 8),
                  EduButton.outlined(
                    ' Notifications envoyées',
                    onPressed: () => _showNotifications(context),
                  ),
                  const SizedBox(height: 8),
                  EduButton.outlined(
                    'Voir le QR Code',
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
                    ' Appeler ce client',
                    onPressed: () async {
                      final phone = client.phone
                          .replaceAll(' ', '')
                          .replaceAll('+', '');
                      final url = Uri.parse('tel:$phone');
                      try {
                        await launchUrl(url);
                      } catch (_) {
                        if (!context.mounted) return;
                        showEduToast(
                          context,
                          'Impossible de lancer l\'appel',
                          isError: true,
                        );
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
          showEduToast(
            context,
            'Aucun kit d\'épargne disponible',
            isError: true,
          );
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
    final availableClasses = <String>{
      for (final p in _savingPlans)
        if (p['level_scope'] is String) p['level_scope'] as String,
    }.toList()..sort();

    String? selectedClass = availableClasses.isNotEmpty
        ? availableClasses.first
        : null;
    List<dynamic> kitsForClass = selectedClass == null
        ? _savingPlans
        : _savingPlans.where((p) => p['level_scope'] == selectedClass).toList();
    String? selectedPlanId =
        (kitsForClass.isNotEmpty && kitsForClass.first['id'] != null)
        ? kitsForClass.first['id'] as String
        : null;
    bool isSubmitting = false;

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
                right: 20,
              ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
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
                          style: GoogleFonts.openSans(
                            fontSize: 13,
                            color: AppColors.white,
                          ),
                          items: availableClasses
                              .map(
                                (c) => DropdownMenuItem<String>(
                                  value: c,
                                  child: Text(c),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            setModalState(() {
                              selectedClass = v;
                              kitsForClass = v == null
                                  ? _savingPlans
                                  : _savingPlans
                                        .where((p) => p['level_scope'] == v)
                                        .toList();
                              selectedPlanId =
                                  (kitsForClass.isNotEmpty &&
                                      kitsForClass.first['id'] != null)
                                  ? kitsForClass.first['id'] as String
                                  : null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                  _buildLabel('KIT D\'ÉPARGNE'),
                  Text(
                    'Choisissez une formule et consultez sa composition.',
                    style: GoogleFonts.openSans(
                      fontSize: 11,
                      color: AppColors.white50,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...kitsForClass.map((plan) {
                    final planId = plan['id'] as String?;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildKitChoice(
                        plan: plan,
                        selected: planId != null && planId == selectedPlanId,
                        onTap: planId == null
                            ? null
                            : () =>
                                  setModalState(() => selectedPlanId = planId),
                      ),
                    );
                  }),
                  if (isSubmitting)
                    const Center(
                      child: CircularProgressIndicator(color: AppColors.green),
                    )
                  else
                    EduButton.green(
                      'Ajouter',
                      onPressed: () async {
                        if (firstNameCtrl.text.trim().isEmpty ||
                            selectedPlanId == null) {
                          showEduToast(
                            ctx,
                            'Prénom et plan obligatoires',
                            isError: true,
                          );
                          return;
                        }
                        setModalState(() => isSubmitting = true);
                        try {
                          final resp = await ApiClient.post(
                            '/agent/me/families/${_client.id}/children',
                            {
                              'first_name': firstNameCtrl.text.trim(),
                              'school': schoolNameCtrl.text.trim(),
                              if (selectedClass != null) 'level': selectedClass,
                            },
                          );

                          final Map<String, dynamic> data = resp['data'] ?? {};
                          final List children = data['children'] ?? [];
                          // Trouver l'enfant qu'on vient de créer
                          final newChild = children.lastWhere(
                            (c) =>
                                c['first_name'] == firstNameCtrl.text.trim() &&
                                c['kit_id'] == null,
                            orElse: () =>
                                children.isNotEmpty ? children.last : null,
                          );

                          if (newChild != null && newChild['id'] != null) {
                            await ApiClient.post(
                              '/agent/me/families/${_client.id}/children/${newChild['id']}/kit',
                              {'kit_id': selectedPlanId},
                            );
                          }

                          if (mounted) Navigator.pop(ctx);
                          showEduToast(context, 'Enfant ajouté avec succès');
                          _refreshClient();
                        } catch (e) {
                          setModalState(() => isSubmitting = false);
                          showEduToast(ctx, 'Erreur: $e', isError: true);
                        }
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildKitChoice({
    required dynamic plan,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    final level = plan['level'] as String? ?? '';
    final price = (plan['price'] as num?)?.toInt() ?? 0;
    final items = plan['items'] is List ? plan['items'] as List : const [];
    final title = switch (level) {
      'basic' => 'Kit Basique',
      'intermediate' => 'Kit Intermédiaire',
      'premium' => 'Kit Premium',
      _ => 'Kit scolaire',
    };
    final subtitle = switch (level) {
      'basic' => 'L’essentiel pour bien démarrer',
      'intermediate' => 'Un équipement plus complet',
      'premium' => 'La formule la plus complète',
      _ => 'Fournitures adaptées à la classe',
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.green.withValues(alpha: .12)
              : AppColors.white07,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.borderDefault,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.green : AppColors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    level == 'premium'
                        ? Icons.workspace_premium_outlined
                        : Icons.shopping_basket_outlined,
                    color: selected ? Colors.white : AppColors.gold,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.openSans(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.openSans(
                          color: AppColors.white50,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${price.toString()} FCFA',
                  style: GoogleFonts.montserrat(
                    color: selected ? AppColors.green : AppColors.gold,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selected ? AppColors.green : AppColors.white35,
                  size: 20,
                ),
              ],
            ),
            if (selected && items.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: 8),
              Text(
                'Composition du kit',
                style: GoogleFonts.openSans(
                  color: AppColors.white70,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 5),
              ...items.take(4).map((item) {
                final itemMap = item is Map ? item : const <String, dynamic>{};
                final label =
                    itemMap['label'] ?? itemMap['name'] ?? 'Fourniture';
                final quantity = itemMap['quantity'] ?? 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.green,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '$quantity × $label',
                          style: GoogleFonts.openSans(
                            color: AppColors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (items.length > 4)
                Text(
                  '+ ${items.length - 4} autres fournitures',
                  style: GoogleFonts.openSans(
                    color: AppColors.white50,
                    fontSize: 10,
                  ),
                ),
            ],
          ],
        ),
      ),
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
          hintStyle: GoogleFonts.openSans(
            fontSize: 13,
            color: AppColors.white35,
          ),
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
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
          future: ApiClient.get(
            '/agent/me/families/${_client.id}/contributions',
          ),
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
                      child: CircularProgressIndicator(color: AppColors.green),
                    )
                  else if (snapshot.hasError)
                    Text(
                      'Impossible de charger l\'historique.',
                      style: GoogleFonts.openSans(color: AppColors.red),
                    )
                  else if (!snapshot.hasData ||
                      (snapshot.data!['data'] as List).isEmpty)
                    Text(
                      'Aucune cotisation enregistrée.',
                      style: GoogleFonts.openSans(color: AppColors.white50),
                    )
                  else
                    ...(snapshot.data!['data'] as List).take(10).map((tx) {
                      final amount =
                          double.tryParse(tx['amount']?.toString() ?? '0') ?? 0;
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
                              color: AppColors.green,
                            ),
                          ),
                        )
                      else if (notifications.isEmpty)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '📭',
                                  style: TextStyle(fontSize: 40),
                                ),
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
                            separatorBuilder: (_, __) => const Divider(
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
    final formattedDate = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(notif.createdAt);

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
                  ? AppColors.green.withOpacity(0.12)
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
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: notif.isSent
                            ? AppColors.green.withOpacity(0.12)
                            : AppColors.gold.withOpacity(0.12),
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
