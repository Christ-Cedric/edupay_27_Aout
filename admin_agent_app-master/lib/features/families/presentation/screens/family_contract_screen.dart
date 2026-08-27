import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_card.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/key_value_row.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../domain/models/savings_plan.dart';
import '../providers/families_providers.dart';
import '../widgets/family_status_tag.dart';

/// Récapitulatif d'engagement d'une famille (motif absent du prototype,
/// aucune donnée de contrat réelle n'existe — simple récap dérivé des
/// informations déjà connues, pas un document PDF).
class FamilyContractScreen extends ConsumerWidget {
  const FamilyContractScreen({super.key, required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyAsync = ref.watch(familyDetailProvider(familyId));

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(
        title: "Contrat d'engagement",
        onBack: () => context.pop(),
      ),
      body: familyAsync.when(
        data: (family) => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(family.fullName, style: AppTextStyles.h2),
                FamilyStatusTag(status: family.status),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              "Cet écran récapitule l'engagement de cotisation du client "
              "auprès d'EduP@y — pas un document officiel.",
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Column(
                children: [
                  KeyValueRow(label: 'Téléphone', value: family.phone),
                  KeyValueRow(label: 'Ville', value: family.city),
                  KeyValueRow(
                    label: "Plan d'épargne",
                    value: family.plan.labelWithAmount,
                  ),
                  KeyValueRow(
                    label: "Date d'inscription",
                    value: DateFormat(
                      'd MMMM yyyy',
                      'fr_FR',
                    ).format(family.registeredAt),
                  ),
                  KeyValueRow(
                    label: 'Objectif',
                    value: formatCurrency(family.targetAmount),
                  ),
                  KeyValueRow(
                    label: 'Solde actuel',
                    value: formatCurrency(family.balance),
                    valueColor: AppColors.gold,
                    showDivider: false,
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const LoadingScreen(),
        error: (error, stackTrace) => ErrorScreen(
          onRetry: () => ref.invalidate(familyDetailProvider(familyId)),
        ),
      ),
    );
  }
}
