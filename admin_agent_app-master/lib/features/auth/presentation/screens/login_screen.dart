import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/widgets/app_button.dart';
import '../../../../core/theme/widgets/app_logo.dart';
import '../../../../core/theme/widgets/app_text_field.dart';
import '../../domain/models/auth_failure.dart';
import '../providers/auth_providers.dart';

/// Message affiché à l'utilisateur à partir de l'erreur de connexion.
///
/// Le backend distingue déjà "identifiants invalides" de "compte désactivé"
/// (contrat §1.1 — `ApiException.message`) ; en mode mock, [AuthFailure]
/// porte le même rôle. Sans ce mapping, un agent suspendu verrait "Numéro ou
/// mot de passe incorrect" au lieu de "Ce compte est désactivé", et essaierait
/// en boucle son mot de passe au lieu de contacter l'admin.
String _loginErrorMessage(Object? error) => switch (error) {
  ApiException(:final message) => message,
  AuthFailure(:final message) => message,
  _ => 'Numéro ou mot de passe incorrect',
};

/// Connexion par téléphone + mot de passe — mode de connexion commun à
/// l'Admin et à l'Agent terrain (un compte admin existe par défaut dès le
/// premier lancement ; chaque agent reçoit ses accès à sa création par
/// l'admin). Aucune auto-inscription : les comptes sont créés par l'admin.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ref
        .read(sessionControllerProvider.notifier)
        .login(
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionControllerProvider);
    final submitting = sessionState.isLoading;
    final errorMessage = sessionState.hasError
        ? _loginErrorMessage(sessionState.error)
        : null;

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppLogo(fontSize: 30),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      label: 'Téléphone',
                      controller: _phoneController,
                      hintText: '+226 76 69 19 11',
                      keyboardType: TextInputType.phone,
                      enabled: !submitting,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Mot de passe',
                      controller: _passwordController,
                      obscureText: true,
                      enableObscureToggle: true,
                      enabled: !submitting,
                      errorText: errorMessage,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Se connecter',
                      loading: submitting,
                      onPressed: submitting ? null : _submit,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const Text(
                      'Problème ? Contactez le support',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
