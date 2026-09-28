import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_card.dart';
import '../../../../core/theme/widgets/app_toast.dart';
import '../../../../core/theme/widgets/initials_avatar.dart';
import '../../../agents/presentation/providers/agents_providers.dart';
import '../../domain/models/family.dart';
import '../../domain/models/family_filter.dart';
import '../providers/families_providers.dart';

Future<void> showAssignAgentSheet(BuildContext context, Family family) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _AssignAgentSheetContent(family: family),
  );
}

class _AssignAgentSheetContent extends ConsumerStatefulWidget {
  const _AssignAgentSheetContent({required this.family});

  final Family family;

  @override
  ConsumerState<_AssignAgentSheetContent> createState() =>
      _AssignAgentSheetContentState();
}

class _AssignAgentSheetContentState
    extends ConsumerState<_AssignAgentSheetContent> {
  bool _isLoading = false;

  Future<void> _assign(String? agentId, String? agentName) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(familyRepositoryProvider).assignAgent(
            familyId: widget.family.id,
            agentId: agentId,
          );

      ref.invalidate(familyDetailProvider(widget.family.id));
      ref.invalidate(familiesListProvider(const FamilyFilter()));

      if (mounted) {
        Navigator.of(context).pop();
        if (agentName != null) {
          showAppToast(
            context,
            'Mission et localisation transmises à $agentName !',
          );
        } else {
          showAppToast(
            context,
            'Agent désassigné de la famille.',
          );
        }

      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showAppToast(
          context,
          'Erreur lors de l\'attribution : $e',
          type: AppToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final agentsAsync = ref.watch(agentsListProvider);
    final family = widget.family;
    final hasLocation = family.deliveryLocationLat != null &&
        family.deliveryLocationLng != null;

    return Padding(
      padding: EdgeInsets.only(
        top: AppSpacing.md,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Attribuer à un agent',
                style: AppTextStyles.h2,
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Famille : ${family.fullName} (${family.city})',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          // Carte localisation
          AppCard(
            variant: hasLocation
                ? AppCardVariant.success
                : AppCardVariant.neutral,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      hasLocation ? Icons.location_on : Icons.location_off,
                      size: 18,
                      color: hasLocation ? AppColors.green : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      hasLocation
                          ? 'LOCALISATION TRANSMIS PAR LE CLIENT'
                          : 'AUCUNE COORDONNÉE GPS',
                      style: AppTextStyles.caption.copyWith(
                        color: hasLocation ? AppColors.green : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  family.deliveryAddress?.isNotEmpty == true
                      ? family.deliveryAddress!
                      : (hasLocation
                          ? 'Position GPS disponible'
                          : 'Le parent n\'a pas encore envoyé sa localisation.'),
                  style: AppTextStyles.body,
                ),
                if (hasLocation) ...[
                  const SizedBox(height: 2),
                  Text(
                    'GPS: ${family.deliveryLocationLat!.toStringAsFixed(5)}, ${family.deliveryLocationLng!.toStringAsFixed(5)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.green,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.map_outlined, size: 16),
                      label: const Text('Voir sur Google Maps'),
                      onPressed: () async {
                        final uri = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=${family.deliveryLocationLat},${family.deliveryLocationLng}',
                        );
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Choisir l\'agent de terrain',
            style: AppTextStyles.bodyStrong,
          ),
          const SizedBox(height: AppSpacing.xs),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            agentsAsync.when(
              data: (agents) {
                if (agents.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      'Aucun agent actif enregistré.',
                      style: AppTextStyles.caption,
                    ),
                  );
                }

                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.35,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: agents.length +
                        (family.assignedAgentName != null ? 1 : 0),
                    separatorBuilder: (_, _) => const Divider(
                      color: AppColors.surfaceBorder,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      if (family.assignedAgentName != null &&
                          index == agents.length) {
                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.surfaceBorder,
                            child: Icon(Icons.person_remove_outlined,
                                color: AppColors.danger, size: 20),
                          ),
                          title: const Text(
                            'Retirer l\'agent (désassigner)',
                            style: TextStyle(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () => _assign(null, null),
                        );
                      }

                      final agent = agents[index];
                      final isCurrent =
                          family.assignedAgentName == agent.fullName;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        leading: InitialsAvatar(name: agent.fullName),
                        title: Text(
                          agent.fullName,
                          style: AppTextStyles.bodyStrong.copyWith(
                            color: isCurrent ? AppColors.green : null,
                          ),
                        ),
                        subtitle: Text(
                          '${agent.zone}${agent.district != null && agent.district!.isNotEmpty ? " (${agent.district})" : ""} • ${agent.phone}',
                          style: AppTextStyles.caption,
                        ),
                        trailing: isCurrent
                            ? const Icon(Icons.check_circle,
                                color: AppColors.green, size: 20)
                            : const Icon(Icons.chevron_right,
                                color: AppColors.textSecondary, size: 20),
                        onTap: () => _assign(agent.id, agent.fullName),
                      );
                    },
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Erreur de chargement des agents',
                  style: TextStyle(color: AppColors.danger),
                ),
              ),

            ),
        ],
      ),
    );
  }
}
