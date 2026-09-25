import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/action_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_progress_bar.dart';
import '../../domain/parent_models.dart';
import '../../domain/parent_use_cases.dart';
import '../../domain/savings_engine.dart';
import '../../domain/school_catalogue.dart';
import '../parent_scope.dart';
import 'page_scaffold.dart';

/// Detail page for one child's savings — merges "Fournitures" (breakdown by
/// category) and "Épargne en cours" (progress + contribution history), since
/// both entry points (SavingsPage, HomePage "Mes objectifs") point at the
/// exact same underlying data for a child.
class SavingsDetailPage extends StatefulWidget {
  const SavingsDetailPage({required this.childIndex, super.key});

  final int childIndex;

  @override
  State<SavingsDetailPage> createState() => _SavingsDetailPageState();
}

enum _SavingsDetailTab { supplies, tuition, transport }

class _SavingsDetailPageState extends State<SavingsDetailPage> {
  _SavingsDetailTab _selectedTab = _SavingsDetailTab.supplies;

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;
    final child = state.children[widget.childIndex];
    final selection = child.kitSelection;

    final resolvedKit = child.resolvedKit;

    int target;
    int savedAmount;
    String progressTitle;
    SavingsGoalType? goalType;

    switch (_selectedTab) {
      case _SavingsDetailTab.supplies:
        target = child.suppliesCost;
        savedAmount = child.kitSavedAmount;
        progressTitle = 'Progression fournitures';
        goalType = SavingsGoalType.supplies;
        break;
      case _SavingsDetailTab.tuition:
        target = child.tuitionAmount;
        savedAmount = child.tuitionSavedAmount;
        progressTitle = 'Progression scolarité';
        goalType = SavingsGoalType.registration;
        break;
      case _SavingsDetailTab.transport:
        target = child.transportAmount;
        savedAmount = child.transportSavedAmount;
        progressTitle = 'Progression déplacement';
        goalType = SavingsGoalType.transport;
        break;
    }

    final progress = target == 0 ? 0.0 : (savedAmount / target).clamp(0.0, 1.0);
    final remaining = (target - savedAmount).clamp(0, target);
    final percent = (progress * 100).round();
    final status = _status(savedAmount, target);

    // BUG #2 fix : utiliser le plan de la catégorie active, pas le plan global.
    // Cela garantit que la "part de cet enfant" est calculée sur le reste DUE
    // de cette catégorie uniquement, et non sur le reste de toutes les cotisations.
    final categoryPlan = goalType != null
        ? state.savingsPlanFor(goalType!)
        : state.savingsPlan;
    final childShare = childShareOfContribution(
      contribution: categoryPlan.perPeriodAmount,
      childRemaining: remaining,
      globalRemaining: categoryPlan.globalRemaining > 0
          ? categoryPlan.globalRemaining
          : 1, // évite division par zéro
    );
    final history = state.contributionsFor(child.firstName);

    final byCategory = <String, List<CatalogueArticle>>{};
    for (final item in resolvedKit?.lineItems ?? const <CatalogueArticle>[]) {
      byCategory.putIfAbsent(item.category, () => []).add(item);
    }

