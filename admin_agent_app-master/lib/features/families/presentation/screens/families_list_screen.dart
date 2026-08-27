import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../domain/models/family_filter.dart';
import '../../domain/models/family_status.dart';
import '../providers/families_providers.dart';
import '../widgets/family_filter_chips.dart';
import '../widgets/family_list_tile.dart';

/// Liste de toutes les familles (motif `ad_fa` du prototype), avec
/// recherche et filtres fonctionnels (décoratifs dans le mockup source).
class FamiliesListScreen extends ConsumerStatefulWidget {
  const FamiliesListScreen({super.key});

  @override
  ConsumerState<FamiliesListScreen> createState() => _FamiliesListScreenState();
}

class _FamiliesListScreenState extends ConsumerState<FamiliesListScreen> {
  final _searchController = TextEditingController();
  FamilyStatus? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = FamilyFilter(
      query: _searchController.text,
      status: _statusFilter,
    );
    final familiesAsync = ref.watch(familiesListProvider(filter));

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(
        title: 'Toutes les familles',
        trailing: IconButton(
          icon: const Icon(
            Icons.person_add_alt,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.push('${RoutePaths.adminFamilies}/enroll'),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Column(
              children: [
                AppTextField(
                  label: 'Rechercher',
                  controller: _searchController,
                  hintText: 'Nom de la famille...',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FamilyFilterChips(
                    selected: _statusFilter,
                    onSelected: (status) =>
                        setState(() => _statusFilter = status),
                    onPendingTap: () =>
                        context.push('${RoutePaths.adminFamilies}/pending'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: familiesAsync.when(
              data: (families) => families.isEmpty
                  ? const EmptyState(
                      icon: Icons.groups_outlined,
                      title: 'Aucune famille',
                      subtitle:
                          'Ajustez vos filtres ou inscrivez une nouvelle famille',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      itemCount: families.length,
                      itemBuilder: (context, index) {
                        final family = families[index];
                        return FamilyListTile(
                          family: family,
                          onTap: () => context.push(
                            '${RoutePaths.adminFamilies}/${family.id}',
                          ),
                        );
                      },
                    ),
              loading: () => const LoadingScreen(),
              error: (error, stackTrace) => ErrorScreen(
                onRetry: () => ref.invalidate(familiesListProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
