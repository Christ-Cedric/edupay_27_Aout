import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/widgets/app_logo.dart';

/// Écran d'accueil (motif `splash` du prototype) — affiché pendant la
/// restauration de session ; le routeur redirige automatiquement dès que
/// [SessionController] a résolu son état initial.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.navy,
      child: Center(child: AppLogo(fontSize: 34)),
    );
  }
}
