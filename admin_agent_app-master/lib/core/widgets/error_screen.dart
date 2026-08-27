import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/widgets/app_card.dart';
import '../theme/widgets/success_recap_screen.dart';

/// Écran d'erreur serveur générique (motif `g_er` du prototype), réutilise
/// le motif de récap de succès pour la confirmation visuelle du fallback.
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
    required this.onRetry,
    this.title = 'Erreur de connexion',
    this.message =
        'Impossible de contacter les serveurs EduP@y. Vérifiez votre connexion internet.',
    this.onContactSupport,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onContactSupport;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.navy,
      child: SuccessRecapScreen(
        icon: Icons.wifi_off,
        iconVariant: AppCardVariant.danger,
        title: title,
        message: message,
        primaryActionLabel: 'Réessayer',
        onPrimaryAction: onRetry,
        secondaryActionLabel: onContactSupport != null
            ? 'Contacter le support'
            : null,
        onSecondaryAction: onContactSupport,
      ),
    );
  }
}
