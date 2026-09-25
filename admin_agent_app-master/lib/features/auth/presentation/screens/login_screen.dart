import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/widgets/app_logo.dart';
import '../../../../core/theme/widgets/app_text_field.dart';
import '../../domain/models/auth_failure.dart';
import '../providers/auth_providers.dart';

/// Message affiché à l'utilisateur à partir de l'erreur de connexion.
String _loginErrorMessage(Object? error) => switch (error) {
      ApiException(:final message) => message,
      AuthFailure(:final message) => message,
      _ => 'Numéro ou mot de passe incorrect',
    };

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
    await ref.read(sessionControllerProvider.notifier).login(
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

    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 940 : 460,
              maxHeight: isDesktop ? 600 : double.infinity,
            ),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: isDesktop
                ? Row(
                    children: [
                      // Panel Gauche : Formulaire
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: _buildLoginForm(submitting, errorMessage),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Panel Droit : Illustration & Branding
                      Expanded(
                        flex: 5,
                        child: _buildRightBanner(),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: _buildLoginForm(submitting, errorMessage),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(bool submitting, String? errorMessage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppLogo(fontSize: 26),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Bon retour !',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w800,
                fontSize: 26,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Veuillez entrer vos identifiants pour vous connecter.',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
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
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Se connecter',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Veuillez contacter l\'administrateur système pour réinitialiser vos accès.',
                ),
              ),
            );
          },
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
              children: [
                TextSpan(text: 'Problème ? '),
                TextSpan(
                  text: 'Contactez le support',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightBanner() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1D4ED8), // Bleu éclatant haut
            Color(0xFF1E3A8A), // Bleu profond milieu
            Color(0xFF0F172A), // Bleu nuit bas
          ],
        ),
      ),
      child: Stack(
        children: [
          // Effet de halo / arc au bas du panneau
          Positioned(
            bottom: -80,
            left: -40,
            right: -40,
            height: 260,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3B82F6).withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                  radius: 0.85,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Badge "E"
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'E',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Plateforme Administrative',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Gestion sécurisée des paiements scolaires',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 13,
                    color: Color(0xB3FFFFFF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
