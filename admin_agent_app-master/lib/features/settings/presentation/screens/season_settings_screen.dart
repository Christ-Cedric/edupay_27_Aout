import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_button.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/app_tag.dart';
import '../../../../core/theme/widgets/app_text_field.dart';
import '../../../../core/theme/widgets/app_toast.dart';
import '../../../../core/theme/widgets/key_value_row.dart';
import '../../../../core/theme/widgets/nav_row.dart';
import '../../../../core/theme/widgets/tap_target.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../families/domain/models/savings_plan.dart';
import '../../../seasons/domain/models/season.dart';
import '../../../seasons/presentation/providers/seasons_providers.dart';

const _planUnits = {
  SavingsPlan.daily: '/jour',
  SavingsPlan.weekly: '/sem.',
  SavingsPlan.monthly: '/mois',
};

final _dateFormat = DateFormat('d MMMM yyyy', 'fr_FR');

/// Paramètres de saison (motif `ad_pa` du prototype) — sert aussi de hub
/// vers Agents terrain, Catalogue de kits et Mon compte (rattachés à cet
/// onglet dans notre arbre de routes, absents de la navigation du
/// prototype, qui ne modélise pas l'authentification Admin/Agent).
class SeasonSettingsScreen extends ConsumerWidget {
  const SeasonSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonAsync = ref.watch(currentSeasonProvider);

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: const AppHeader(title: 'Paramètres'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppNavRow(
            label: 'Mon compte',
            onTap: () => context.push('/admin/settings/account'),
          ),
          AppNavRow(
            label: 'Agents terrain',
            onTap: () => context.push('/admin/settings/agents'),
          ),
          AppNavRow(
            label: 'Catalogue de kits',
            onTap: () => context.push('/admin/settings/kits'),
          ),
          AppNavRow(
            label: 'Journal d\'audit',
            onTap: () => context.push('/admin/settings/audit-logs'),
          ),
          AppNavRow(
            label: 'Gestion des saisons',
            onTap: () => context.push('/admin/settings/seasons'),
          ),
          const SizedBox(height: AppSpacing.md),
          seasonAsync.when(
            data: (season) => _SeasonSection(season: season),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => ErrorScreen(
              onRetry: () => ref.invalidate(currentSeasonProvider),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('TARIFS', style: AppTextStyles.sectionLabel),
          const SizedBox(height: AppSpacing.sm),
          for (final plan in SavingsPlan.values)
            KeyValueRow(
              label: 'Plan ${plan.label.toLowerCase()}',
              value: '${formatCurrency(plan.amount)}${_planUnits[plan]}',
            ),
          KeyValueRow(
            label: 'Frais remboursement',
            value: seasonAsync.maybeWhen(
              data: (season) => formatCurrency(season.refundFee),
              orElse: () => '—',
            ),
            valueColor: AppColors.danger,
            showDivider: false,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('COMMISSIONS AGENTS', style: AppTextStyles.sectionLabel),
          const SizedBox(height: AppSpacing.sm),
          const KeyValueRow(
            label: 'Par inscription',
            value: '200 FCFA/famille',
          ),
          const KeyValueRow(
            label: 'Sur collecte',
            value: '2% par collecte',
            showDivider: false,
          ),
          const SizedBox(height: AppSpacing.md),
          AppNavRow(
            label: 'Déconnexion',
            onTap: () async {
              await ref.read(sessionControllerProvider.notifier).logout();
              if (context.mounted) showAppToast(context, 'Déconnecté(e)');
            },
          ),
        ],
      ),
    );
  }
}

class _SeasonSection extends ConsumerStatefulWidget {
  const _SeasonSection({required this.season});

  final Season season;

  @override
  ConsumerState<_SeasonSection> createState() => _SeasonSectionState();
}

class _SeasonSectionState extends ConsumerState<_SeasonSection> {
  bool _editing = false;
  late DateTime _launchDate;
  late DateTime _deliveryDeadline;
  late bool _enrollmentOpen;
  late final TextEditingController _refundFeeController;

