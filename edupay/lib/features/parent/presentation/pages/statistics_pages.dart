import 'package:edupay/features/parent/domain/school_catalogue.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../parent_scope.dart';
import 'page_scaffold.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;

    int totalSuppliesTarget = 0;
    int totalSuppliesSaved = 0;
    int totalTuitionTarget = 0;
    int totalTuitionSaved = 0;
    int totalTransportTarget = 0;
    int totalTransportSaved = 0;

    for (final child in state.children) {
      totalSuppliesTarget += child.suppliesCost;
      totalSuppliesSaved += child.kitSavedAmount;

      totalTuitionTarget += child.tuitionAmount;
      totalTuitionSaved += child.tuitionSavedAmount;

      totalTransportTarget += child.transportAmount;
      totalTransportSaved += child.transportSavedAmount;
    }

    return ParentPageScaffold(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            const Expanded(
              child: PageTitle(
                'Statistiques globales',
                subtitle: 'Aperçu par type de cotisation.',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _CategoryStatCard(
          title: 'Fournitures scolaires',
          icon: Icons.inventory_2_outlined,
          color: const Color(0xFF00C853), // Green
          gradientColors: const [Color(0xFF82F4B1), Color(0xFF30C5D2)],
          target: totalSuppliesTarget,
          saved: totalSuppliesSaved,
        ),
        const SizedBox(height: 16),
        _CategoryStatCard(
          title: 'Frais de scolarité',
          icon: Icons.school_outlined,
          color: palette.accentYellow, // Yellow
          gradientColors: const [Color(0xFFFFD54F), Color(0xFFFFB300)],
          target: totalTuitionTarget,
          saved: totalTuitionSaved,
        ),
        const SizedBox(height: 16),
        _CategoryStatCard(
          title: 'Déplacement',
          icon: Icons.directions_bike_outlined,
          color: const Color(0xFF00B4D8), // Blue
          gradientColors: const [Color(0xFF90E0EF), Color(0xFF00B4D8)],
          target: totalTransportTarget,
          saved: totalTransportSaved,
        ),
      ],
    );
  }
}

class _CategoryStatCard extends StatelessWidget {
  const _CategoryStatCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.gradientColors,
    required this.target,
    required this.saved,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;
  final int target;
  final int saved;

  String _money(int value) {
    final raw = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final fromEnd = raw.length - i;
      buffer.write(raw[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(' ');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final progress = target == 0 ? 0.0 : (saved / target).clamp(0.0, 1.0);
    final percent = (progress * 100).round();

    return AppCard(
      borderColor: color.withValues(alpha: .3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final fillWidth = maxWidth * progress;
              return Container(
                height: 24,
                width: maxWidth,
                decoration: BoxDecoration(
                  color: palette.onSurface(.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    if (progress > 0)
                      Container(
                        width: fillWidth,
                        height: 24,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(colors: gradientColors),
                          boxShadow: [
                            BoxShadow(
                              color: gradientColors.last.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Épargné : ${_money(saved)} F',
                  style: TextStyle(
                    color: palette.onSurface(.6),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                'Objectif : ${_money(target)} F',
                style: TextStyle(
                  color: palette.onSurface(.6),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
