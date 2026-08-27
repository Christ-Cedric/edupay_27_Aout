// =============================================================================
// FEATURES/AGENT/SCREENS/AG_BON_LIVRAISON_SCREEN.DART
// =============================================================================
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signature/signature.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/services/api_client.dart';
import '../../../core/models/livraison_model.dart';
import 'package:intl/intl.dart';

class AgBonLivraisonScreen extends StatefulWidget {
  final String livraisonId;
  const AgBonLivraisonScreen({super.key, required this.livraisonId});

  @override
  State<AgBonLivraisonScreen> createState() => _AgBonLivraisonScreenState();
}

class _AgBonLivraisonScreenState extends State<AgBonLivraisonScreen> {
  LivraisonModel? _livraison;
  bool _isLoading = true;
  bool _isConfirming = false;
  List<dynamic> _articles = [];
  List<bool> _checked = [];

  final SignatureController _sigController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );
  bool _signed = false;

  @override
  void initState() {
    super.initState();
    _sigController.onDrawEnd = () => setState(() => _signed = _sigController.isNotEmpty);
    _loadLivraisonDetails();
  }

  @override
  void dispose() {
    _sigController.dispose();
    super.dispose();
  }

  Future<void> _loadLivraisonDetails() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.get('/agent/me/deliveries/${widget.livraisonId}');
      _livraison = LivraisonModel.fromJson(response['data']);

      // Le DeliveryDto ne porte que `kit_id` — la composition réelle du kit
      // (articles/quantités) vient du catalogue, pas d'une liste générique.
      final kitsResponse = await ApiClient.get('/catalog/kits');
      final kits = kitsResponse['data'] as List;
      final kit = kits
          .cast<Map<String, dynamic>>()
          .where((k) => k['id'] == _livraison!.kitId)
          .firstOrNull;
      final items = (kit?['items'] as List?) ?? const [];
      _articles = items
          .cast<Map<String, dynamic>>()
          .map((i) => '${i['quantity']} x ${i['label']}')
          .toList();
      if (_articles.isEmpty) _articles = ['Kit scolaire'];
      _checked = List.filled(_articles.length, false);
    } catch (e) {
      if (mounted) showEduToast(context, 'Erreur lors du chargement', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmLivraison() async {
    // Vérifier si tous les articles sont cochés
    if (_checked.contains(false)) {
      showEduToast(context, 'Veuillez cocher tous les articles avant de valider', isError: true);
      return;
    }
    if (!_signed) {
      showEduToast(context, 'La signature du client est requise avant de valider', isError: true);
      return;
    }

    setState(() => _isConfirming = true);
    try {
      final signatureBytes = await _sigController.toPngBytes();
      await ApiClient.post('/agent/me/deliveries/${widget.livraisonId}/confirm', {
        'notes': 'Confirmé sur le terrain par l\'agent',
        if (signatureBytes != null) 'signature': base64Encode(signatureBytes),
      });

      if (mounted) {
        // Afficher le dialogue de succès avec notification
        await _showLivraisonSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        final msg = e is ApiException ? e.message : e.toString();
        showEduToast(context, 'Erreur: $msg', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  /// Dialogue de succès montrant que la livraison est confirmée ET le client notifié
  Future<void> _showLivraisonSuccessDialog() async {
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
                color: AppColors.green.withOpacity(0.12),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône succès
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.green, width: 2),
                ),
                child: const Center(
                  child: Text('📦', style: TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Livraison Confirmée !',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                'Le kit scolaire a bien été remis à la famille.',
                style: GoogleFonts.openSans(
                  fontSize: 12,
                  color: AppColors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Détails de la livraison
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white05,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Column(
                  children: [
                    if (_livraison?.clientFullName != null)
                      _buildDetailRow('👤 Client', _livraison!.clientFullName!),
                    if (_livraison?.childFirstName != null)
                      _buildDetailRow('👦 Enfant', _livraison!.childFirstName!),
                    _buildDetailRow('📋 Articles', '${_articles.length} articles remis'),
                    _buildDetailRow(
                      '📅 Date',
                      DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Notification envoyée au client
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.green.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat, color: AppColors.green, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Client notifié automatiquement par WhatsApp',
                      style: GoogleFonts.openSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              EduButton.green(
                'Retour aux livraisons',
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.pop(context, true); // true = rafraîchir la liste
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.openSans(
                fontSize: 10,
                color: AppColors.white50,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.openSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      'Bon de livraison',
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
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.green))
                : _livraison == null
                    ? const Center(
                        child: Text('Livraison introuvable',
                            style: TextStyle(color: AppColors.white50)))
                    // Le pavé de signature (plus bas) ne doit JAMAIS être un
                    // descendant d'un widget défilable : son geste de dessin
                    // entrerait en concurrence avec le geste de défilement de
                    // l'ancêtre (arène de gestes Flutter), rendant le tracé
                    // au doigt impossible sur certains appareils et bloquant
                    // toute confirmation de livraison. Seule la partie
                    // "infos + checklist" défile ; signature et bouton
                    // restent dans une zone fixe (voir plus bas).
                    : Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                            Text(
                              _livraison!.reference,
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Livraison à domicile — validez sur place',
                              style: GoogleFonts.openSans(
                                  fontSize: 11, color: AppColors.white50),
                            ),
                            const SizedBox(height: 14),

                            // Infos client
                            EduCard(
                              child: Column(
                                children: [
                                  EduDataRow(
                                    label: 'Client',
                                    value: _livraison!.clientFullName ?? 'Inconnu',
                                  ),
                                  if (_livraison!.childFirstName != null &&
                                      _livraison!.childFirstName!.isNotEmpty)
                                    EduDataRow(
                                      label: 'Enfant',
                                      value: _livraison!.childFirstName!,
                                      valueColor: AppColors.gold,
                                    ),
                                  EduDataRow(
                                    label: 'Adresse',
                                    value: _livraison!.location?.address.isNotEmpty == true
                                        ? _livraison!.location!.address
                                        : _livraison!.clientCity ?? 'Inconnue',
                                  ),
                                  EduDataRow(
                                    label: 'École',
                                    value: _livraison!.childSchool ?? 'Non spécifié',
                                    valueColor: AppColors.gold,
                                  ),
                                  EduDataRow(
                                    label: 'Articles',
                                    value: '${_articles.length} articles',
                                    showDivider: false,
                                  ),
                                ],
                              ),
                            ),

                            // Badge "Épargne complète"
                            if (_livraison!.isDelivered == false)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.green.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppColors.green.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('🎉 ',
                                        style: TextStyle(fontSize: 12)),
                                    Text(
                                      'Épargne complète — Kit scolaire à remettre',
                                      style: GoogleFonts.openSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SectionLabel('ARTICLES À REMETTRE'),

                            // Check-list articles
                            if (_articles.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text('Aucun article listé',
                                    style:
                                        TextStyle(color: AppColors.white50)),
                              )
                            else
                              ...List.generate(
                                _articles.length,
                                (i) {
                                  final articleStr = _articles[i].toString();
                                  return GestureDetector(
                                    onTap: _livraison!.isDelivered
                                        ? null
                                        : () => setState(
                                            () => _checked[i] = !_checked[i]),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: AppColors.divider,
                                                width: 1)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              articleStr,
                                              style: GoogleFonts.openSans(
                                                fontSize: 12,
                                                color: _checked[i] ||
                                                        _livraison!.isDelivered
                                                    ? AppColors.white50
                                                    : AppColors.white70,
                                                decoration: _checked[i] ||
                                                        _livraison!.isDelivered
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              color: _checked[i] ||
                                                      _livraison!.isDelivered
                                                  ? AppColors.green
                                                  : Colors.transparent,
                                              border: Border.all(
                                                color: _checked[i] ||
                                                        _livraison!.isDelivered
                                                    ? AppColors.green
                                                    : AppColors.borderDefault,
                                                width: 1.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: _checked[i] ||
                                                    _livraison!.isDelivered
                                                ? const Icon(Icons.check,
                                                    color: AppColors.background,
                                                    size: 14)
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                                ],
                              ),
                            ),
                          ),

                          // Zone fixe (hors de tout défilement) : signature + validation.
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Signature manuscrite du client (obligatoire avant validation).
                                if (!_livraison!.isDelivered) ...[
                                  Text(
                                    'Signature du client',
                                    style: GoogleFonts.openSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 140,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _signed ? AppColors.green : AppColors.borderDefault,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Signature(
                                        controller: _sigController,
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _signed
                                          ? () {
                                              _sigController.clear();
                                              setState(() => _signed = false);
                                            }
                                          : null,
                                      child: const Text('Effacer'),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],

                                // Bouton ou statut
                                if (_livraison!.isDelivered)
                                  EduCard(
                                    borderColor: const Color(0x3300C853),
                                    bgColor: const Color(0x0F00C853),
                                    child: Column(
                                      children: [
                                        Center(
                                          child: Text(
                                            '✅ Livraison déjà confirmée',
                                            style: GoogleFonts.openSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.green,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Center(
                                          child: Text(
                                            '💬 Client notifié par WhatsApp',
                                            style: GoogleFonts.openSans(
                                              fontSize: 10,
                                              color: AppColors.white50,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (_isConfirming)
                                  const Center(
                                      child: CircularProgressIndicator(
                                          color: AppColors.green))
                                else if (!_livraison!.isDelivered)
                                  EduButton.green(
                                    'Valider la livraison',
                                    onPressed: _confirmLivraison,
                                  ),
                              ],
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
