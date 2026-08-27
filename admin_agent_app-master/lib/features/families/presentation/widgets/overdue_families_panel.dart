import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_button.dart';
import '../../../../core/theme/widgets/app_card.dart';
import '../../../../core/theme/widgets/app_toast.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../domain/models/family_filter.dart';
import '../../domain/models/family_status.dart';
import '../../domain/models/savings_plan.dart';
import '../providers/families_providers.dart';

/// Liste des familles en retard de paiement avec relance par appel/SMS
/// (motif `ad_al`/`ag_im` du prototype) — utilisé par l'écran Admin (toutes
/// agences, [agentName] nul) et par l'écran Agent terrain (ses propres
/// clients, [agentName] renseigné).
class OverdueFamiliesPanel extends ConsumerWidget {
  const OverdueFamiliesPanel({super.key, this.agentName});

  final String? agentName;

  Future<void> _call(BuildContext context, String phone) async {
    final url = Uri.parse('tel:${phone.replaceAll(' ', '')}');
    try {
      await launchUrl(url);
    } catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          "Impossible de lancer l'appel",
          type: AppToastType.error,
        );
      }
    }
  }

  Future<void> _sendGroupSms(BuildContext context, List<String> phones) async {
    if (phones.isEmpty) {
      showAppToast(context, 'Aucun client en retard.');
      return;
    }
    final message = Uri.encodeComponent(
      'Bonjour, ceci est un rappel pour le règlement de votre cotisation '
      'EduPay. Merci !',
    );
    final url = Uri.parse('sms:${phones.join(',')}?body=$message');
    try {
      await launchUrl(url);
      if (context.mounted) {
        showAppToast(context, 'SMS préparé pour ${phones.length} client(s) !');
      }
    } catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          "Impossible d'ouvrir l'application SMS",
          type: AppToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = FamilyFilter(
      status: FamilyStatus.lateOverdue,
      assignedAgentName: agentName,
    );
    final familiesAsync = ref.watch(familiesListProvider(filter));

    return familiesAsync.when(
      data: (families) => ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            variant: AppCardVariant.danger,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚠ ${families.length} client(s) en retard de paiement',
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Contactez-les pour régulariser',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          for (final family in families)
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.surfaceBorder),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(family.fullName, style: AppTextStyles.bodyStrong),
                        Text(
                          '${family.city} - ${family.plan.label}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _call(context, family.phone),
                    icon: const Icon(Icons.phone, color: AppColors.gold),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: '📢 Envoyer SMS de relance groupe',
            variant: AppButtonVariant.danger,
            onPressed: () =>
                _sendGroupSms(context, families.map((f) => f.phone).toList()),
          ),
        ],
      ),
      loading: () => const LoadingScreen(),
      error: (error, stackTrace) =>
          ErrorScreen(onRetry: () => ref.invalidate(familiesListProvider)),
    );
  }
}
