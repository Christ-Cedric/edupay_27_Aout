import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/mock_schooling_plan.dart';
import '../../../core/models/mock_transport_plan.dart';
import '../../../core/theme/app_theme.dart';

class AgSchoolingHistoryScreen extends StatelessWidget {
  final MockSchoolingPlan plan;

  const AgSchoolingHistoryScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final paidContributions = plan.contributions.where((c) => c.status == ContributionStatus.paid).toList();
    final df = DateFormat('dd MMM yyyy, HH:mm', 'fr');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Historique de ${plan.childName}', style: AppTheme.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Beautiful Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [AppColors.gold.withValues(alpha: 0.2), AppColors.background],
                center: Alignment.center,
                radius: 1.2,
              ),
            ),
          ),
          
          // Reduced, centered, shiny image
          Center(
            child: Opacity(
              opacity: 0.5,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      blurRadius: 80,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/bg_menapln.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Premium Glassmorphism Encouragement Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.15),
                              Colors.white.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.stars_rounded, color: AppColors.gold, size: 54),
                            const SizedBox(height: 12),
                            Text(
                              'Félicitations !',
                              style: AppTheme.montserrat(fontSize: 24, color: AppColors.gold, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Continuez vos cotisations avec régularité pour garantir un bel avenir à ${plan.childName}.',
                              textAlign: TextAlign.center,
                              style: AppTheme.openSans(fontSize: 14, color: Colors.white.withValues(alpha: 0.9)),
                            ),
                            const SizedBox(height: 24),
                            // Advanced Progress indicator
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Payé: ${plan.totalPaid.toInt()} F', style: AppTheme.montserrat(color: AppColors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text('Reste: ${plan.remainingAmount.toInt()} F', style: AppTheme.openSans(color: Colors.white70, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Stack(
                                  children: [
                                    Container(
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: plan.progress.isNaN ? 0.0 : plan.progress.clamp(0.0, 1.0),
                                      child: Container(
                                        height: 10,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(colors: [AppColors.green, Color(0xFF00C853)]),
                                          borderRadius: BorderRadius.circular(5),
                                          boxShadow: [
                                            BoxShadow(color: AppColors.green.withValues(alpha: 0.5), blurRadius: 8, offset: const Offset(0, 2))
                                          ]
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Objectif : ${plan.targetAmount.toInt()} FCFA',
                                  textAlign: TextAlign.center,
                                  style: AppTheme.montserrat(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Premium History List (NO BLUR, pure translucency to see background image perfectly)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Vos derniers paiements',
                          style: AppTheme.montserrat(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        if (paidContributions.isEmpty)
                          Expanded(
                            child: Center(
                              child: Text(
                                'Aucun paiement effectué pour le moment.',
                                style: AppTheme.openSans(color: Colors.white54),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 24),
                              physics: const BouncingScrollPhysics(),
                              itemCount: paidContributions.length,
                              itemBuilder: (context, index) {
                                // Reversed order for latest first (simulated)
                                final c = paidContributions[paidContributions.length - 1 - index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [AppColors.green, AppColors.green.withValues(alpha: 0.6)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(color: AppColors.green.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2))
                                          ]
                                        ),
                                        child: const Icon(Icons.check, color: Colors.white, size: 24),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Paiement validé',
                                              style: AppTheme.montserrat(fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              df.format(DateTime.now()), // simulated date
                                              style: AppTheme.openSans(fontSize: 12, color: Colors.white54),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '+${c.amount.toInt()} F',
                                        style: AppTheme.montserrat(color: AppColors.green, fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
