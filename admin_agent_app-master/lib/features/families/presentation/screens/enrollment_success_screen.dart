import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/widgets/success_recap_screen.dart';
import '../../domain/models/family.dart';
import '../../domain/models/savings_plan.dart';

/// Écran de succès après inscription directe (motif `ad_ok` du prototype).
///
/// Réutilisé par l'Admin et l'Agent terrain : chacun fournit ses propres
/// routes de retour plutôt que de les avoir codées en dur ici.
class EnrollmentSuccessScreen extends StatelessWidget {
  const EnrollmentSuccessScreen({
    super.key,
    required this.family,
    required this.onEnrollAnother,
    required this.onBackToDashboard,
  });

  final Family family;
  final VoidCallback onEnrollAnother;
  final VoidCallback onBackToDashboard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SuccessRecapScreen(
        icon: Icons.check_circle,
        title: 'Action enregistrée',
        message: 'Famille inscrite. SMS de bienvenue envoyé.',
        entries: [
          SuccessRecapEntry('Famille', family.fullName),
          SuccessRecapEntry('Plan', family.plan.labelWithAmount),
          SuccessRecapEntry('Agent', family.assignedAgentName ?? '-'),
          const SuccessRecapEntry(
            'Statut',
            'Actif ✓',
            valueColor: AppColors.green,
          ),
        ],
        primaryActionLabel: 'Inscrire une autre famille',
        onPrimaryAction: onEnrollAnother,
        secondaryActionLabel: 'Retour dashboard',
        onSecondaryAction: onBackToDashboard,
      ),
    );
  }
}
