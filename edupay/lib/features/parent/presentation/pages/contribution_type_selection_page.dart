import 'package:edupay/app/theme/app_colors.dart';
import 'package:edupay/features/parent/presentation/parent_scope.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/parent_models.dart';
import '../parent_app_state.dart';
import 'page_scaffold.dart';
import '../../../../shared/widgets/progress_stepper.dart';

class ContributionTypeSelectionPage extends StatelessWidget {
  const ContributionTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;

    return ParentPageScaffold(
      children: [
        const ProgressStepper(currentStep: 1, totalSteps: 5),
        const SizedBox(height: 20),
        Text(
          'Que souhaitez-vous financer ?',
          style: TextStyle(
            color: palette.onSurface(1),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choisissez le type de cotisation.',
          style: TextStyle(
            color: palette.onSurface(.6),
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        _TypeCard(
          title: 'Scolarité',
          subtitle: 'Frais d\'inscription et de scolarité',
          icon: Icons.school_outlined,
          color: const Color(0xFF00C853),
          goalType: SavingsGoalType.registration,
          state: state,
        ),
        const SizedBox(height: 12),
        _TypeCard(
          title: 'Déplacement',
          subtitle: 'Transport scolaire, vélo, moto',
          icon: Icons.directions_bus_outlined,
          color: const Color(0xFF2979FF),
          goalType: SavingsGoalType.transport,
          state: state,
        ),
        const SizedBox(height: 12),
        _TypeCard(
          title: 'Fournitures',
          subtitle: 'Kits scolaires, uniformes, cantine',
          icon: Icons.backpack_outlined,
          color: const Color(0xFFFF9100),
          goalType: SavingsGoalType.supplies,
          state: state,
        ),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.goalType,
    required this.state,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final SavingsGoalType goalType;
  final ParentAppState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final plan = state.savingsPlanFor(goalType);
    final reached = plan.goalReached || plan.totalGoal == 0;

    return InkWell(
      onTap: reached
          ? null
          : () {
              context.push('/app/contribute', extra: goalType);
            },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: reached ? palette.hairline : color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: reached ? palette.hairline : color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: reached ? palette.onSurface(.4) : color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: reached
                          ? palette.onSurface(.4)
                          : palette.onSurface(1),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: palette.onSurface(.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (reached)
              Icon(Icons.check_circle, color: palette.onSurface(.3))
            else
              const Icon(Icons.chevron_right, color: Color(0xFF00C853)),
          ],
        ),
      ),
    );
  }
}
