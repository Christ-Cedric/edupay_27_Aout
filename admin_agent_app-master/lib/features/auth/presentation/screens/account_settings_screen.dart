import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_button.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/app_text_field.dart';
import '../../../../core/theme/widgets/app_toast.dart';
import '../providers/auth_providers.dart';

/// "Mon compte" — permet à l'utilisateur connecté (admin, seedé par défaut
/// au premier lancement) de modifier son téléphone et/ou son mot de passe.
/// N'existe pas dans le prototype (qui ne modélise pas l'authentification
/// Admin/Agent) — ajouté à la demande du client.
class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  late final TextEditingController _phoneController;
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_phoneController.text.trim().isEmpty) {
      showAppToast(
        context,
        'Le téléphone est requis',
        type: AppToastType.error,
      );
      return;
    }
    if (_newPasswordController.text.isNotEmpty &&
        _newPasswordController.text.length < 6) {
      showAppToast(
        context,
        'Le mot de passe doit contenir au moins 6 caractères',
        type: AppToastType.error,
      );
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      showAppToast(
        context,
        'Les mots de passe ne correspondent pas',
        type: AppToastType.error,
      );
      return;
    }

    await ref
        .read(sessionControllerProvider.notifier)
        .updateCredentials(
          newPhone: _phoneController.text.trim(),
          newPassword: _newPasswordController.text.isEmpty
              ? null
              : _newPasswordController.text,
        );
    if (!mounted) return;

    if (ref.read(sessionControllerProvider).hasError) {
      showAppToast(
        context,
        'Une erreur est survenue',
        type: AppToastType.error,
      );
      return;
    }
    showAppToast(context, 'Identifiants mis à jour !');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider).value;
    final saving = ref.watch(sessionControllerProvider).isLoading;

    if (!_initialized && session != null) {
      _phoneController = TextEditingController(text: session.phone);
      _initialized = true;
    } else if (!_initialized) {
      _phoneController = TextEditingController();
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(title: 'Mon compte', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ListView(
          children: [
            if (session != null) ...[
              Text(session.displayName, style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Modifiez votre téléphone ou votre mot de passe',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            AppTextField(
              label: 'Téléphone',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              enabled: !saving,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Nouveau mot de passe',
              controller: _newPasswordController,
              hintText: 'Laisser vide pour ne pas changer',
              obscureText: true,
              enableObscureToggle: true,
              enabled: !saving,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Confirmer le nouveau mot de passe',
              controller: _confirmPasswordController,
              obscureText: true,
              enableObscureToggle: true,
              enabled: !saving,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Enregistrer',
              variant: AppButtonVariant.green,
              loading: saving,
              onPressed: saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
