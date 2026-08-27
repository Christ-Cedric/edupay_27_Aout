import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/initials_avatar.dart';
import '../../domain/models/family.dart';
import '../../domain/models/family_status.dart';
import '../../domain/models/savings_plan.dart';
import 'family_status_tag.dart';

/// Ligne famille dans une liste (motif `.ai` du prototype, `ad_fa`/`ad_do`).
class FamilyListTile extends StatelessWidget {
  const FamilyListTile({super.key, required this.family, required this.onTap});

  final Family family;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
        ),
        child: Row(
          children: [
            InitialsAvatar(
              name: family.fullName,
              size: 32,
              backgroundColor: family.status == FamilyStatus.lateOverdue
                  ? AppColors.danger
                  : AppColors.green,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(family.fullName, style: AppTextStyles.bodyStrong),
                  Text(
                    '${family.city} - ${family.plan.label} - ${(family.progress * 100).round()}%',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            FamilyStatusTag(status: family.status),
          ],
        ),
      ),
    );
  }
}
