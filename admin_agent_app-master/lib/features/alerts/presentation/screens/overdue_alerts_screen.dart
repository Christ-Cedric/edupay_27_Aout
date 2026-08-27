import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../families/presentation/widgets/overdue_families_panel.dart';

/// Alertes impayés (motif `ad_al` du prototype) — vue Admin sur toutes les
/// agences.
class OverdueAlertsScreen extends StatelessWidget {
  const OverdueAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(title: 'Alertes impayés', onBack: () => context.pop()),
      body: const OverdueFamiliesPanel(),
    );
  }
}
