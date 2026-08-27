import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/widgets/alert_notice.dart';
import '../../domain/models/dashboard_alert.dart';

/// Liste des cartes d'alerte du dashboard (motif `.nt` du prototype).
class DashboardAlertsSection extends StatelessWidget {
  const DashboardAlertsSection({
    super.key,
    required this.alerts,
    this.onAlertTap,
  });

  final List<DashboardAlert> alerts;
  final ValueChanged<DashboardAlert>? onAlertTap;

  AlertNoticeVariant _variantFor(DashboardAlertSeverity severity) =>
      switch (severity) {
        DashboardAlertSeverity.danger => AlertNoticeVariant.danger,
        DashboardAlertSeverity.warning => AlertNoticeVariant.warning,
        DashboardAlertSeverity.info => AlertNoticeVariant.info,
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < alerts.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.xs),
          AlertNotice(
            title: alerts[i].title,
            subtitle: alerts[i].subtitle,
            variant: _variantFor(alerts[i].severity),
            onTap: onAlertTap == null ? null : () => onAlertTap!(alerts[i]),
          ),
        ],
      ],
    );
  }
}
