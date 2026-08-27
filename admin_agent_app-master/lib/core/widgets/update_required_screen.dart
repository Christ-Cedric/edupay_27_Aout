import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/widgets/success_recap_screen.dart';

/// Mise à jour disponible/requise (motif `g_up` du prototype).
class UpdateRequiredScreen extends StatelessWidget {
  const UpdateRequiredScreen({
    super.key,
    required this.onUpdate,
    this.onLater,
    this.versionLabel = 'Version 1.2',
    this.highlights = const [
      'Catalogue de kits amélioré',
      'Performances paiement optimisées',
      'Suivi livraison temps réel',
    ],
  });

  final VoidCallback onUpdate;
  final VoidCallback? onLater;
  final String versionLabel;
  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.navy,
      child: SuccessRecapScreen(
        icon: Icons.system_update_alt,
        iconColor: AppColors.gold,
        title: 'Mise à jour disponible',
        message: '$versionLabel avec des améliorations importantes.',
        entries: [
          for (final highlight in highlights)
            SuccessRecapEntry('✦ $highlight', ''),
        ],
        primaryActionLabel: 'Mettre à jour maintenant',
        onPrimaryAction: onUpdate,
        secondaryActionLabel: onLater != null ? 'Plus tard' : null,
        onSecondaryAction: onLater,
      ),
    );
  }
}
