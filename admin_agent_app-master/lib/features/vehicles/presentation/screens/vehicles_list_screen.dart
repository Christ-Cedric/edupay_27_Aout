import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_button.dart';
import '../../../../core/theme/widgets/app_card.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/tap_target.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../domain/models/transport_vehicle.dart';
import '../providers/vehicles_providers.dart';

class VehiclesListScreen extends ConsumerWidget {
  const VehiclesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesListProvider);

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(
        title: 'Moyens de Déplacement',
        onBack: () => context.pop(),
      ),
      body: vehiclesAsync.when(
        data: (vehicles) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              if (vehicles.isEmpty)
                const EmptyState(
                  icon: Icons.two_wheeler_outlined,
                  title: 'Aucun engin enregistré',
                  subtitle: 'Ajoutez des engins/moyens de déplacement pour les familles',
                ),
              for (final vehicle in vehicles) ...[
                _VehicleCard(vehicle: vehicle),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: '+ Ajouter un moyen de déplacement',
                variant: AppButtonVariant.green,
                onPressed: () => context.push('/admin/settings/vehicles/new'),
              ),
            ],
          );
        },
        loading: () => const LoadingScreen(),
        error: (error, stackTrace) =>
            ErrorScreen(onRetry: () => ref.invalidate(vehiclesListProvider)),
      ),
    );
  }
}

class _VehicleCard extends ConsumerWidget {
  final TransportVehicle vehicle;

  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstImage = vehicle.images.isNotEmpty ? vehicle.images.first : null;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(12),
                  image: firstImage != null
                      ? DecorationImage(
                          image: NetworkImage(firstImage),
                          fit: BoxFit.cover,
                          onError: (_, __) {},
                        )
                      : null,
                ),
                child: firstImage == null
                    ? const Icon(
                        Icons.two_wheeler,
                        color: AppColors.gold,
                        size: 36,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vehicle.name,
                            style: AppTextStyles.bodyStrong,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: vehicle.isAvailable
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            vehicle.isAvailable ? 'Disponible' : 'Indisponible',
                            style: TextStyle(
                              color: vehicle.isAvailable ? Colors.green : Colors.redAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(vehicle.price),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (vehicle.description != null && vehicle.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        vehicle.description!,
                        style: AppTextStyles.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TapTarget(
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      title: const Text('Supprimer cet engin ?', style: TextStyle(color: Colors.white)),
                      content: Text(
                        'Êtes-vous sûr de vouloir supprimer "${vehicle.name}" ?',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Supprimer', style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await ref
                        .read(vehicleDeleteControllerProvider.notifier)
                        .delete(vehicle.id);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Supprimer 🗑',
                    style: AppTextStyles.tag.copyWith(color: Colors.redAccent),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              TapTarget(
                onTap: () => context.push('/admin/settings/vehicles/${vehicle.id}/edit'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Modifier ✎',
                    style: AppTextStyles.tag.copyWith(color: AppColors.gold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
