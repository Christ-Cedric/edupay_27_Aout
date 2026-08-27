import 'package:flutter/material.dart';

import '../app_spacing.dart';

/// Enveloppe un élément tappable compact (lien texte, icône isolée...) pour
/// garantir une zone tactile d'au moins [AppSpacing.minTapTarget] même quand
/// le contenu visuel est plus petit — charte graphique, principe non
/// négociable n°1. À utiliser à la place d'un [GestureDetector] nu dès que
/// le contenu enveloppé ne remplit pas déjà cette taille par lui-même.
class TapTarget extends StatelessWidget {
  const TapTarget({super.key, required this.onTap, required this.child});

  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppSpacing.minTapTarget,
          minWidth: AppSpacing.minTapTarget,
        ),
        child: Center(child: child),
      ),
    );
  }
}
