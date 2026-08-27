// =============================================================================
// FEATURES/AGENT/SCREENS/AG_QR_CODE_CLIENT_SCREEN.DART
// Affichage QR code après inscription + export PDF
// =============================================================================
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/models/client_model.dart';
import 'ag_clients_screen.dart';

class AgQrCodeClientScreen extends StatefulWidget {
  final ClientModel client;
  final bool isFromRegistration;

  const AgQrCodeClientScreen({
    super.key,
    required this.client,
    this.isFromRegistration = true,
  });

  @override
  State<AgQrCodeClientScreen> createState() => _AgQrCodeClientScreenState();
}

class _AgQrCodeClientScreenState extends State<AgQrCodeClientScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _pulseAnim;
  bool _isGeneratingPdf = false;

  String get _qrData {
    // Le widget Barcode plante si la donnée est vide. On met une valeur de fallback.
    final code = widget.client.familyCode ?? '';
    return code.isNotEmpty ? code : 'EN-ATTENTE';
  }

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _generateAndSharePdf() async {
    setState(() => _isGeneratingPdf = true);
    try {
      final client = widget.client;
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // ── En-tête ──────────────────────────────────────────────
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.teal700,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'EduPay',
                        style: pw.TextStyle(
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Épargne Scolaire - Carte d\'adhésion famille',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // ── QR Code ──────────────────────────────────────────────
                pw.Text(
                  'Scannez ce code pour encaisser la cotisation',
                  style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 12),
                pw.Container(
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.teal700, width: 2.5),
                    borderRadius: pw.BorderRadius.circular(12),
                    color: PdfColors.white,
                  ),
                  child: pw.BarcodeWidget(
                    data: _qrData,
                    width: 180,
                    height: 180,
                    barcode: pw.Barcode.qrCode(
                      errorCorrectLevel: pw.BarcodeQRCorrectionLevel.medium,
                    ),
                    color: PdfColors.blueGrey900,
                    backgroundColor: PdfColors.white,
                    drawText: false,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Code: ${client.familyCode ?? ''}',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.teal700,
                  ),
                ),
                pw.SizedBox(height: 20),

                // ── Informations client ───────────────────────────────────
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(10),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INFORMATIONS DU CLIENT',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.teal700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      _pdfRow('Nom complet', client.fullName),
                      _pdfRow('Code client', client.familyCode ?? ''),
                      _pdfRow('Téléphone', client.phone),
                      _pdfRow('Quartier / Adresse', client.address),
                      _pdfRow(
                        'Date d\'inscription',
                        DateFormat('dd/MM/yyyy').format(DateTime.now()),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 12),

                // ── Enfants inscrits ──────────────────────────────────────
                if (client.children != null && client.children!.isNotEmpty) ...[
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green50,
                      borderRadius: pw.BorderRadius.circular(10),
                      border: pw.Border.all(color: PdfColors.green200),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'ENFANTS INSCRITS (${client.children!.length})',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.teal700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        for (var i = 0; i < client.children!.length; i++) ...[
                          if (i > 0)
                            pw.Divider(color: PdfColors.green200, height: 12),
                          pw.Text(
                            'Enfant ${i + 1} - ${client.children![i].firstName}',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blueGrey800,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          if (client.children![i].school != null &&
                              client.children![i].school!.isNotEmpty)
                            _pdfRowSmall('École', client.children![i].school!),
                          if (client.children![i].kitId != null) ...[
                            _pdfRowSmall('Kit d\'épargne', 'Kit Scolaire'),
                            _pdfRowSmall(
                              'Objectif total',
                              '${client.children![i].targetAmount?.toInt() ?? 0} FCFA',
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ] else ...[
                  // Fallback rétrocompatibilité (client sans enfants modélisés)
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green50,
                      borderRadius: pw.BorderRadius.circular(10),
                      border: pw.Border.all(color: PdfColors.green200),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'PLAN D\'ÉPARGNE',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.teal700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        _pdfRow('Plan', client.plan),
                        _pdfRow(
                          'Objectif total',
                          '${client.targetAmount.toInt()} FCFA',
                        ),
                      ],
                    ),
                  ),
                ],

                pw.Spacer(),
                pw.Text(
                  'EduPay - Épargne Scolaire | Burkina Faso',
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                ),
              ],
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();
      final safeName = client.fullName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final safeCode = client.familyCode ?? 'Client';

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'EduPay_${safeCode}_$safeName.pdf',
      );
    } catch (e) {
      if (mounted) {
        showEduToast(
          context,
          'Erreur génération PDF: ${e.toString().substring(0, e.toString().length.clamp(0, 80))}',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 7),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfRowSmall(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final client = widget.client;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            // Header avec gradient vert
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF00C853), Color(0xFF00897B)],
                ),
              ),
              child: Stack(
                children: [
                  if (!widget.isFromRegistration)
                    Positioned(
                      left: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  Column(
                    children: [
                      // Icône succès
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.isFromRegistration
                              ? Icons.check_circle_rounded
                              : Icons.qr_code_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.isFromRegistration
                            ? 'Client inscrit !'
                            : 'QR Code du client',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Voici la carte QR de ${client.fullName}',
                        style: GoogleFonts.openSans(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Carte QR Code
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.green.withValues(alpha: 0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.green.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Nom du client
                          Text(
                            client.fullName.toUpperCase(),
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.green.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              client.familyCode ?? '',
                              style: GoogleFonts.openSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.green,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // QR Code animé
                          ScaleTransition(
                            scale: _pulseAnim,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.green.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: QrImageView(
                                data: _qrData,
                                version: QrVersions.auto,
                                size: 190,
                                errorCorrectionLevel: QrErrorCorrectLevel.M,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: Color(0xFF0A1628),
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: Color(0xFF0A1628),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Scanner pour encaisser la cotisation',
                            style: GoogleFonts.openSans(
                              fontSize: 10,
                              color: AppColors.white50,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Infos du client
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderDefault),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'IDENTIFIANTS DU CLIENT',
                            style: GoogleFonts.openSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.green,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _infoRow(
                            Icons.person_outline,
                            'Nom complet',
                            client.fullName,
                          ),
                          _infoRow(
                            Icons.qr_code,
                            'Code client',
                            client.familyCode ?? '',
                          ),
                          _infoRow(
                            Icons.phone_outlined,
                            'Téléphone',
                            client.phone,
                          ),
                          if (client.temporaryPassword != null) ...[
                            _infoRow(
                              Icons.lock_outline,
                              'Mot de passe temporaire',
                              client.temporaryPassword!,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Remettez ces identifiants au client pour sa première connexion dans l’application client.',
                                style: GoogleFonts.openSans(
                                  fontSize: 10,
                                  color: AppColors.gold,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                          _infoRow(
                            Icons.location_on_outlined,
                            'Adresse',
                            client.address,
                          ),
                          if (client.children != null &&
                              client.children!.isNotEmpty) ...[
                            for (
                              var i = 0;
                              i < client.children!.length;
                              i++
                            ) ...[
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  bottom: 4,
                                ),
                                child: Text(
                                  'ENFANT ${i + 1}',
                                  style: GoogleFonts.openSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.green,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              _infoRow(
                                Icons.child_care_outlined,
                                'Prénom',
                                client.children![i].firstName,
                              ),
                              if (client.children![i].school != null)
                                _infoRow(
                                  Icons.school_outlined,
                                  'École',
                                  client.children![i].school!,
                                ),
                              if (client.children![i].targetAmount != null &&
                                  client.children![i].targetAmount! > 0)
                                _infoRow(
                                  Icons.savings_outlined,
                                  'Objectif',
                                  '${client.children![i].targetAmount!.toInt()} FCFA',
                                  valueColor: AppColors.gold,
                                ),
                            ],
                          ] else ...[
                            // Fallback pour rétrocompatibilité
                            _infoRow(
                              Icons.savings_outlined,
                              'Plan d\'épargne',
                              'Plan ${client.plan}',
                            ),
                            _infoRow(
                              Icons.attach_money,
                              'Objectif total',
                              '${client.targetAmount.toInt()} FCFA',
                              valueColor: AppColors.gold,
                            ),
                          ],
                          _infoRow(
                            Icons.calendar_today_outlined,
                            'Inscrit le',
                            DateFormat('dd/MM/yyyy').format(DateTime.now()),
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bouton PDF
                    _isGeneratingPdf
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.borderDefault,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: AppColors.green,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Génération du PDF...',
                                  style: GoogleFonts.openSans(
                                    fontSize: 12,
                                    color: AppColors.white70,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _buildPdfButton(),
                    const SizedBox(height: 10),

                    // Bouton Terminer
                    EduButton.outlined(
                      widget.isFromRegistration ? 'Terminer' : 'Retour',
                      onPressed: () {
                        if (widget.isFromRegistration) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AgClientsScreen(),
                            ),
                            (route) => false,
                          );
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfButton() {
    return GestureDetector(
      onTap: _generateAndSharePdf,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1565C0).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.picture_as_pdf_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'Afficher / Sauvegarder le PDF',
              style: GoogleFonts.openSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: AppColors.white35, size: 15),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.openSans(
                  fontSize: 11,
                  color: AppColors.white50,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  value,
                  style: GoogleFonts.openSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? AppColors.white,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(color: AppColors.divider, height: 1),
      ],
    );
  }
}
