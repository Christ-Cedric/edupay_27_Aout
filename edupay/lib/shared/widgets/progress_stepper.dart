import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class ProgressStepper extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressStepper({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (index) {
          if (index % 2 == 0) {
            // C'est un cercle (étape)
            final stepIndex = index ~/ 2 + 1;
            final isActive = stepIndex <= currentStep;
            return Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? palette.accentGreen : palette.onSurface(.05),
              ),
              alignment: Alignment.center,
              child: Text(
                '$stepIndex',
                style: TextStyle(
                  color: isActive ? palette.background : palette.onSurface(.4),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            );
          } else {
            // C'est une ligne de connexion
            final stepIndex = index ~/ 2 + 1;
            final isActive = stepIndex < currentStep;
            return Expanded(
              child: Container(
                height: 3,
                color: isActive ? palette.accentGreen : palette.onSurface(.05),
              ),
            );
          }
        }),
      ),
    );
  }
}
