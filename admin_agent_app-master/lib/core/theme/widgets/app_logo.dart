import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Fond sur lequel le logo est posé — détermine la couleur du segment "Edu".
enum AppLogoBackground { dark, light }

/// Logo officiel EduP@y : "Edu"+"P"+"@"+"y", toujours en un seul mot.
///
/// Couleurs imposées par la charte graphique : "Edu" en blanc (ou bleu nuit
/// sur fond clair), "P" et "y" en Vert Vif, "@" en Jaune Soleil. Une zone de
/// protection (espace libre équivalent à la hauteur du "E") entoure
/// toujours le logo — ne jamais recomposer ces lettres à la main ailleurs.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.fontSize = 28,
    this.background = AppLogoBackground.dark,
  });

  final double fontSize;
  final AppLogoBackground background;

  @override
  Widget build(BuildContext context) {
    final eduColor = background == AppLogoBackground.dark
        ? Colors.white
        : AppColors.navy;
    final style = TextStyle(
      fontFamily: 'Montserrat',
      fontWeight: FontWeight.w800,
      fontSize: fontSize,
      height: 1,
    );
    // Zone de protection charte : espace libre ≈ hauteur du "E" (cap-height).
    final protectionSpace = fontSize * 0.75;

    return Padding(
      padding: EdgeInsets.all(protectionSpace),
      child: RichText(
        text: TextSpan(
          style: style,
          children: [
            TextSpan(
              text: 'Edu',
              style: TextStyle(color: eduColor),
            ),
            const TextSpan(
              text: 'P',
              style: TextStyle(color: AppColors.green),
            ),
            const TextSpan(
              text: '@',
              style: TextStyle(color: AppColors.gold),
            ),
            const TextSpan(
              text: 'y',
              style: TextStyle(color: AppColors.green),
            ),
          ],
        ),
      ),
    );
  }
}
