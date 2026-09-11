// =============================================================================
// FEATURES/AGENT/SCREENS/AG_RECU_SCREEN.DART
// =============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import 'ag_encaisser_screen.dart';
import 'ag_dashboard_screen.dart';

class AgRecuScreen extends StatelessWidget {
  final String modeCollecte;
  final String clientName;
  final double amount;
  final String? transactionId;

  const AgRecuScreen({
    super.key,
    this.modeCollecte = 'CASH',
    required this.clientName,
    required this.amount,
    this.transactionId,
  });

  String get _modeLabel {
    switch (modeCollecte) {
      case 'ORANGE_MONEY':
        return 'Orange Money';
      case 'MOOV_MONEY':
        return 'Moov Money';
      case 'WAVE':
        return 'Wave';
      default:
        return 'Espèces';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Icone succès
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppColors.background, size: 36),
              ),
              const SizedBox(height: 16),

              Text(
                'Encaissement validé',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Reçu envoyé à $clientName par WhatsApp',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, 
                    fontSize: 12, color: AppColors.white50),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Récapitulatif
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white05,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      _recuRow('N° Reçu', transactionId ?? 'EP-RC-NEW'),
                      _recuRow('Client', clientName),
                      _recuRow('Montant', '${amount.toStringAsFixed(0)} FCFA'),
                      _recuRow('Mode', _modeLabel, showDivider: false),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    EduButton.green(
                      'Encaisser un autre',
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AgEncaisserScreen()),
                      ),
                    ),
                    const SizedBox(height: 8),
                    EduButton.outlined(
                      'Retour dashboard',
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AgDashboardScreen()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recuRow(String label, String value,
      {Color? valueColor, bool showDivider = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 1)))
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.white70)),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
