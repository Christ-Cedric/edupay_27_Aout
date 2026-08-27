import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/action_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/edupay_logo.dart';
import '../../data/contract_pdf_exporter.dart';
import '../../domain/contract_document.dart';
import '../../domain/parent_models.dart';
import '../../domain/savings_engine.dart';
import '../../domain/school_catalogue.dart';
import '../parent_scope.dart';
import 'page_scaffold.dart';
import '../../../../shared/widgets/progress_stepper.dart';

/// Icône associée à chaque fréquence, côté présentation (le modèle de domaine
/// ne dépend pas de Material).
extension _PlanIcon on SavingsPlan {
  IconData get icon => switch (this) {
    SavingsPlan.daily => Icons.wb_sunny_outlined,
    SavingsPlan.weekly => Icons.calendar_view_week_rounded,
    SavingsPlan.monthly => Icons.calendar_month_rounded,
  };
}

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

/// Étape 2 de la souscription (BUSINESS_RULES.md) : choix de la fréquence,
/// une fois les kits déjà choisis. Chaque option affiche le montant par
/// échéance qu'elle implique (calculé depuis le total des kits déjà
/// sélectionnés), pour que le parent choisisse en connaissance de cause.
class PlanPage extends StatelessWidget {
  const PlanPage({super.key, this.editOnly = false});

  /// `true` quand on arrive depuis le profil (« Mon plan d'épargne ») : on
  /// modifie uniquement la fréquence, sans enchaîner vers le contrat.
  final bool editOnly;

