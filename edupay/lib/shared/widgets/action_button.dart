import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.secondary = false,
    this.danger = false,
    this.isLarge = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool secondary;
  final bool danger;

  /// Variante « CTA principal » : bouton plus haut et texte agrandi.
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 10),
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    final largeStyle = isLarge
        ? const ButtonStyle(
            minimumSize: WidgetStatePropertyAll(Size.fromHeight(56)),
            textStyle: WidgetStatePropertyAll(
              TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          )
        : null;

    if (secondary || danger) {
      final dangerColor = context.palette.danger;
      final base = danger
          ? OutlinedButton.styleFrom(
              foregroundColor: dangerColor,
              side: BorderSide(color: dangerColor),
            )
          : null;
      return OutlinedButton(
        onPressed: onPressed,
        style: largeStyle == null
            ? base
            : (base?.merge(largeStyle) ?? largeStyle),
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: largeStyle,
      child: child,
    );
  }
}
