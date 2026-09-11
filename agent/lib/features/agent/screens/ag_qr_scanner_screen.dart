// =============================================================================
// FEATURES/AGENT/SCREENS/AG_QR_SCANNER_SCREEN.DART
// Scanner QR du client + saisie cotisation depuis le profil agent
// =============================================================================
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/services/api_client.dart';
import '../../../core/providers/agent_provider.dart';
import '../../../core/models/client_model.dart';
import 'ag_recu_screen.dart';

class AgQrScannerScreen extends StatefulWidget {
  const AgQrScannerScreen({super.key});

  @override
  State<AgQrScannerScreen> createState() => _AgQrScannerScreenState();
}

class _AgQrScannerScreenState extends State<AgQrScannerScreen>
    with TickerProviderStateMixin {
  final MobileScannerController _scannerCtrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    formats: const [BarcodeFormat.qrCode],
  );

  late final AnimationController _scanLineCtrl;
  late final Animation<double> _scanLineAnim;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  bool _isProcessing = false;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    _scanLineCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _scanLineAnim =
        Tween<double>(begin: 0.0, end: 1.0).animate(_scanLineCtrl);

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _scannerCtrl.dispose();
    _scanLineCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue ?? barcodes.first.displayValue;
    if (rawValue == null || rawValue.isEmpty) {
      if (mounted) showEduToast(context, 'QR vide ou illisible', isError: true);
      return;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();
    _scannerCtrl.stop();

    if (mounted) showEduToast(context, 'Code détecté ! Vérification...');

    _processQrData(rawValue);
  }

  void _processQrData(String rawValue) {
    try {
      // Essayer de parser le JSON du QR
      final Map<String, dynamic> qrData = jsonDecode(rawValue);

      // Si le code contient un familyCode (nouveau format allégé ou ancien format lourd)
      if (qrData.containsKey('familyCode')) {
        _fetchClientAndShowModal(qrData['familyCode'] as String);
        return;
      }
      
      // Fallback: format intermédiaire récent
      if (qrData.containsKey('clientCode')) {
        _fetchClientAndShowModal(qrData['clientCode'] as String);
        return;
      }
      
      // Fallback: très ancien format
      if (qrData.containsKey('nom')) {
         _showErrorAndResume('QR obsolète, veuillez réimprimer');
         return;
      }

      _showErrorAndResume('QR invalide — Code manquant');
    } catch (e) {
      // Si ce n'est pas du JSON, on assume que c'est un code brut (ex: KOU-2026-ABCD, EDP-1234, FAM-5678)
      // On accepte tout texte court (<= 25 caractères) et on laisse le backend valider.
      if (rawValue.trim().length <= 25) {
        _fetchClientAndShowModal(rawValue.trim());
      } else {
        _showErrorAndResume('QR invalide — Code non reconnu');
      }
    }
  }

  Future<void> _fetchClientAndShowModal(String clientCode) async {

    try {
      final response = await ApiClient.get('/agent/me/families/by-code/$clientCode');
      final clientData = response['data'] as Map<String, dynamic>;
      final client = ClientModel.fromJson(clientData);

      if (!mounted) return;
      _showCotisationModal(client);
    } catch (e) {
      final msg = e is ApiException ? e.message : 'Client introuvable';
      _showErrorAndResume('Erreur: $msg');
    }
  }

  void _showErrorAndResume(String message) {
    if (mounted) {
      showEduToast(context, message, isError: true);
      setState(() => _isProcessing = false);
      _scannerCtrl.start();
    }
  }

  void _showCotisationModal(ClientModel client) {
    // Vérification anticipée : pas de modal si aucun objectif d'épargne actif.
    // Cela évite de présenter l'erreur rouge du backend à l'agent sans contexte.
    final remainingAmount = client.targetAmount - client.balance;
    if (client.targetAmount <= 0 || remainingAmount <= 0) {
      if (client.targetAmount <= 0) {
        // Pas encore de kit assigné
        _showErrorAndResume(
          '${client.fullName} n\'a pas encore de kit d\'épargne. '
          'Ouvrez sa fiche pour lui assigner un kit.',
        );
      } else {
        // Objectif déjà atteint
        _showErrorAndResume(
          '${client.fullName} a déjà atteint son objectif d\'épargne ! '
          'Aucune cotisation supplémentaire requise.',
        );
      }
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => _CotisationModal(
        client: client,
        onSuccess: (amount, modeCollecte) {
          Navigator.pop(ctx);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AgRecuScreen(
                modeCollecte: modeCollecte,
                clientName: client.fullName,
                amount: amount,
              ),
            ),
          );
        },
        onCancel: () {
          Navigator.pop(ctx);
          if (mounted) {
            setState(() => _isProcessing = false);
            _scannerCtrl.start();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Caméra en plein écran
          MobileScanner(
            controller: _scannerCtrl,
            onDetect: _onDetect,
          ),

          // Overlay sombre avec découpe QR
          _buildScannerOverlay(),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Scanner QR Client',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  // Bouton torche
                  GestureDetector(
                    onTap: () async {
                      await _scannerCtrl.toggleTorch();
                      setState(() => _torchOn = !_torchOn);
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _torchOn
                            ? AppColors.gold.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _torchOn
                            ? Icons.flashlight_on
                            : Icons.flashlight_off,
                        color: _torchOn ? AppColors.gold : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bas de l'écran — instructions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isProcessing) ...[
                    const CircularProgressIndicator(
                        color: AppColors.green, strokeWidth: 2),
                    const SizedBox(height: 12),
                    Text(
                      'Chargement du client...',
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, 
                          fontSize: 13, color: Colors.white70),
                    ),
                  ] else ...[
                    AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (_, child) => Opacity(
                        opacity: _pulseAnim.value,
                        child: child,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.qr_code_scanner,
                              color: AppColors.green, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Pointez la caméra vers le QR EduPay',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Le dossier du client s\'ouvrira automatiquement',
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, 
                          fontSize: 10, color: Colors.white54),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return CustomPaint(
      painter: _ScannerOverlayPainter(scanLineAnim: _scanLineAnim),
      child: const SizedBox.expand(),
    );
  }
}

// =============================================================================
// PAINTER — Overlay scanner avec ligne animée
// =============================================================================
class _ScannerOverlayPainter extends CustomPainter {
  final Animation<double> scanLineAnim;

  _ScannerOverlayPainter({required this.scanLineAnim})
      : super(repaint: scanLineAnim);

  @override
  void paint(Canvas canvas, Size size) {
    const cutoutSize = 240.0;
    final cutoutLeft = (size.width - cutoutSize) / 2;
    final cutoutTop = (size.height - cutoutSize) / 2 - 40;
    final cutoutRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cutoutLeft, cutoutTop, cutoutSize, cutoutSize),
      const Radius.circular(16),
    );

    // Fond sombre
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(cutoutRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withValues(alpha: 0.6),
    );

    // Bordure verte du cadre
    canvas.drawRRect(
      cutoutRect,
      Paint()
        ..color = AppColors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Coins accentués
    _drawCorner(canvas, Offset(cutoutLeft, cutoutTop), true, true);
    _drawCorner(canvas, Offset(cutoutLeft + cutoutSize, cutoutTop), false, true);
    _drawCorner(canvas, Offset(cutoutLeft, cutoutTop + cutoutSize), true, false);
    _drawCorner(canvas,
        Offset(cutoutLeft + cutoutSize, cutoutTop + cutoutSize), false, false);

    // Ligne de scan animée
    final scanY = cutoutTop + scanLineAnim.value * cutoutSize;
    canvas.drawLine(
      Offset(cutoutLeft + 10, scanY),
      Offset(cutoutLeft + cutoutSize - 10, scanY),
      Paint()
        ..color = AppColors.green.withValues(alpha: 0.8)
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  void _drawCorner(Canvas canvas, Offset corner, bool isLeft, bool isTop) {
    const length = 24.0;
    const width = 4.0;
    final paint = Paint()
      ..color = AppColors.green
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    final dx = isLeft ? length : -length;
    final dy = isTop ? length : -length;

    canvas.drawLine(corner, corner.translate(dx, 0), paint);
    canvas.drawLine(corner, corner.translate(0, dy), paint);
  }

  @override
  bool shouldRepaint(_ScannerOverlayPainter oldDelegate) => true;
}

// =============================================================================
// MODAL — Saisie cotisation après scan
// =============================================================================
class _CotisationModal extends StatefulWidget {
  final ClientModel client;
  final void Function(double amount, String modeCollecte) onSuccess;
  final VoidCallback onCancel;

  const _CotisationModal({
    required this.client,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<_CotisationModal> createState() => _CotisationModalState();
}

class _CotisationModalState extends State<_CotisationModal> {
  final TextEditingController _amountCtrl = TextEditingController();
  String _modeCollecte = 'CASH';
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _modes = [
    {
      'id': 'CASH',
      'bg': AppColors.green,
      'label': 'Espèces',
      'icon': Icons.payments_outlined,
    },
  ];

  /// Calcule le montant suggéré
  double get _montantSuggere {
    final remaining = widget.client.targetAmount - widget.client.balance;
    return remaining > 0 ? remaining : 0.0;
  }

  @override
  void initState() {
    super.initState();
    // Pré-remplir avec le montant total calculé
    final montant = _montantSuggere;
    if (montant > 0) {
      _amountCtrl.text = montant.toInt().toString();
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitCotisation(BuildContext ctx) async {
    final amountStr = _amountCtrl.text.trim();
    final amount = double.tryParse(amountStr);

    if (amount == null || amount <= 0) {
      showEduToast(ctx, 'Montant invalide', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ApiClient.post('/agent/me/families/${widget.client.id}/contributions', {
        'amount': amount,
      });

      if (ctx.mounted) {
        ctx.read<AgentProvider>().loadDashboard();
        widget.onSuccess(amount, _modeCollecte);
      }
    } catch (e) {
      if (ctx.mounted) {
        final msg = e is ApiException ? e.message : e.toString();
        showEduToast(ctx, 'Erreur: $msg', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = widget.client;
    final balance = client.balance;
    final targetAmount = client.targetAmount;
    final progressPct = targetAmount > 0 ? (balance / targetAmount) : 0.0;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.white35,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // En-tête client
            Row(
              children: [
                // Avatar
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.green, Color(0xFF00897B)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      client.initials,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.fullName,
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            client.familyCode ?? '',
                            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, 
                                fontSize: 10, color: AppColors.green),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${client.phone}',
                            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, 
                                fontSize: 10, color: AppColors.white50),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Badge statut
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: client.isLate
                        ? AppColors.orange.withValues(alpha: 0.15)
                        : AppColors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    client.isLate ? '⚠ Retard' : '✓ Actif',
                    style: GoogleFonts.montserrat(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: client.isLate
                          ? AppColors.orange
                          : AppColors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Barre de progression épargne
            if (targetAmount > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Épargne accumulée',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, 
                        fontSize: 10, color: AppColors.white50),
                  ),
                  Text(
                    '${NumberFormat('#,###').format(balance.toInt())} / ${NumberFormat('#,###').format(targetAmount.toInt())} FCFA',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressPct.clamp(0.0, 1.0),
                  backgroundColor: AppColors.white10,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.green),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(progressPct * 100).toStringAsFixed(0)}% atteint',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, 
                    fontSize: 9, color: AppColors.white35),
              ),
              const SizedBox(height: 12),
            ],

            // Liste des enfants de la famille
            if (client.children != null && client.children!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white05,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.child_care, color: AppColors.green, size: 12),
                        const SizedBox(width: 5),
                        Text(
                          'ENFANTS INSCRITS (${client.children!.length})',
                          style: GoogleFonts.montserrat(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: AppColors.green,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...client.children!.map((child) => Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.green.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                child.firstName[0].toUpperCase(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.green,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  child.firstName,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                  ),
                                ),
                                  if (child.school != null)
                                    Text(
                                      child.school!,
                                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, 
                                          fontSize: 9, color: AppColors.white50),
                                    ),
                                ],
                              ),
                            ),
                            if (child.targetAmount != null && child.targetAmount! > 0)
                              Text(
                                '${child.targetAmount!.toInt()} FCFA (Obj.)',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gold,
                                ),
                              ),
                          ],
                      ),
                    )),
                    const SizedBox(height: 8),
                    const Divider(color: AppColors.divider, height: 1),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total cotisation suggérée',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white70,
                          ),
                        ),
                        Text(
                          '${_montantSuggere.toInt()} FCFA',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            const Divider(color: AppColors.divider),
            const SizedBox(height: 12),

            // Titre saisie
            Text(
              'ENCAISSER LA COTISATION',
              style: GoogleFonts.montserrat(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.green,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),

            // Champ montant
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.white07,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.green.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  Text(
                    'Montant à encaisser (FCFA)',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, 
                        fontSize: 10, color: AppColors.white50),
                  ),
                  TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gold,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: TextStyle(color: AppColors.white10),
                    ),
                  ),
                  TextButton(
                      onPressed: () => setState(() => _amountCtrl.text =
                          _montantSuggere.toInt().toString()),
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 28)),
                      child: Text(
                        'Montant suggéré: ${_montantSuggere.toInt()} FCFA',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          color: AppColors.green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Modes de paiement
            Text(
              'MODE DE PAIEMENT',
              style: GoogleFonts.montserrat(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.white50,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: _modes.map((mode) {
                final isSelected = _modeCollecte == mode['id'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _modeCollecte = mode['id'] as String),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (mode['bg'] as Color).withValues(alpha: 0.15)
                            : AppColors.white05,
                        border: Border.all(
                          color: isSelected
                              ? mode['bg'] as Color
                              : AppColors.borderDefault,
                          width: isSelected ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(mode['icon'] as IconData,
                              color: isSelected
                                  ? mode['bg'] as Color
                                  : AppColors.white35,
                              size: 18),
                          const SizedBox(height: 4),
                          Text(
                            mode['label'] as String,
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? mode['bg'] as Color
                                  : AppColors.white50,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Boutons
            if (_isSubmitting)
              const Center(
                  child: CircularProgressIndicator(color: AppColors.green))
            else
              EduButton.green(
                'Valider la cotisation',
                onPressed: () => _submitCotisation(context),
              ),
            const SizedBox(height: 10),
            EduButton.outlined(
              'Annuler',
              onPressed: widget.onCancel,
            ),
          ],
        ),
      ),
    );
  }
}