    return ParentPageScaffold(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: palette.accentGreen,
              foregroundColor: Colors.white,
              child: Text(
                child.firstName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cotisation ${child.firstName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${child.level} · ${child.school}',
                    style: TextStyle(
                      color: palette.onSurface(.55),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Année scolaire $kSchoolYear',
                    style: TextStyle(
                      color: palette.onSurface(.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppCard(
          borderColor: palette.accentGreen.withValues(alpha: .4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      progressTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      '${_money(savedAmount)} FCFA',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: TextStyle(
                      color: palette.onSurface(.6),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  final fillWidth = maxWidth * progress;
                  return Container(
                    height: 28,
                    width: maxWidth,
                    decoration: BoxDecoration(
                      color: palette.onSurface(.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Text(
                              'Objectif : ${_money(target)} F',
                              style: TextStyle(
                                color: palette.onSurface(.4),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        if (progress > 0)
                          Container(
                            width: fillWidth,
                            height: 28,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF82F4B1), Color(0xFF30C5D2)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF30C5D2,
                                  ).withValues(alpha: 0.4),
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
              const SizedBox(height: 16),
              if (percent >= 70)
                _MilestoneBanner(percent: percent),
              if (percent >= 70)
                const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: palette.onSurface(.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: palette.onSurface(.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Plus de détails',
                          style: TextStyle(
                            color: palette.onSurface(.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: palette.onSurface(.8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(height: 26, color: palette.hairline),
              _MetricRow(
                label: 'Reste à payer',
                value: '${_money(remaining)} F',
              ),
              _MetricRow(
                label: 'Prochaine échéance (part de ${child.firstName})',
                value: '${_money(childShare)} F / ${state.plan.period}',
              ),
              _MetricRow(
                label: 'Date prévue',
                value: _formatDate(kSubscriptionDeadline),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        // Les trois boutons de filtrage pour les informations spécifiques
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterTabButton(
                icon: Icons.inventory_2_outlined,
                label: 'Fournitures',
                amount: child.suppliesCost,
                isSelected: _selectedTab == _SavingsDetailTab.supplies,
                color: palette.accentGreen,
                onTap: () =>
                    setState(() => _selectedTab = _SavingsDetailTab.supplies),
              ),
              const SizedBox(width: 8),
              _FilterTabButton(
                icon: Icons.school_outlined,
                label: 'Scolarité',
                amount: child.tuitionAmount,
                isSelected: _selectedTab == _SavingsDetailTab.tuition,
                color: palette.accentYellow,
                onTap: () =>
                    setState(() => _selectedTab = _SavingsDetailTab.tuition),
              ),
              const SizedBox(width: 8),
              _FilterTabButton(
                icon: Icons.directions_bike_outlined,
                label: 'Déplacement',
                amount: child.transportAmount,
                isSelected: _selectedTab == _SavingsDetailTab.transport,
                color: const Color(0xFF00B4D8),
                onTap: () =>
                    setState(() => _selectedTab = _SavingsDetailTab.transport),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Vue filtrée selon le bouton sélectionné
        if (_selectedTab == _SavingsDetailTab.supplies) ...[
          if (selection == null || (resolvedKit?.price ?? 0) == 0)
            AppCard(
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: palette.onSurface(.4),
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aucun kit de fournitures choisi pour ${child.firstName}.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: palette.onSurface(.6)),
                  ),
                  const SizedBox(height: 12),
                  ActionButton(
                    label: 'Choisir un kit',
                    icon: Icons.checklist,
                    secondary: true,
                    onPressed: () => context.push('/app/children/kits'),
                  ),
                ],
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: SectionLabel('Détail du kit : ${selection.title}'),
                ),
                Text(
                  '${_money(resolvedKit?.price ?? 0)} FCFA',
                  style: TextStyle(
                    color: palette.accentGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Builder(
              builder: (context) {
                final rem = (child.suppliesCost - child.kitSavedAmount).clamp(
                  0,
                  child.suppliesCost,
                );
                final days = kSubscriptionDeadline
                    .difference(DateTime.now())
                    .inDays;
                final daysRemaining = days > 0 ? days : 0;
                final daily = daysRemaining > 0
                    ? (rem / daysRemaining).ceil()
                    : rem;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: palette.accentGreen.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: palette.accentGreen.withValues(alpha: .2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Échéance : 15 sept. ($daysRemaining j restants)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: palette.onSurface(.75),
                        ),
                      ),
                      Text(
                        '${_money(daily)} FCFA / jour',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: palette.accentGreen,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            for (final category in byCategory.keys)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          color: palette.accentGreen,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final item in byCategory[category]!)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text('${item.quantity} x ${item.label}'),
                              ),
                              Text(
                                '${_money(item.unitPrice)} F',
                                style: TextStyle(
                                  color: palette.onSurface(.5),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${_money(item.subtotal)} F',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ] else if (_selectedTab == _SavingsDetailTab.tuition) ...[
          AppCard(
            borderColor: palette.accentYellow.withValues(alpha: .3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.school, color: palette.accentYellow, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Frais de scolarité',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'École : ${child.school} (Classe ${child.level})',
                            style: TextStyle(
                              color: palette.onSurface(.55),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${_money(child.tuitionAmount)} FCFA',
                      style: TextStyle(
                        color: palette.accentYellow,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
                if (child.tuitionAmount > 0) ...[
                  Builder(
                    builder: (context) {
                      final rem =
                          (child.tuitionAmount - child.tuitionSavedAmount)
                              .clamp(0, child.tuitionAmount);
                      final days = kSubscriptionDeadline
                          .difference(DateTime.now())
                          .inDays;
                      final daysRemaining = days > 0 ? days : 0;
                      final daily = daysRemaining > 0
                          ? (rem / daysRemaining).ceil()
                          : rem;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        margin: const EdgeInsets.only(top: 10, bottom: 4),
                        decoration: BoxDecoration(
                          color: palette.accentYellow.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: palette.accentYellow.withValues(alpha: .2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Échéance : 15 sept. ($daysRemaining j restants)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: palette.onSurface(.75),
                              ),
                            ),
                            Text(
                              '${_money(daily)} FCFA / jour',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: palette.accentYellow,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  child.tuitionAmount > 0
                      ? 'Les frais de scolarité de ${child.firstName} sont intégrés à votre plan de cotisation global.'
                      : 'Aucun montant de scolarité défini pour le moment.',
                  style: TextStyle(color: palette.onSurface(.6), fontSize: 13),
                ),
                const SizedBox(height: 14),
                ActionButton(
                  label: child.tuitionAmount > 0
                      ? 'Modifier le montant'
                      : 'Définir la scolarité',
                  icon: Icons.edit_outlined,
                  secondary: true,
                  onPressed: () => context.push('/app/goals/tuition'),
                ),
              ],
            ),
          ),
        ] else if (_selectedTab == _SavingsDetailTab.transport) ...[
          AppCard(
            borderColor: const Color(0xFF00B4D8).withValues(alpha: .3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.directions_bike,
                      color: Color(0xFF00B4D8),
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            child.transportType ?? 'Moyen de déplacement',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Trajet domicile - école (${child.school})',
                            style: TextStyle(
                              color: palette.onSurface(.55),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${_money(child.transportAmount)} FCFA',
                      style: const TextStyle(
                        color: Color(0xFF00B4D8),
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
                if (child.transportAmount > 0) ...[
                  Builder(
                    builder: (context) {
                      final deadline =
                          child.transportDeadline ?? kSubscriptionDeadline;
                      final rem =
                          (child.transportAmount - child.transportSavedAmount)
                              .clamp(0, child.transportAmount);
                      final days = deadline.difference(DateTime.now()).inDays;
                      final daysRemaining = days > 0 ? days : 0;
                      final daily = daysRemaining > 0
                          ? (rem / daysRemaining).ceil()
                          : rem;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        margin: const EdgeInsets.only(top: 10, bottom: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B4D8).withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFF00B4D8,
                            ).withValues(alpha: .2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Fin : ${DateFormat("dd/MM/yyyy").format(deadline)} ($daysRemaining j)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: palette.onSurface(.75),
                              ),
                            ),
                            Text(
                              '${_money(daily)} FCFA / jour',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF00B4D8),
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  child.transportAmount > 0
                      ? 'Le budget déplacement pour ${child.firstName} (${child.transportType ?? "Transport"}) est inclus dans votre cotisation.'
                      : 'Aucun moyen de déplacement défini pour le moment.',
                  style: TextStyle(color: palette.onSurface(.6), fontSize: 13),
                ),
                const SizedBox(height: 14),
                ActionButton(
                  label: child.transportAmount > 0
                      ? 'Modifier le déplacement'
                      : 'Ajouter un déplacement',
                  icon: Icons.edit_outlined,
                  secondary: true,
                  onPressed: () => context.push('/app/goals/transport'),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        const SectionLabel('Historique des versements reçus'),
        if (history.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Aucune cotisation pour le moment.',
              style: TextStyle(color: palette.onSurface(.5)),
            ),
          )
        else
          for (final contribution in history)
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
                            contribution.method,
                            style: TextStyle(color: palette.onSurface(.55)),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '+${_money(state.shareOf(contribution, child.firstName))} F',
                      style: TextStyle(
                        color: palette.accentGreen,
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

class _FilterTabButton extends StatelessWidget {
  const _FilterTabButton({
    required this.icon,
    required this.label,
    required this.amount,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int amount;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: .18)
                : palette.onSurface(.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : palette.hairline,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? color : palette.onSurface(.6),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isSelected ? color : palette.textPrimary,
                    ),
                  ),
                  Text(
                    '${_money(amount)} F',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : palette.onSurface(.5),
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

/// Bannière de célébration affichée quand la progression atteint 70 % ou 100 %.
/// À 70 % : gradient orange/jaune + icône 🎁 (commande déclenchable).
/// À 100 % : gradient vert + icône 🏆 (objectif atteint).
class _MilestoneBanner extends StatelessWidget {
  const _MilestoneBanner({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final isComplete = percent >= 100;
    final gradient = isComplete
        ? const LinearGradient(
            colors: [Color(0xFF30C5D2), Color(0xFF82F4B1)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFFFA040), Color(0xFFFFD700)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          );
    final icon = isComplete ? '🏆' : '🎁';
    final title = isComplete ? 'Objectif atteint !' : 'Commande déclenchable !';
    final subtitle = isComplete
        ? 'Félicitations ! Votre épargne est complète. Votre kit va être préparé.'
        : 'Vous avez atteint $percent % de votre objectif. La commande peut être lancée.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: (isComplete ? const Color(0xFF30C5D2) : const Color(0xFFFFA040))
                .withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
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

/// Vue d'ensemble de l'épargne : total consolidé de tous les enfants + le
/// détail par enfant. Accessible depuis l'étape « Épargne en cours » du suivi
/// de livraison. Chaque enfant reste cliquable pour son détail complet.
class SavingsOverviewPage extends StatelessWidget {
  const SavingsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;
    final globalProgress = state.totalGoal == 0
        ? 0.0
        : (state.totalSaved / state.totalGoal).clamp(0.0, 1.0);
    final remaining = (state.totalGoal - state.totalSaved).clamp(
      0,
      state.totalGoal,
    );

    return ParentPageScaffold(
      children: [
        const PageTitle(
          'Épargne en cours',
          subtitle: 'Détail global et par enfant.',
        ),
        AppCard(
          borderColor: palette.accentGreen.withValues(alpha: .4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ÉPARGNE TOTALE',
                style: TextStyle(
                  color: palette.accentGreen,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_money(state.totalSaved)} FCFA',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 8),
              AppProgressBar(
                progress: globalProgress,
                height: 8,
                backgroundColor: palette.onSurface(.08),
                color: palette.accentGreen,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Objectif ${_money(state.totalGoal)} F',
                      style: TextStyle(color: palette.onSurface(.55)),
                    ),
                  ),
                  Text(
                    '${state.progress}%',
                    style: TextStyle(
                      color: palette.accentGreen,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Divider(height: 26, color: palette.hairline),
              _MetricRow(
                label: 'Reste à épargner',
                value: '${_money(remaining)} F',
              ),
              _MetricRow(
                label: 'Enfants inscrits',
                value: '${state.children.length}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionLabel('Détail par enfant'),
        for (var index = 0; index < state.children.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ChildSavingsCard(index: index),
          ),
      ],
    );
  }
}

/// Carte récapitulative de l'épargne d'un enfant, cliquable vers son détail.
class _ChildSavingsCard extends StatelessWidget {
  const _ChildSavingsCard({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;
    final child = state.children[index];
    final target = child.totalCost;
    final progress = target == 0
        ? 0.0
        : (child.savedAmount / target).clamp(0.0, 1.0);
    final percent = (progress * 100).round();
    final status = _status(child.savedAmount, target);

    return AppCard(
      onTap: () => context.push('/app/savings/$index'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: palette.accentGreen,
                foregroundColor: Colors.white,
                child: Text(child.firstName.substring(0, 1).toUpperCase()),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.firstName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      child.kitSelection?.title ?? 'Kit à choisir',
                      style: TextStyle(
                        color: palette.onSurface(.55),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 10),
          AppProgressBar(
            progress: progress,
            height: 8,
            backgroundColor: palette.onSurface(.10),
            color: palette.accentGreen,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_money(child.savedAmount)} / ${_money(target)} F',
                  style: TextStyle(color: palette.onSurface(.6), fontSize: 12),
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  color: palette.accentGreen,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _status(int saved, int target) {
  if (target <= 0) return 'À définir';
  if (saved >= target) return 'Terminé';
  if (saved / target >= 0.8) return 'Presque terminé';
  return 'En cours';
}

Color _statusColor(AppPalette palette, String status) => switch (status) {
  'Terminé' => palette.accentGreen,
  'Presque terminé' => palette.accentYellow,
  _ => AppColors.info,
};

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context.palette, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: context.palette.onSurface(.6),
              fontSize: 12,
            ),
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}

const _months = [
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre',
];

String _formatDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';

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
