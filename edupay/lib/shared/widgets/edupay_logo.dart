import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class EduPayLogo extends StatelessWidget {
  const EduPayLogo({super.key, this.size = 24, this.color});

  final double size;

  /// Force la couleur du bloc « Edu » ; par défaut il suit le texte principal
  /// du mode (bleu nuit en Light, blanc en Dark) — comme le logo sur fond blanc.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w800,
          fontSize: size,
        ),
        children: [
          TextSpan(
            text: 'Edu',
            style: TextStyle(color: color ?? palette.textPrimary),
          ),
          TextSpan(
            text: 'P',
            style: TextStyle(color: palette.accentGreen),
          ),
          const TextSpan(
            text: '@',
            style: TextStyle(color: AppColors.sunYellow),
          ),
          TextSpan(
            text: 'y',
            style: TextStyle(color: palette.accentGreen),
          ),
        ],
      ),
    );
  }
}
