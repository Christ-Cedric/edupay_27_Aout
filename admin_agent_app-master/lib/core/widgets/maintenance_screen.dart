import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/widgets/success_recap_screen.dart';

/// Maintenance programmée (motif `g_mn` du prototype).
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({
    super.key,
    required this.onContactSupport,
    this.estimatedDuration = '15 minutes',
  });

  final VoidCallback onContactSupport;
  final String estimatedDuration;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.navy,
      child: SuccessRecapScreen(
        icon: Icons.build_outlined,
        iconColor: AppColors.gold,
        title: 'Maintenance en cours',
        message:
            'EduP@y effectue une maintenance programmée. Retour dans quelques minutes. '
            'Durée estimée : $estimatedDuration.',
        primaryActionLabel: 'Contacter le support',
        onPrimaryAction: onContactSupport,
      ),
    );
  }
}
