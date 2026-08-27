import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/action_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/password_text_field.dart';
import '../parent_scope.dart';
import 'page_scaffold.dart';

/// Onboarding is strictly limited to account activation (Phone, OTP,
/// Profil parent) — no plan, kit, or contribution logic lives here. See
/// ai_context/BUSINESS_RULES.md « Flux de l'Onboarding et Responsabilité ».
class ProfileFormPage extends StatelessWidget {
  const ProfileFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);

    return ParentPageScaffold(
      children: [
        const PageTitle(
          'Vos informations',
          subtitle: 'Ces informations figureront sur votre contrat.',
        ),
        _FieldLabel('Prénom et nom'),
        TextField(controller: state.nameController),
        const SizedBox(height: 26),
        _FieldLabel('Ville'),
        DropdownButtonFormField<String>(
          initialValue: state.cityController.text.isEmpty
              ? null
              : state.cityController.text,
          items: ['Ouagadougou', 'Koudougou', 'Bobo-Dioulasso'].map((ville) {
            return DropdownMenuItem(value: ville, child: Text(ville));
          }).toList(),
          onChanged: (value) {
            state.cityController.text = value!;
          },
        ),
        const SizedBox(height: 26),
        _FieldLabel('Quartier'),
        TextField(controller: state.districtController),
        const SizedBox(height: 26),
        _FieldLabel('Mot de passe'),
        PasswordTextField(
          controller: state.passwordController,
          decoration: const InputDecoration(hintText: 'Au moins 8 caractères'),
        ),
        const SizedBox(height: 26),
        _FieldLabel('Confirmer le mot de passe'),
        PasswordTextField(controller: state.confirmPasswordController),
        const SizedBox(height: 40),
        ActionButton(
          label: 'Continuer',
          onPressed: () async {
            final ok = await state.registerAccount();
            if (!context.mounted) return;
            if (ok) {
              context.go('/onboarding/success');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.lastError?.toString() ??
                        'Impossible de créer le compte.',
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

/// Libellé de champ (accent de marque), adapté au mode.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: context.palette.accentGreen,
      ),
    );
  }
}

class RegistrationSuccessPage extends StatelessWidget {
  const RegistrationSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;

    return ColoredBox(
      color: palette.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const Spacer(),
              Icon(Icons.celebration, color: palette.accentGreen, size: 76),
              const SizedBox(height: 16),
              Text(
                'Bienvenue dans EduP@y !',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w800,
                  fontSize: 21,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Votre compte est prêt, ${state.displayName}. Ajoutez vos enfants pour démarrer une épargne scolaire.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.onSurface(.62),
                  fontSize: 13,
                  height: 1.4,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 20),
              AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    _SummaryRow(label: 'Famille', value: state.displayName),
                    Divider(height: 1, color: palette.hairline),
                    _SummaryRow(
                      label: 'Numéro',
                      value: state.profile?.phone ?? state.phoneController.text,
                    ),
                    Divider(height: 1, color: palette.hairline),
                    _SummaryRow(
                      label: 'Ville',
                      value: state.profile?.city ?? state.cityController.text,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ActionButton(
                label: 'Accéder à mon espace',
                icon: Icons.home,
                onPressed: () {
                  context.go('/app/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: TextStyle(
                color: context.palette.onSurface(.58),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
