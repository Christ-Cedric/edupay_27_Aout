import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_text_styles.dart';

/// Dialog de confirmation Oui/Annuler avant une action sensible (suspendre un
/// agent, supprimer un kit...). Renvoie `true` si l'utilisateur confirme,
/// `false`/`null` sinon (annulation ou fermeture par tap en dehors).
///
/// Style calqué sur `_askReason` (motif de rejet, `pending_validation_list_screen.dart`).
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirmer',
  bool danger = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(title, style: AppTextStyles.bodyStrong),
      content: Text(message, style: AppTextStyles.body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            confirmLabel,
            style: danger ? const TextStyle(color: AppColors.danger) : null,
          ),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