  @override
  void initState() {
    super.initState();
    _resetFromSeason();
  }

  void _resetFromSeason() {
    _launchDate = widget.season.launchDate;
    _deliveryDeadline = widget.season.deliveryDeadline;
    _enrollmentOpen = widget.season.enrollmentOpen;
    _refundFeeController = TextEditingController(
      text: widget.season.refundFee.toString(),
    );
  }

  @override
  void dispose() {
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

  Future<void> _save() async {
    final refundFee = int.tryParse(_refundFeeController.text);
    if (refundFee == null || refundFee < 0) {
      showAppToast(
        context,
        'Frais de remboursement invalide',
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

    final updated = widget.season.copyWith(
      launchDate: _launchDate,
      deliveryDeadline: _deliveryDeadline,
      enrollmentOpen: _enrollmentOpen,
      refundFee: refundFee,
    );
    await ref.read(seasonEditControllerProvider.notifier).save(updated);
    if (!mounted) return;

    if (ref.read(seasonEditControllerProvider).hasError) {
      showAppToast(context, 'Une erreur est survenue', type: AppToastType.error);
      return;
    }
    showAppToast(context, 'Saison mise à jour');
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(seasonEditControllerProvider).isLoading;

    if (!_editing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SAISON EN COURS', style: AppTextStyles.sectionLabel),
              TapTarget(
                onTap: () => setState(() => _editing = true),
                child: Text(
                  'Modifier ✎',
                  style: AppTextStyles.tag.copyWith(color: AppColors.gold),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          KeyValueRow(
            label: 'Saison active',
            value: widget.season.label,
            valueColor: AppColors.gold,
          ),
          KeyValueRow(
            label: 'Date de lancement',
            value: _dateFormat.format(widget.season.launchDate),
          ),
          KeyValueRow(
            label: 'Date limite rentrée',
            value: _dateFormat.format(widget.season.deliveryDeadline),
            valueColor: AppColors.green,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Inscriptions', style: AppTextStyles.bodySecondary),
                AppTag(
                  label: widget.season.enrollmentOpen ? 'Ouvertes' : 'Fermées',
                  variant: widget.season.enrollmentOpen
                      ? AppTagVariant.green
                      : AppTagVariant.danger,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MODIFIER LA SAISON', style: AppTextStyles.sectionLabel),
        const SizedBox(height: AppSpacing.sm),
        _DatePickerRow(
          label: 'Date de lancement',
          value: _launchDate,
          enabled: !saving,
          onTap: () => _pickDate(true),
        ),
        const SizedBox(height: AppSpacing.sm),
        _DatePickerRow(
          label: 'Date limite rentrée',
          value: _deliveryDeadline,
          enabled: !saving,
          onTap: () => _pickDate(false),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          label: 'Frais de remboursement (FCFA)',
          controller: _refundFeeController,
          keyboardType: TextInputType.number,
          enabled: !saving,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Inscriptions ouvertes', style: AppTextStyles.body),
            Switch(
              value: _enrollmentOpen,
              onChanged: saving
                  ? null
                  : (value) => setState(() => _enrollmentOpen = value),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Annuler',
                variant: AppButtonVariant.outline,
                onPressed: saving
                    ? null
                    : () => setState(() {
                        _resetFromSeason();
                        _editing = false;
                      }),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppButton(
                label: 'Enregistrer',
                variant: AppButtonVariant.green,
                loading: saving,
                onPressed: saving ? null : _save,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DatePickerRow extends StatelessWidget {
  const _DatePickerRow({
    required this.label,
    required this.value,
    required this.onTap,
    required this.enabled,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TapTarget(
      onTap: enabled ? onTap : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySecondary),
          Text(_dateFormat.format(value), style: AppTextStyles.bodyStrong),
        ],
      ),
    );
  }
}
