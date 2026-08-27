import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/widgets/success_recap_screen.dart';

/// Session expirée après inactivité (motif `g_se` du prototype) — reboucle
/// vers la connexion par PIN.
class SessionExpiredScreen extends StatelessWidget {
  const SessionExpiredScreen({super.key, required this.onReconnect});

  final VoidCallback onReconnect;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.navy,
      child: SuccessRecapScreen(
        icon: Icons.lock_outline,
        iconColor: AppColors.info,
        title: 'Session expirée',
        message:
            'Pour votre sécurité, vous avez été déconnecté après 15 minutes d\'inactivité.',
        primaryActionLabel: 'Se reconnecter',
        onPrimaryAction: onReconnect,
      ),
    );
  }
}