  @override
  Widget build(BuildContext context) {
    return ParentPageScaffold(
      children: [
        if (!editOnly) const ProgressStepper(currentStep: 4, totalSteps: 5),
        _PageHeader(
          title: editOnly
              ? "Modifier ma fréquence"
              : 'Choisissez votre fréquence',
          subtitle: editOnly
              ? 'Change le rythme de cotisation. Les montants sont recalculés automatiquement.'
              : 'Vos kits sont choisis : sélectionnez maintenant le rythme de cotisation.',
        ),
        const SizedBox(height: 8),
        ...SavingsPlan.values.map(
          (plan) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PlanTile(plan: plan),
          ),
        ),
        const SizedBox(height: 16),
        if (editOnly)
          ActionButton(
            label: 'Enregistrer',
            icon: Icons.check_rounded,
            isLarge: true,
            onPressed: () {
              // La fréquence est déjà appliquée à la sélection (réactif) ; on
              // persiste au mieux puis on revient au profil.
              ParentScope.of(context).confirmSubscriptionPlan();
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/app/profile');
              }
            },
          )
        else
          ActionButton(
            label: 'Voir le contrat',
            icon: Icons.description_outlined,
            onPressed: () => context.push('/app/contract'),
            isLarge: true,
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: palette.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            color: palette.onSurface(0.6),
            fontSize: 15,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 3,
          width: 48,
          decoration: BoxDecoration(
            color: palette.accentYellow,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.plan});

  final SavingsPlan plan;

  String get _periodLabel {
    switch (plan.period) {
      case 'jour':
        return 'quotidienne';
      case 'semaine':
        return 'hebdomadaire';
      case 'mois':
        return 'mensuelle';
      default:
        return '';
    }
  }

  String get _helper {
    switch (plan) {
      case SavingsPlan.daily:
        return 'Simple pour petits paiements';
      case SavingsPlan.weekly:
        return 'Recommandé pour la plupart des familles';
      case SavingsPlan.monthly:
        return 'Pratique pour salaires mensuels';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;
    final selected = state.plan == plan;
    // Montant par échéance pour CETTE fréquence spécifiquement (indépendant
    // de la fréquence actuellement sélectionnée) : permet d'afficher les 3
    // options côte à côte avec leur propre montant.
    final amountForThisPlan = computeSavingsPlan(
      children: state.children,
      frequency: plan,
    ).perPeriodAmount;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? palette.accentYellow : palette.hairline,
          width: selected ? 2 : 1,
        ),
        color: selected
            ? palette.accentYellow.withValues(alpha: 0.06)
            : palette.onSurface(0.02),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: palette.accentYellow.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => state.selectPlan(plan),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? palette.accentYellow
                        : palette.onSurface(0.06),
                  ),
                  child: Icon(
                    selected ? Icons.check_rounded : plan.icon,
                    color: selected ? Colors.white : palette.onSurface(0.4),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.title,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: selected
                              ? palette.textPrimary
                              : palette.onSurface(0.7),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cotisation $_periodLabel',
                        style: TextStyle(
                          color: palette.onSurface(0.5),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          '${_money(amountForThisPlan)} FCFA / ${plan.period}',
                          key: ValueKey(amountForThisPlan),
                          style: TextStyle(
                            color: selected
                                ? palette.accentGreen
                                : palette.accentGreen.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            fontFamily: 'Montserrat',
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _helper,
                        style: TextStyle(
                          color: palette.onSurface(0.45),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? palette.accentYellow
                          : palette.onSurface(0.2),
                      width: selected ? 0 : 2,
                    ),
                    color: selected ? palette.accentYellow : Colors.transparent,
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Étape 2 de la souscription : un kit choisi pour CHAQUE enfant
class AssignKitsPage extends StatelessWidget {
  const AssignKitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final assignedCount = state.children
        .where((c) => c.suppliesCost > 0 || state.isKitLocked(c))
        .length;

    return ParentPageScaffold(
      children: [
        const ProgressStepper(currentStep: 3, totalSteps: 5),
        const _PageHeader(
          title: 'Un kit par enfant',
          subtitle: 'Choisissez le kit scolaire de chacun de vos enfants.',
        ),
        const SizedBox(height: 4),
        ...List.generate(state.children.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _ChildKitCard(index: index, child: state.children[index]),
          );
        }),
        const SizedBox(height: 8),
        _SummaryCard(
          childCount: state.children.length,
          assignedCount: assignedCount,
          totalGoal: state.totalGoal,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ActionButton(
                label: 'Continuer vers la fréquence',
                onPressed: state.allChildrenHaveKit
                    ? () => context.push('/app/plan')
                    : null,
                isLarge: true,
              ),
            ),
            const SizedBox(width: 12),
            _HelpButton(onTap: () => context.push('/app/contact')),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.childCount,
    required this.assignedCount,
    required this.totalGoal,
  });

  final int childCount;
  final int assignedCount;
  final int totalGoal;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppCard(
      color: palette.accentGreen.withValues(alpha: 0.08),
      borderColor: palette.accentGreen.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: palette.accentGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: palette.accentGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Résumé de la sélection',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$childCount enfant${childCount > 1 ? 's' : ''} · '
                  '$assignedCount kit${assignedCount > 1 ? 's' : ''} sélectionné${assignedCount > 1 ? 's' : ''}',
                  style: TextStyle(color: palette.onSurface(0.5), fontSize: 12),
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              '${_money(totalGoal)} F',
              key: ValueKey(totalGoal),
              style: TextStyle(
                color: palette.accentGreen,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                fontFamily: 'Montserrat',
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpButton extends StatelessWidget {
  const _HelpButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          border: Border.all(
            color: palette.accentYellow.withValues(alpha: 0.4),
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(
          Icons.help_outline_rounded,
          color: palette.accentYellow,
          size: 24,
        ),
      ),
    );
  }
}

class _ChildKitCard extends StatefulWidget {
  const _ChildKitCard({required this.index, required this.child});

  final int index;
  final ChildProfile child;

  @override
  State<_ChildKitCard> createState() => _ChildKitCardState();
}

class _ChildKitCardState extends State<_ChildKitCard> {
  bool _showDetails = false;

  void _notifyLocked(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Ce kit a déjà commencé à être financé : il ne peut plus être modifié.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;
    final selection = widget.child.kitSelection;
    // Prix/contenu résolus depuis le catalogue officiel pour la classe précise
    // de cet enfant (voir school_catalogue.dart).
    final resolvedKit = widget.child.resolvedKit;
    final kitLineItems = resolvedKit?.lineItems ?? const <CatalogueArticle>[];
    // Règle métier : un kit financé à ≥ 75 % est verrouillé (plus de
    // modification/remplacement). On désactive alors les tuiles de choix.
    final locked = state.isKitLocked(widget.child);

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: palette.accentGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    widget.child.firstName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.child.firstName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: palette.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.child.level} · ${widget.child.school}',
                      style: TextStyle(
                        color: palette.onSurface(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (selection != null || locked) ...[
                if (locked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: palette.accentYellow.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          color: palette.accentYellow,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verrouillé',
                          style: TextStyle(
                            color: palette.accentYellow,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: palette.accentGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_money(resolvedKit?.price ?? 0)} F',
                      style: TextStyle(
                        color: palette.accentGreen,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Opacity(
            // Verrouillé : les tuiles restent visibles mais grisées et inertes.
            opacity: locked ? 0.5 : 1,
            child: Row(
              children: [
                for (final kit in SchoolKit.values) ...[
                  Expanded(
                    child: _KitTile(
                      icon: Icons.shopping_basket_rounded,
                      color: palette.accentGreen,
                      label: kit.title,
                      selected:
                          selection?.type == KitSelectionType.standard &&
                          selection?.standardKit == kit,
                      onTap: locked
                          ? () => _notifyLocked(context)
                          : () => state.assignStandardKit(widget.index, kit),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: _KitTile(
                    icon: Icons.tune_rounded,
                    color: palette.accentGreen,
                    label: 'Personnaliser',
                    selected: selection?.type == KitSelectionType.custom,
                    onTap: locked
                        ? () => _notifyLocked(context)
                        : () => context.push(
                            '/app/children/kits/custom/${widget.index}',
                          ),
                  ),
                ),
              ],
            ),
          ),
          // Composition du kit sélectionné : elle apparaît sous les tuiles dès
          // qu'un kit est choisi. Un aperçu (2 articles) est affiché, puis
          // « Voir plus » déroule le kit complet avec le détail des articles.
          if (selection != null) ...[
            const SizedBox(height: 14),
            Divider(height: 1, color: palette.hairline),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.auto_awesome, color: palette.accentYellow, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _tagline(selection),
                    style: TextStyle(
                      color: palette.onSurface(0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final CatalogueArticle item
                in _showDetails ? kitLineItems : kitLineItems.take(2))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: palette.onSurface(0.35),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${item.quantity} × ${item.label}',
                        style: TextStyle(
                          color: palette.onSurface(0.75),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      '${_money(item.subtotal)} F',
                      style: TextStyle(
                        color: palette.onSurface(0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            if (kitLineItems.length > 2)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() => _showDetails = !_showDetails),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _showDetails
                            ? 'Voir moins'
                            : 'Voir plus (${kitLineItems.length} articles)',
                        style: TextStyle(
                          color: palette.accentGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Icon(
                        _showDetails
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        color: palette.accentGreen,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

String _tagline(ChildKitSelection selection) => switch (selection.type) {
  KitSelectionType.custom => 'Composez le kit à la carte, article par article.',
  KitSelectionType.standard => switch (selection.standardKit!) {
    SchoolKit.basic => 'Le nécessaire pour une année scolaire réussie.',
    SchoolKit.comfort => 'Un confort optimal pour toute l’année.',
    SchoolKit.complete => 'Tout l’équipement, sans rien à ajouter.',
  },
};

class _KitTile extends StatelessWidget {
  const _KitTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          // Fond neutre (plus de fond vert) : la sélection est signalée par la
          // bordure et la pastille de validation.
          color: palette.onSurface(0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : palette.onSurface(0.12),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              width: 44,
              height: 44,
              alignment: Alignment.center,
              // `transform` appartient au Container, pas à BoxDecoration.
              transform: selected
                  ? Matrix4.diagonal3Values(1.05, 1.05, 1)
                  : Matrix4.identity(),
              transformAlignment: Alignment.center,
              // Icône seule, sans fond vert.
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? color : palette.onSurface(0.6),
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: selected ? 20 : 16,
              height: selected ? 20 : 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? color : Colors.transparent,
                border: Border.all(
                  color: selected ? color : palette.onSurface(0.2),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Kit personnalisé pour l'enfant [childIndex] — article par article.
class CustomKitPage extends StatelessWidget {
  const CustomKitPage({required this.childIndex, super.key});

  final int childIndex;

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final child = state.children[childIndex];
    final selection = child.kitSelection;
    final total = selection?.type == KitSelectionType.custom
        ? (child.resolvedKit?.price ?? 0)
        : 0;
    // Articles réels de la classe de cet enfant, tirés du catalogue officiel
    // (aucun article générique/fictif) — voir school_catalogue.dart.
    final articles = SchoolCatalogue.articlesFor(child.level);
    final palette = context.palette;

    return ParentPageScaffold(
      children: [
        _PageHeader(
          title: 'Kit personnalisé — ${child.firstName}',
          subtitle:
              'Ajoutez les articles et ajustez leurs quantités (${child.level}).',
        ),
        const SizedBox(height: 4),
        if (articles.isEmpty)
          AppCard(
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: palette.onSurface(.5),
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  'Aucun article connu pour la classe ${child.level}.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.onSurface(.6)),
                ),
              ],
            ),
          )
        else
          ...articles.map(
            (article) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CustomItemTile(childIndex: childIndex, article: article),
            ),
          ),
        const SizedBox(height: 8),
        _CustomTotalCard(total: total),
        const SizedBox(height: 16),
        ActionButton(
          label: 'Enregistrer ce kit',
          icon: Icons.check_rounded,
          onPressed: total > 0 ? () => context.pop() : null,
          isLarge: true,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _CustomTotalCard extends StatelessWidget {
  const _CustomTotalCard({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppCard(
      color: palette.accentGreen.withValues(alpha: 0.08),
      borderColor: palette.accentGreen.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: palette.accentYellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              color: palette.accentYellow,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Total du kit personnalisé',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: palette.textPrimary,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              '${_money(total)} FCFA',
              key: ValueKey(total),
              style: TextStyle(
                color: palette.accentYellow,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                fontFamily: 'Montserrat',
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomItemTile extends StatelessWidget {
  const _CustomItemTile({required this.childIndex, required this.article});
  final int childIndex;
  final CatalogueArticle article;

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;
    final selection = state.children[childIndex].kitSelection;
    final quantity = selection?.type == KitSelectionType.custom
        ? (selection!.customItemIds[article.id] ?? 0)
        : 0;
    final selected = quantity > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? palette.accentGreen : palette.hairline,
          width: selected ? 2 : 1,
        ),
        color: selected
            ? palette.accentGreen.withValues(alpha: 0.04)
            : Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => state.toggleCustomKitItem(childIndex, article.id),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: palette.accentYellow.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: palette.accentYellow,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.label,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: palette.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            article.category,
                            style: TextStyle(
                              color: palette.onSurface(0.45),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${article.unitPrice} FCFA',
                            style: TextStyle(
                              color: palette.accentYellow,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: selected,
                      activeColor: palette.accentGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (_) =>
                          state.toggleCustomKitItem(childIndex, article.id),
                    ),
                  ],
                ),
                if (selected) ...[
                  const SizedBox(height: 12),
                  Divider(height: 1, color: palette.hairline),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Quantité',
                        style: TextStyle(
                          color: palette.onSurface(0.6),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 14),
                      _QuantityStepper(
                        quantity: quantity,
                        onDecrement: () => state.changeCustomKitItemQuantity(
                          childIndex,
                          article.id,
                          -1,
                        ),
                        onIncrement: () => state.changeCustomKitItemQuantity(
                          childIndex,
                          article.id,
                          1,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: palette.onSurface(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onDecrement,
            icon: const Icon(Icons.remove_rounded, size: 18),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$quantity',
              style: TextStyle(
                color: palette.accentGreen,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          IconButton(
            onPressed: onIncrement,
            icon: const Icon(Icons.add_rounded, size: 18),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

/// Étape 4 de la souscription : le contrat complet et personnalisé (repris
/// du modèle EduPay_Contrat_Parent_CGV.docx) est affiché pour lecture, avec
/// les montants enfin visibles, avant acceptation.
class ContractPage extends StatelessWidget {
  const ContractPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final document = buildContractDocument(
      profile: state.profile,
      children: state.children,
      plan: state.plan,
      totalGoal: state.totalGoal,
      installmentAmount: state.installmentAmount,
    );

    return ParentPageScaffold(
      children: [
        const ProgressStepper(currentStep: 5, totalSteps: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: _PageHeader(
                title: 'Votre contrat',
                subtitle:
                    'Lisez le contrat complet, vérifiez les montants puis acceptez pour confirmer.',
              ),
            ),
            _PdfDownloadButton(document: document),
          ],
        ),
        const SizedBox(height: 4),
        ...state.children.map(
          (child) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ContractChildTile(child: child),
          ),
        ),
        const SizedBox(height: 8),
        _ContractTotalCard(
          totalGoal: state.totalGoal,
          plan: state.plan,
          installmentAmount: state.installmentAmount,
        ),
        const SizedBox(height: 20),
        Text(
          'Contrat n° ${document.contractNumber}',
          style: TextStyle(
            color: context.palette.onSurface(0.45),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...document.sections.map(
          (section) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ContractSectionCard(section: section),
          ),
        ),
        const SizedBox(height: 8),
        _ContractAgreementCheckbox(
          agreed: state.signed,
          onChanged: (value) => state.setContractAgreed(value),
        ),
        const SizedBox(height: 16),

        ActionButton(
          label: 'Valider et confirmer',
          icon: Icons.check_circle_outline,
          onPressed: state.signed
              ? () async {
                  await state.confirmSubscriptionPlan();
                  if (context.mounted) context.go('/app/plan-success');
                }
              : null,
          isLarge: true,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _PdfDownloadButton extends StatelessWidget {
  const _PdfDownloadButton({required this.document});

  final ContractDocument document;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: () => exportContractPdf(document),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        margin: const EdgeInsets.only(top: 2),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          border: Border.all(color: palette.accentGreen.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(
          Icons.picture_as_pdf_outlined,
          color: palette.accentGreen,
          size: 20,
        ),
      ),
    );
  }
}

class _ContractSectionCard extends StatelessWidget {
  const _ContractSectionCard({required this.section});

  final ContractSection section;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          for (final paragraph in section.paragraphs) ...[
            Text(
              paragraph,
              style: TextStyle(
                color: palette.onSurface(0.68),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            if (paragraph != section.paragraphs.last) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _ContractChildTile extends StatelessWidget {
  const _ContractChildTile({required this.child});

  final ChildProfile child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final selection = child.kitSelection;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: palette.accentGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                child.firstName.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: palette.accentGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.firstName,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: palette.textPrimary,
                  ),
                ),
                Text(
                  selection?.title ?? 'Aucun kit sélectionné',
                  style: TextStyle(color: palette.onSurface(0.5), fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${_money(child.resolvedKit?.price ?? 0)} F',
            style: TextStyle(
              color: palette.accentYellow,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}

class _ContractTotalCard extends StatelessWidget {
  const _ContractTotalCard({
    required this.totalGoal,
    required this.plan,
    required this.installmentAmount,
  });

  final int totalGoal;
  final SavingsPlan plan;
  final int installmentAmount;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppCard(
      color: palette.accentGreen.withValues(alpha: 0.06),
      borderColor: palette.accentGreen.withValues(alpha: 0.2),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: palette.accentYellow.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.payments_outlined,
                  color: palette.accentYellow,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Total à financer',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: palette.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${_money(totalGoal)} FCFA',
            style: TextStyle(
              color: palette.accentYellow,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w800,
              fontSize: 28,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: palette.onSurface(0.04),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Échéance ${plan.title.toLowerCase()} : ${_money(installmentAmount)} FCFA / ${plan.period}',
              style: TextStyle(
                color: palette.onSurface(0.6),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Acceptation du contrat complet (affiché juste au-dessus, voir
/// `contract_document.dart`) par simple case à cocher — pas de signature
/// manuscrite : la case + la confirmation valent acceptation explicite.
class _ContractAgreementCheckbox extends StatelessWidget {
  const _ContractAgreementCheckbox({
    required this.agreed,
    required this.onChanged,
  });

  final bool agreed;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: agreed ? palette.accentGreen : palette.onSurface(0.2),
          width: agreed ? 2 : 1.5,
        ),
        color: agreed
            ? palette.accentGreen.withValues(alpha: 0.06)
            : palette.onSurface(0.02),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!agreed),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  agreed
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  color: agreed ? palette.accentGreen : palette.onSurface(0.4),
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "J'ai vérifié les montants et j'accepte les conditions de ce plan d'épargne.",
                    style: TextStyle(
                      color: palette.onSurface(0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Confirmation affichée juste après la signature du plan.
class PlanSuccessPage extends StatelessWidget {
  const PlanSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;

    return ColoredBox(
      color: palette.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 1),
              const EduPayLogo(size: 28),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.accentGreen,
                  boxShadow: [
                    BoxShadow(
                      color: palette.accentGreen.withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Plan souscrit avec succès !',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Votre épargne est activée. Vous recevrez un email de confirmation.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.onSurface(0.6),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              _SuccessSummaryCard(
                childCount: state.children.length,
                totalGoal: state.totalGoal,
                installmentAmount: state.installmentAmount,
                plan: state.plan,
              ),
              const Spacer(flex: 2),
              ActionButton(
                label: 'Accéder à mon espace',
                icon: Icons.home_rounded,
                onPressed: () => context.go('/app/home'),
                isLarge: true,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessSummaryCard extends StatelessWidget {
  const _SuccessSummaryCard({
    required this.childCount,
    required this.totalGoal,
    required this.installmentAmount,
    required this.plan,
  });

  final int childCount;
  final int totalGoal;
  final int installmentAmount;
  final SavingsPlan plan;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        children: [
          _SuccessSummaryRow(label: 'Enfants', value: '$childCount'),
          Divider(height: 1, color: palette.hairline),
          _SuccessSummaryRow(
            label: 'Total',
            value: '${_money(totalGoal)} FCFA',
            isHighlighted: true,
          ),
          Divider(height: 1, color: palette.hairline),
          _SuccessSummaryRow(
            label: 'Échéance',
            value: '${_money(installmentAmount)} FCFA / ${plan.period}',
          ),
        ],
      ),
    );
  }
}

class _SuccessSummaryRow extends StatelessWidget {
  const _SuccessSummaryRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  final String label;
  final String value;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: palette.onSurface(0.5),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
              color: isHighlighted
                  ? palette.accentYellow
                  : palette.onSurface(0.7),
              fontFamily: isHighlighted ? 'Montserrat' : null,
            ),
          ),
        ],
      ),
    );
  }
}
