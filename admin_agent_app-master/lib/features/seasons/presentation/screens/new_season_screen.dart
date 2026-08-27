import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_button.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/app_text_field.dart';
import '../../../../core/theme/widgets/app_toast.dart';
import '../../../../core/theme/widgets/tap_target.dart';
import '../../domain/models/season.dart';
import '../providers/seasons_providers.dart';

final _dateFormat = DateFormat('d MMMM yyyy', 'fr_FR');

/// Création d'une nouvelle saison (motif `NewAgentScreen`/`NewKitScreen`,
/// appliqué aux saisons). Ne devient jamais courante automatiquement — voir
/// [SeasonsListScreen] pour basculer la saison courante après création.
class NewSeasonScreen extends ConsumerStatefulWidget {
  const NewSeasonScreen({super.key});

  @override
  ConsumerState<NewSeasonScreen> createState() => _NewSeasonScreenState();
}

class _NewSeasonScreenState extends ConsumerState<NewSeasonScreen> {
  final _labelController = TextEditingController();
  final _refundFeeController = TextEditingController(text: '500');
  DateTime _launchDate = DateTime.now();
  DateTime _deliveryDeadline = DateTime.now().add(const Duration(days: 90));
  bool _enrollmentOpen = true;

  @override
  void dispose() {
    _labelController.dispose();
    _refundFeeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isLaunch) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isLaunch ? _launchDate : _deliveryDeadline,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isLaunch) {
        _launchDate = picked;
      } else {
        _deliveryDeadline = picked;
      }
    });
  }

  Future<void> _submit() async {
    final label = _labelController.text.trim();
    final refundFee = int.tryParse(_refundFeeController.text);

    if (label.length < 4 || refundFee == null || refundFee < 0) {
      showAppToast(
        context,
        'Renseignez tous les champs requis',
        type: AppToastType.error,
      );
      return;
    }
    if (!_deliveryDeadline.isAfter(_launchDate)) {
      showAppToast(
        context,
        'La date limite doit être après le lancement',
        type: AppToastType.error,
      );
      return;
    }

    await ref
        .read(seasonCreateControllerProvider.notifier)
        .create(
          Season(
            id: '',
            label: label,
            launchDate: _launchDate,
            deliveryDeadline: _deliveryDeadline,
            enrollmentOpen: _enrollmentOpen,
            refundFee: refundFee,
            isCurrent: false,
          ),
        );
    if (!mounted) return;

    if (ref.read(seasonCreateControllerProvider).hasError) {
      showAppToast(context, 'Une erreur est survenue', type: AppToastType.error);
      return;
    }
    showAppToast(context, 'Saison créée');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final submitting = ref.watch(seasonCreateControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(title: 'Nouvelle saison', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ListView(
          children: [
            const Text('Créer une saison', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Ne devient pas automatiquement la saison courante.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Libellé (ex. 2026-2027)',
              controller: _labelController,
              hintText: '2026-2027',
              enabled: !submitting,
            ),
            const SizedBox(height: AppSpacing.md),
            TapTarget(
              onTap: submitting ? null : () => _pickDate(true),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Date de lancement', style: AppTextStyles.bodySecondary),
                  Text(_dateFormat.format(_launchDate), style: AppTextStyles.bodyStrong),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TapTarget(
              onTap: submitting ? null : () => _pickDate(false),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Date limite rentrée', style: AppTextStyles.bodySecondary),
                  Text(
                    _dateFormat.format(_deliveryDeadline),
                    style: AppTextStyles.bodyStrong,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Frais de remboursement (FCFA)',
              controller: _refundFeeController,
              keyboardType: TextInputType.number,
              enabled: !submitting,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Inscriptions ouvertes', style: AppTextStyles.body),
                Switch(
                  value: _enrollmentOpen,
                  onChanged: submitting
                      ? null
                      : (value) => setState(() => _enrollmentOpen = value),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Créer la saison',
              loading: submitting,
              onPressed: submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
