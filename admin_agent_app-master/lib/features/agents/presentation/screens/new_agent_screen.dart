import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_button.dart';
import '../../../../core/theme/widgets/app_dropdown_field.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/app_text_field.dart';
import '../../../../core/theme/widgets/app_toast.dart';
import '../../../../core/theme/widgets/selectable_card.dart';
import '../../../../core/domain/burkina_city.dart';
import '../../domain/models/agent.dart';
import '../providers/agents_providers.dart';

/// Création d'un agent terrain (motif `ad_na` du prototype).
class NewAgentScreen extends ConsumerStatefulWidget {
  const NewAgentScreen({super.key});

  @override
  ConsumerState<NewAgentScreen> createState() => _NewAgentScreenState();
}

class _NewAgentScreenState extends ConsumerState<NewAgentScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _districtController = TextEditingController();
  BurkinaCity _zone = BurkinaCity.values.first;
  AgentContractType _contractType = AgentContractType.volunteer;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      showAppToast(
        context,
        'Renseignez tous les champs requis',
        type: AppToastType.error,
      );
      return;
    }
    if (_passwordController.text.length < 6) {
      showAppToast(
        context,
        'Le mot de passe doit contenir au moins 6 caractères',
        type: AppToastType.error,
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      showAppToast(
        context,
        'Les mots de passe ne correspondent pas',
        type: AppToastType.error,
      );
      return;
    }

    await ref
        .read(newAgentControllerProvider.notifier)
        .create(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          zone: _zone.label,
          district: _districtController.text.trim().isEmpty
              ? null
              : _districtController.text.trim(),
          contractType: _contractType,
        );
    if (!mounted) return;

    if (ref.read(newAgentControllerProvider).hasError) {
      showAppToast(
        context,
        'Une erreur est survenue',
        type: AppToastType.error,
      );
      return;
    }
    showAppToast(context, 'Agent créé !');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final submitting = ref.watch(newAgentControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(title: 'Ajouter un agent', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ListView(
          children: [
            const Text('Nouvel agent terrain', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Définissez les identifiants de connexion de l\'agent',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Nom et prénom',
              controller: _nameController,
              hintText: 'Kabore Wendyam',
              enabled: !submitting,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Téléphone',
              controller: _phoneController,
              hintText: '+226 74 11 22 33',
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
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Confirmer le mot de passe',
              controller: _confirmPasswordController,
              obscureText: true,
              enableObscureToggle: true,
              enabled: !submitting,
            ),
            const SizedBox(height: AppSpacing.md),
            AppDropdownField<BurkinaCity>(
              label: "Zone d'intervention",
              value: _zone,
              items: BurkinaCity.values
                  .map(
                    (city) =>
                        DropdownMenuItem(value: city, child: Text(city.label)),
                  )
                  .toList(),
              onChanged: submitting
                  ? null
                  : (zone) => setState(() => _zone = zone!),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Quartier (optionnel)',
              controller: _districtController,
              hintText: 'Secteur 15',
              enabled: !submitting,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('TYPE DE CONTRAT', style: AppTextStyles.fieldLabel),
            const SizedBox(height: AppSpacing.xs),
            for (final type in AgentContractType.values)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: SelectableCard(
                  title: type.label,
                  selected: _contractType == type,
                  onTap: () => setState(() => _contractType = type),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Créer le compte agent',
              loading: submitting,
              onPressed: submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
