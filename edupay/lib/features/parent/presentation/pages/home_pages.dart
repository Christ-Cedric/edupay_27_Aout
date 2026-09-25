import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/action_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_progress_bar.dart';
import '../../../../shared/widgets/edupay_logo.dart';
import '../../domain/parent_models.dart';
import '../../domain/savings_engine.dart';
import '../../domain/school_catalogue.dart';
import '../parent_app_state.dart';
import '../parent_scope.dart';
import 'page_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;

    if (!state.homeLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) => state.loadHomeData());
    }

    return ParentPageScaffold(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      onRefresh: state.loadHomeData,
      children: [
        Text(
          'Bonjour ${state.displayName.isNotEmpty ? state.displayName : "Parent"}',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            fontFamily: 'Montserrat',
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Préparez sereinement les dépenses scolaires.',
          style: TextStyle(
            color: palette.onSurface(.55),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 18),

        // --- CARTE BLEUE ÉPARGNE TOTALE ---
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF0D1E3A),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D1E3A).withValues(alpha: .25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Cercle décoratif subtil en haut à droite
              Positioned(
                top: -30,
                right: -20,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .04),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ÉPARGNE TOTALE',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .7),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_money(state.totalSaved)} FCFA',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w800,
                        fontSize: 32,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppProgressBar(
                      progress: (state.progress / 100).clamp(0.0, 1.0),
                      height: 10,
                      backgroundColor: Colors.white.withValues(alpha: .12),
                      color: palette.accentGreen,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              const TextSpan(text: 'Objectif '),
                              TextSpan(
                                text: '${_money(state.totalGoal)} F',
                                style: const TextStyle(
                                  color: Color(0xFF00C853),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${state.progress}%',
                          style: const TextStyle(
                            color: Color(0xFF00C853),
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD600),
                          foregroundColor: const Color(0xFF071426),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        onPressed: state.goalReached
                            ? null
                            : () => context.push('/app/contribute/type'),
                        child: Text(
                          state.goalReached
                              ? 'Objectif atteint 🎉'
                              : 'Cotiser maintenant',
                          style: const TextStyle(
                            color: Color(0xFF071426),
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // --- 2 CARTES ACTIONS RAPIDES (NOUVEL OBJECTIF & MES ENFANTS) ---
        Row(
          children: [
            Expanded(
              child: _ActionSquareCard(
                iconWidget: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFF5A623),
                      width: 3,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.add, color: Color(0xFFF5A623), size: 28),
                  ),
                ),
                backgroundColor: palette.isDark
                    ? palette.surface
                    : const Color(0xFFFCF8F2),
                borderColor: palette.isDark
                    ? palette.hairline
                    : const Color(0xFFF5ECD9).withValues(alpha: .6),
                title: 'Nouvel objectif',
                subtitle: 'Créer un objectif\nd’épargne',
                onTap: () => context.push('/app/goals'),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _ActionSquareCard(
                iconWidget: const Icon(
                  Icons.face_retouching_natural_outlined,
                  color: Color(0xFF00C853),
                  size: 44,
                ),
                backgroundColor: palette.isDark
                    ? palette.surface
                    : const Color(0xFFF2FAF6),
                borderColor: palette.isDark
                    ? palette.hairline
                    : const Color(0xFFD8F2E4).withValues(alpha: .6),
                title: 'Mes enfants',
                subtitle: 'Gérer les informations\nde vos enfants',
                onTap: () => context.push('/app/children'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // --- SECTION MES OBJECTIFS PLANIFIÉS & VOIR TOUT ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'MES OBJECTIFS PLANIFIÉS',
              style: TextStyle(
                color: Color(0xFF00C853),
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
            InkWell(
              onTap: () => context.push('/app/savings'),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Voir tout',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // --- LISTE DES ENFANTS / OBJECTIFS ---
        if (state.children.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: palette.hairline),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.flag_outlined,
                  color: palette.onSurface(.4),
                  size: 36,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aucun objectif défini',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Appuyez sur « Nouvel objectif » pour planifier vos dépenses de rentrée.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.onSurface(.55), fontSize: 13),
                ),
              ],
            ),
          )
        else
          for (var index = 0; index < state.children.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ChildGoalCard(
                child: state.children[index],
                onTap: () => context.push('/app/savings/$index'),
              ),
            ),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// Carte carrée pour les actions rapides « Nouvel objectif » et « Mes enfants »
class _ActionSquareCard extends StatelessWidget {
  const _ActionSquareCard({
    required this.iconWidget,
    required this.backgroundColor,
    required this.borderColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Widget iconWidget;
  final Color backgroundColor;
  final Color borderColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget,
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.onSurface(.55),
                  fontSize: 11,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte d'un objectif enfant dans la liste d'accueil
class _ChildGoalCard extends StatelessWidget {
  const _ChildGoalCard({required this.child, required this.onTap});

  final ChildProfile child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final pct = child.totalCost > 0
        ? ((child.savedAmount / child.totalCost) * 100).toInt()
        : 0;
    final initial = child.firstName.isNotEmpty
        ? child.firstName.substring(0, 1).toUpperCase()
        : 'E';

    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: palette.isDark
                  ? palette.hairline
                  : const Color(0xFFEDF2F7),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: palette.isDark ? .15 : .02,
                ),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F7EE),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Color(0xFF00C853),
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cotisation ${child.firstName.toLowerCase()}',
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${child.level} · ${child.school}',
                          style: TextStyle(
                            color: palette.onSurface(.55),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_money(child.savedAmount)} FCFA',
                        style: const TextStyle(
                          color: Color(0xFFF5A623),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'sur ${_money(child.totalCost)} FCFA',
                        style: TextStyle(
                          color: palette.onSurface(.5),
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppProgressBar(
                      progress: child.totalCost > 0
                          ? (child.savedAmount / child.totalCost).clamp(
                              0.0,
                              1.0,
                            )
                          : 0.0,
                      height: 6,
                      backgroundColor: palette.isDark
                          ? Colors.white.withValues(alpha: .08)
                          : const Color(0xFFEDF2F7),
                      color: palette.accentGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$pct%',
                    style: const TextStyle(
                      color: Color(0xFF00C853),
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SavingsPage extends StatelessWidget {
  const SavingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;

    return ParentPageScaffold(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: PageTitle(
                'Mes épargnes',
                subtitle: 'Suivez la progression de vos cotisations.',
              ),
            ),
            TextButton.icon(
              onPressed: () => context.push('/app/history'),
              icon: Icon(
                Icons.receipt_long,
                size: 16,
                color: palette.accentGreen,
              ),
              label: Text(
                'Historique',
                style: TextStyle(
                  color: palette.accentGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (var index = 0; index < state.children.length; index++) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              onTap: () => context.push('/app/savings/$index'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: palette.accentGreen.withValues(
                          alpha: .15,
                        ),
                        foregroundColor: palette.accentGreen,
                        child: Text(
                          state.children[index].firstName
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cotisation ${state.children[index].firstName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${state.children[index].level} · ${state.children[index].school}',
                              style: TextStyle(
                                color: palette.onSurface(.55),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${_money(state.children[index].savedAmount)} F',
                        style: TextStyle(
                          color: palette.accentYellow,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AppProgressBar(
                    progress: state.children[index].totalCost > 0
                        ? (state.children[index].savedAmount /
                                  state.children[index].totalCost)
                              .clamp(0.0, 1.0)
                        : 0.0,
                    height: 8,
                    backgroundColor: palette.onSurface(.10),
                    color: palette.accentGreen,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if ((state.children[index].resolvedKit?.price ?? 0) > 0)
                        _SmallGoalBadge(
                          icon: Icons.inventory_2_outlined,
                          label:
                              'Fournitures : ${_money(state.children[index].resolvedKit!.price)} F',
                          color: palette.accentGreen,
                        ),
                      if (state.children[index].tuitionAmount > 0)
                        _SmallGoalBadge(
                          icon: Icons.school_outlined,
                          label:
                              'Scolarité : ${_money(state.children[index].tuitionAmount)} F',
                          color: palette.accentYellow,
                        ),
                      if (state.children[index].transportAmount > 0)
                        _SmallGoalBadge(
                          icon: Icons.directions_bike_outlined,
                          label:
                              '${state.children[index].transportType ?? "Transport"} : ${_money(state.children[index].transportAmount)} F',
                          color: const Color(0xFF00B4D8),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Objectif total : ${_money(state.children[index].totalCost)} F',
                    style: TextStyle(
                      color: palette.onSurface(.55),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SmallGoalBadge extends StatelessWidget {
  const _SmallGoalBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class ContributePage extends StatefulWidget {
  const ContributePage({super.key, this.targetGoalType});

  final SavingsGoalType? targetGoalType;

  @override
  State<ContributePage> createState() => _ContributePageState();
}

class _ContributePageState extends State<ContributePage> {
  final _amountController = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pré-remplit le montant avec la quote-part prévue (une seule fois, pour ne
    // pas écraser une saisie du parent à chaque reconstruction).
    if (!_initialized) {
      _initialized = true;
      final state = ParentScope.of(context);
      final plan = widget.targetGoalType != null
          ? state.savingsPlanFor(widget.targetGoalType!)
          : state.savingsPlan;
      _amountController.text = plan.perPeriodAmount.toString();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Montant saisi (quote-part par défaut, borné au reste global).
  int _amountFor(ParentAppState state, SavingsPlanComputation plan) {
    final typed = int.tryParse(_amountController.text.trim());
    if (typed == null || typed <= 0) return plan.perPeriodAmount;
    return typed.clamp(1, plan.globalRemaining);
  }

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;
    final plan = widget.targetGoalType != null
        ? state.savingsPlanFor(widget.targetGoalType!)
        : state.savingsPlan;

    // Objectif atteint : plus aucune cotisation possible, on affiche seulement
    // un message d'information à la place du formulaire de paiement.
    if (plan.goalReached) {
      return ParentPageScaffold(
        children: [
          const SizedBox(height: 12),
          _GoalReachedBanner(total: plan.totalSaved),
        ],
      );
    }

    final quotePart = plan.perPeriodAmount;
    final alreadySaved = plan.totalSaved;
    final remaining = plan.globalRemaining;

    return ParentPageScaffold(
      children: [
        // Règle métier : l'écran de paiement affiche clairement la quote-part
        // prévue, le déjà cotisé et le reste à payer.
        _QuotePartCard(
          quotePart: quotePart,
          period: state.plan.period,
          alreadySaved: alreadySaved,
          remaining: remaining,
        ),
        if (state.pendingQuotaBalance > 0) ...[
          const SizedBox(height: 10),
          _PendingBalanceBanner(
            balance: state.pendingQuotaBalance,
            quotaValue: quotePart,
          ),
        ],
        if (state.isPaymentOverdue) ...[
          const SizedBox(height: 10),
          const _ArrearsBanner(),
        ],
        const SizedBox(height: 20),
        const SectionLabel('Montant à payer'),
        const SizedBox(height: 8),
        _AmountField(controller: _amountController, quotePart: quotePart),
        const SizedBox(height: 6),
        Text(
          'Vous pouvez payer plus que la quote-part : le surplus est déduit de '
          'vos prochaines échéances.',
          style: TextStyle(
            color: palette.onSurface(.5),
            fontSize: 12,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        const SectionLabel('Mode de paiement'),
        const _PaymentTile(
          method: PaymentMethod.orangeMoney,
          title: 'Orange Money',
          badge: 'OM',
          color: Color(0xFFFF6600),
        ),
        const _PaymentTile(
          method: PaymentMethod.moovMoney,
          title: 'Moov Money',
          badge: 'MM',
          color: Color(0xFF0066CC),
        ),

        const SizedBox(height: 12),
        const SizedBox(height: 18),
        ActionButton(
          label: 'Cotiser maintenant',
          icon: Icons.phone_in_talk,
          onPressed: () => _confirmPayment(
            context,
            state,
            _amountFor(state, plan),
            widget.targetGoalType,
          ),
        ),
      ],
    );
  }
}

/// Récapitulatif chiffré affiché en tête de l'écran de paiement (règle métier) :
/// quote-part prévue pour l'échéance, montant déjà cotisé et reste à payer.
class _QuotePartCard extends StatelessWidget {
  const _QuotePartCard({
    required this.quotePart,
    required this.period,
    required this.alreadySaved,
    required this.remaining,
  });

  final int quotePart;
  final String period;
  final int alreadySaved;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppCard(
      borderColor: palette.accentYellow.withValues(alpha: .3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUOTE-PART DE L’ÉCHÉANCE',
            style: TextStyle(
              color: palette.accentYellow,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: .3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_money(quotePart)} FCFA',
            style: TextStyle(
              color: palette.accentYellow,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w800,
              fontSize: 30,
            ),
          ),
          Text(
            'à cotiser par $period',
            style: TextStyle(color: palette.onSurface(.55), fontSize: 12),
          ),
          Divider(height: 24, color: palette.hairline),
          _QuoteRow(
            label: 'Déjà cotisé',
            value: '${_money(alreadySaved)} F',
          ),
          const SizedBox(height: 8),
          _QuoteRow(
            label: 'Reste à payer',
            value: '${_money(remaining)} F',
            valueColor: palette.accentGreen,
          ),
        ],
      ),
    );
  }
}

/// Reliquat en attente (règle métier § quotas) : montant déjà versé mais pas
/// encore suffisant pour compléter un quota — reporté automatiquement, aucun
/// montant versé n'est perdu.
class _PendingBalanceBanner extends StatelessWidget {
  const _PendingBalanceBanner({
    required this.balance,
    required this.quotaValue,
  });
  final int balance;
  final int quotaValue;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppCard(
      color: palette.onSurface(.03),
      child: Row(
        children: [
          Icon(Icons.hourglass_bottom, color: palette.accentYellow),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Solde en attente',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_money(balance)} FCFA déjà versés, en attente de compléter '
                  'la quote-part (${_money(quotaValue)} FCFA). Reporté '
                  'automatiquement, rien n\'est perdu.',
                  style: TextStyle(
                    color: palette.onSurface(.6),
                    fontSize: 12,
                    height: 1.3,
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

/// Alerte de retard de paiement (règle métier §6).
class _ArrearsBanner extends StatelessWidget {
  const _ArrearsBanner();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppCard(
      color: palette.danger.withValues(alpha: .08),
      borderColor: palette.danger.withValues(alpha: .4),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: palette.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Retard de paiement',
                  style: TextStyle(
                    color: palette.danger,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Plusieurs échéances n\'ont pas été couvertes. Cotisez dès que '
                  'possible pour régulariser votre dossier.',
                  style: TextStyle(
                    color: palette.onSurface(.6),
                    fontSize: 12,
                    height: 1.3,
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

class _QuoteRow extends StatelessWidget {
  const _QuoteRow({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: palette.onSurface(.6), fontSize: 13),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: valueColor ?? palette.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Champ de saisie du montant (par défaut la quote-part), avec un rappel « + ».
class _AmountField extends StatelessWidget {
  const _AmountField({required this.controller, required this.quotePart});
  final TextEditingController controller;
  final int quotePart;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w800,
        fontSize: 22,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.payments_outlined, color: palette.accentGreen),
        suffixText: 'FCFA',
        hintText: '$quotePart',
        helperText: 'Quote-part prévue : ${_money(quotePart)} FCFA',
      ),
    );
  }
}

// Le mécanisme USSD a été retiré : le paiement est géré côté serveur.

/// Message affiché quand l'objectif de cotisation est entièrement financé.
class _GoalReachedBanner extends StatelessWidget {
  const _GoalReachedBanner({required this.total});
  final int total;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppCard(
      child: Column(
        children: [
          Icon(Icons.verified, color: palette.accentGreen, size: 54),
          const SizedBox(height: 12),
          const Text(
            'Objectif atteint ðŸŽ‰',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous avez atteint votre objectif de cotisation '
            '(${_money(total)} FCFA). Aucune cotisation supplémentaire '
            "n'est nécessaire.",
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.onSurface(.6), height: 1.4),
          ),
        ],
      ),
    );
  }
}

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;
    final contribution =
        state.paymentState.data?.contribution ??
        (state.contributions.isNotEmpty ? state.contributions.first : null);
    return _StatusConfirmationScreen(
      icon: Icons.check,
      iconBackground: palette.accentGreen,
      iconColor: Colors.white,
      title: 'Paiement confirmé !',
      subtitle: 'Votre reçu a été envoyé par WhatsApp',
      details: [
        _StatusDetail(
          label: 'N° Reçu',
          value: contribution?.reference ?? 'EP-RC-2026-0148',
        ),
        _StatusDetail(
          label: 'Montant',
          value:
              '${_money(contribution?.amount ?? state.installmentAmount)} FCFA',
        ),
        _StatusDetail(
          label: 'Mode',
          value: contribution?.method ?? state.paymentMethod.name,
        ),
        _StatusDetail(
          label: 'Nouveau solde',
          value: '${_money(state.totalSaved)} FCFA',
          valueColor: palette.accentGreen,
        ),
      ],
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;

    return ParentPageScaffold(
      children: [
        const PageTitle(
          'Historique',
          subtitle: 'Toutes vos cotisations visibles ici.',
        ),
        if (state.contributions.isNotEmpty) ...[
          AppCard(
            color: palette.accentGreen.withValues(alpha: .08),
            borderColor: palette.accentGreen.withValues(alpha: .4),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: palette.accentGreen,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Total cotisé (${state.contributions.where((c) => c.success).length} paiement'
                    '${state.contributions.where((c) => c.success).length > 1 ? 's' : ''})',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${_money(state.contributions.where((c) => c.success).fold<int>(0, (sum, c) => sum + c.amount))} FCFA',
                  style: TextStyle(
                    color: palette.accentGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (state.contributions.isEmpty)
          AppCard(
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 42,
                  color: palette.onSurface(.4),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Aucune cotisation pour le moment',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vos paiements apparaîtront ici dès votre première cotisation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.onSurface(.55), fontSize: 13),
                ),
              ],
            ),
          ),
        for (final contribution in state.contributions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contribution.date,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${contribution.method} - ${contribution.reference}',
                          style: TextStyle(color: palette.onSurface(.55)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    contribution.success
                        ? '+${_money(contribution.amount)} F'
                        : 'Echoue',
                    style: TextStyle(
                      color: contribution.success
                          ? palette.accentGreen
                          : palette.danger,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class RefundPage extends StatelessWidget {
  const RefundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;

    return ParentPageScaffold(
      children: [
        const PageTitle(
          'Remboursement',
          subtitle: 'Traitement sous 7 jours ouvrables.',
        ),
        AppCard(
          borderColor: palette.accentGreen.withValues(alpha: .4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remboursement possible',
                style: TextStyle(
                  color: palette.accentGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_money((state.totalSaved - 500).clamp(0, 999999))} FCFA',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Frais de dossier : 500 FCFA',
                style: TextStyle(color: palette.onSurface(.55)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: state.refundReasonController,
          decoration: const InputDecoration(
            labelText: 'Motif',
            hintText: 'Difficulte temporaire',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: state.phoneController,
          decoration: const InputDecoration(labelText: 'Numero Mobile Money'),
        ),
        const SizedBox(height: 18),
        ActionButton(
          label: 'Confirmer la demande',
          icon: Icons.hourglass_top,
          danger: true,
          onPressed: () => _confirmRefund(context, state),
        ),
      ],
    );
  }
}

class RefundSuccessPage extends StatelessWidget {
  const RefundSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;
    // Montant et référence RÉELS renvoyés par le serveur à la création de la
    // demande (`ParentAppState.requestRefund`) — jamais recalculés ici.
    final refund = state.lastRefundRequest;
    return _StatusConfirmationScreen(
      icon: Icons.hourglass_top_rounded,
      iconBackground: palette.accentYellow,
      iconColor: palette.danger,
      title: 'Demande envoyée',
      subtitle: refund != null
          ? 'Votre remboursement de ${_money(refund.amount)} FCFA est en cours de traitement'
          : 'Votre demande est en cours de traitement.',
      details: [
        _StatusDetail(
          label: 'N° dossier',
          value: refund?.reference ?? '—',
        ),
        _StatusDetail(
          label: 'Montant',
          value: refund != null ? '${_money(refund.amount)} FCFA' : '—',
        ),
        _StatusDetail(
          label: 'Statut',
          value: 'En attente',
          valueColor: palette.accentYellow,
        ),
        const _StatusDetail(label: 'Délai max.', value: '7 jours ouvrables'),
      ],
    );
  }
}

class _StatusConfirmationScreen extends StatelessWidget {
  const _StatusConfirmationScreen({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.details,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<_StatusDetail> details;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ColoredBox(
      color: palette.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(29, 22, 29, 28),
        child: Column(
          children: [
            const Spacer(flex: 5),
            CircleAvatar(
              radius: 28,
              backgroundColor: iconBackground,
              child: Icon(icon, color: iconColor, size: 30),
            ),
            const SizedBox(height: 17),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.onSurface(.55), fontSize: 8),
            ),
            const SizedBox(height: 16),
            AppCard(
              color: palette.surfaceSoft,
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              child: Column(
                children: [
                  for (var index = 0; index < details.length; index++) ...[
                    _StatusDetailsRow(detail: details[index]),
                    if (index < details.length - 1)
                      Divider(height: 9, color: palette.hairline),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 19),
            ActionButton(
              label: 'Retour à l’accueil',
              onPressed: () => context.go('/app/home'),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _StatusDetail {
  const _StatusDetail({
    required this.label,
    required this.value,
    this.valueColor,
  });
  final String label;
  final String value;

  /// Null = couleur de texte principale du mode.
  final Color? valueColor;
}

class _StatusDetailsRow extends StatelessWidget {
  const _StatusDetailsRow({required this.detail});
  final _StatusDetail detail;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Expanded(
          child: Text(
            detail.label,
            style: TextStyle(color: palette.onSurface(.6), fontSize: 7),
          ),
        ),
        Text(
          detail.value,
          style: TextStyle(
            color: detail.valueColor ?? palette.textPrimary,
            fontSize: 8,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

const String _kSupportWhatsAppNumber = '22676691911';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ParentPageScaffold(
      children: [
        const Center(child: EduPayLogo(size: 28)),
        const SizedBox(height: 22),
        const AppCard(
          child: Column(
            children: [
              _InfoRow(label: 'WhatsApp', value: '+226 76 69 19 11'),
              _InfoRow(label: 'Horaires', value: '7j/7 - 8h a 20h'),
              _InfoRow(label: 'Siege', value: 'Ouagadougou'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ActionButton(
          label: 'Ouvrir WhatsApp',
          icon: Icons.chat,
          onPressed: () => _openSupportWhatsApp(context),
        ),
      ],
    );
  }
}

/// Ouvre une conversation WhatsApp avec le centre d'aide EduPay.
Future<void> _openSupportWhatsApp(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final uri = Uri.parse('https://wa.me/$_kSupportWhatsAppNumber');
  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Contactez-nous sur WhatsApp au +226 76 69 19 11.'),
        ),
      );
    }
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Contactez-nous sur WhatsApp au +226 76 69 19 11.'),
      ),
    );
  }
}

Future<void> _confirmPayment(
  BuildContext context,
  ParentAppState state,
  int amount,
  SavingsGoalType? targetGoalType,
) async {
  final ussd = state.paymentMethod != PaymentMethod.cashAgent
      ? ussdCodeFor(state.paymentMethod, amount)
      : null;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Confirmer le paiement'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vous allez cotiser ${_money(amount)} FCFA via ${_paymentMethodLabel(state.paymentMethod)}.',
          ),
          if (ussd != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.dialpad, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Code USSD : $ussd',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          const Text('Confirmez-vous ce paiement ?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Payer'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  // Si c'est un paiement mobile money, on propose de composer le code USSD
  if (ussd != null) {
    try {
      final encodedUssd = Uri.encodeComponent(ussd);
      final telUri = Uri.parse('tel:$encodedUssd');
      await launchUrl(telUri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  await state.pay(amount: amount, targetGoalType: targetGoalType);
  if (!context.mounted) return;

  if (state.paymentState.status == RequestStatus.success) {
    context.go('/app/payment-success');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.paymentState.error?.toString() ??
              'Échec du paiement. Vérifiez votre connexion et réessayez.',
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

String _paymentMethodLabel(PaymentMethod method) => switch (method) {
  PaymentMethod.orangeMoney => 'Orange Money',
  PaymentMethod.moovMoney => 'Moov Money',
  PaymentMethod.cashAgent => 'paiement en espèces',
};

Future<void> _confirmRefund(BuildContext context, ParentAppState state) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Confirmer le remboursement'),
      content: const Text(
        'Votre demande sera envoyée et pourra être traitée sous 7 jours ouvrables.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Envoyer'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  final ok = await state.requestRefund(
    reason: state.refundReasonController.text,
  );
  if (!context.mounted) return;
  if (ok) {
    context.go('/app/refund-success');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Échec de l’envoi de la demande. Vérifiez votre connexion et réessayez.',
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.method,
    required this.title,
    required this.badge,
    required this.color,
  });

  final PaymentMethod method;
  final String title;
  final String badge;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;
    final selected = state.paymentMethod == method;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: () => state.selectPaymentMethod(method),
        borderColor: selected ? palette.accentYellow : null,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              foregroundColor: Colors.white,
              child: Text(
                badge,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? palette.accentYellow : palette.onSurface(.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: context.palette.onSurface(.55)),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

String _money(int value) {
  final raw = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final fromEnd = raw.length - i;
    buffer.write(raw[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) {
      buffer.write(' ');
    }
  }
  return buffer.toString();
}

/// Rôle visuel d'une notification (couleur/tonalité), dérivé du `type` réel
/// renvoyé par le backend (`notifications.service.ts::NotificationType`).
enum _NotifTone { success, info, warning }

(IconData, _NotifTone) _iconAndToneForType(String type) => switch (type) {
  'contribution_received' => (Icons.check_circle_outline, _NotifTone.success),
  'goal_completed' => (Icons.verified, _NotifTone.success),
  'goal_threshold_70' => (Icons.emoji_events_outlined, _NotifTone.info),
  'goal_completed_admin' => (Icons.verified, _NotifTone.success),
  'contribution_failed' => (Icons.error_outline, _NotifTone.warning),
  'delivery_confirmed' => (Icons.local_shipping_outlined, _NotifTone.info),
  'delivery_issue' => (Icons.report_problem_outlined, _NotifTone.warning),
  'late_reminder' => (Icons.warning_amber_rounded, _NotifTone.warning),
  'account_approved' => (Icons.how_to_reg, _NotifTone.success),
  'account_rejected' => (Icons.block, _NotifTone.warning),
  'agent_assigned' => (Icons.support_agent, _NotifTone.info),
  'refund_processed' => (
    Icons.account_balance_wallet_outlined,
    _NotifTone.info,
  ),
  'family_archived' => (Icons.archive_outlined, _NotifTone.warning),
  _ => (Icons.notifications_outlined, _NotifTone.info),
};

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // `ParentScope.of` s'appuie sur `dependOnInheritedWidgetOfExactType`, donc
    // pas dans initState : on charge une seule fois ici.
    if (!_loaded) {
      _loaded = true;
      final state = ParentScope.of(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        state.loadNotifications();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;
    final loading = state.notificationsState.status == RequestStatus.loading;
    final hasError = state.notificationsState.status == RequestStatus.error;

    return ParentPageScaffold(
      children: [
        const PageTitle(
          'Notifications',
          subtitle: 'Vos rappels, paiements et suivis de livraison.',
        ),
        if (loading && state.notifications.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (hasError && state.notifications.isEmpty) ...[
          const SizedBox(height: 40),
          Center(
            child: Icon(
              Icons.cloud_off,
              size: 56,
              color: palette.onSurface(.4),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Impossible de charger vos notifications',
              style: TextStyle(color: palette.onSurface(.6)),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: state.loadNotifications,
              child: const Text('Réessayer'),
            ),
          ),
        ] else if (state.notifications.isEmpty) ...[
          const SizedBox(height: 40),
          Center(
            child: Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: palette.onSurface(.4),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Aucune nouvelle notification',
              style: TextStyle(color: palette.onSurface(.6), fontSize: 16),
            ),
          ),
        ] else
          for (final notif in state.notifications)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _NotificationTile(
                notif: notif,
                onTap: () => state.markNotificationRead(notif.id),
              ),
            ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notif, required this.onTap});

  final NotificationItem notif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (icon, tone) = _iconAndToneForType(notif.type);
    final color = switch (tone) {
      _NotifTone.success => palette.accentGreen,
      _NotifTone.warning => palette.accentYellow,
      _NotifTone.info => palette.accentGreen,
    };

    return AppCard(
      onTap: onTap,
      color: notif.isRead ? null : palette.accentGreen.withValues(alpha: .04),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notif.title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (!notif.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 6, top: 4),
                        decoration: BoxDecoration(
                          color: palette.accentGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notif.body,
                  style: TextStyle(
                    color: palette.onSurface(.6),
                    fontSize: 13,
                    height: 1.35,
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
