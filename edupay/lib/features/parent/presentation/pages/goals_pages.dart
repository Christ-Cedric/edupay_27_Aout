import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/action_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/parent_models.dart';
import '../parent_app_state.dart';
import '../parent_scope.dart';
import 'page_scaffold.dart';

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

/// Page principale « Nouvel objectif » : reproduit fidèlement la maquette visuelle
class GoalCategorySelectionPage extends StatelessWidget {
  const GoalCategorySelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;

    return ParentPageScaffold(
      children: [
        // En-tête avec illustration cible / rentrée
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nouvel objectif',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Montserrat',
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 38,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: palette.accentGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choisissez la catégorie de dépenses\nà planifier pour la rentrée.',
                    style: TextStyle(
                      color: palette.onSurface(.6),
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Illustration moderne de rentrée & cible
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: palette.accentGreen.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.track_changes_rounded,
                size: 28,
                color: palette.accentGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _CategoryCard(
          title: 'Fournitures scolaires',
          description:
              'Kits complets de fournitures (cahiers, livres, stylos…) adaptés à la classe de votre enfant.',
          icon: Icons.inventory_2_outlined,
          color: const Color(0xFF1B8A5A),
          onTap: () {
            if (state.children.isEmpty) {
              context.push('/app/children/add');
            } else {
              context.push('/app/children');
            }
          },
        ),
        const SizedBox(height: 14),
        _CategoryCard(
          title: 'Scolarité',
          description:
              'Frais de scolarité et inscriptions de vos enfants à régler avant la rentrée.',
          icon: Icons.school_outlined,
          color: const Color(0xFFF5A623),
          onTap: () => context.push('/app/goals/tuition'),
        ),
        const SizedBox(height: 14),
        _CategoryCard(
          title: 'Moyen de déplacement',
          description:
              'Vélo, transport scolaire ou frais de déplacement pour faciliter le trajet de votre enfant.',
          icon: Icons.directions_bike_outlined,
          color: const Color(0xFF00B4D8),
          onTap: () => context.push('/app/goals/transport'),
        ),
        const SizedBox(height: 20),
        // Bannière motivationnelle « Épargner aujourd'hui, réussir demain »
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.hairline, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: palette.accentGreen.withValues(alpha: .08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_rounded,
                  color: palette.accentGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Épargner aujourd\'hui, pour mieux réussir demain.',
                  style: TextStyle(
                    color: palette.onSurface(.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (state.totalGoal > 0) ...[
          const SizedBox(height: 20),
          ActionButton(
            label:
                'Valider et choisir la fréquence (${_money(state.totalGoal)} F)',
            onPressed: () => context.push('/app/plan'),
          ),
        ],
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: palette.hairline, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: palette.onSurface(.6),
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Page de saisie de l'objectif « Scolarité » par enfant.
class TuitionGoalPage extends StatefulWidget {
  const TuitionGoalPage({super.key});

  @override
  State<TuitionGoalPage> createState() => _TuitionGoalPageState();
}

class _TuitionGoalPageState extends State<TuitionGoalPage> {
  Future<void> _showTuitionDialog(
    BuildContext context,
    int index,
    ChildProfile child,
    ParentAppState state,
  ) async {
    final controller = TextEditingController(
      text: child.tuitionAmount > 0 ? child.tuitionAmount.toString() : '',
    );
    final palette = context.palette;

    final result = await showDialog<int?>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bouton de fermeture en haut à droite
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () => Navigator.of(ctx).pop(null),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        color: palette.onSurface(.45),
                        size: 24,
                      ),
                    ),
                  ),
                ),
                // Illustration / Badge flottant centré
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: palette.accentGreen.withValues(alpha: .08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: palette.accentGreen,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 18),
                // Titre
                Text(
                  'Scolarité de ${child.firstName}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                // Sous-titre descriptif
                Text(
                  '${child.level} · ${child.school}\nRenseignez le montant total des frais de scolarité à épargner pour l\'année.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.onSurface(.6),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                // Champ de saisie moderne
                TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Icon(
                        Icons.payments_outlined,
                        color: palette.accentGreen,
                      ),
                    ),
                    suffixText: 'FCFA',
                    suffixStyle: const TextStyle(fontWeight: FontWeight.w700),
                    hintText: 'Ex. 50 000',
                    filled: true,
                    fillColor: palette.surfaceSoft,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: palette.hairline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: palette.hairline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: palette.accentGreen,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Bouton pilule Confirm / Valider
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.primary,
                      foregroundColor: palette.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () {
                      final amount = int.tryParse(controller.text.trim()) ?? 0;
                      Navigator.of(ctx).pop(amount);
                    },
                    child: const Text('Confirmer'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null && context.mounted) {
      await state.setChildTuition(index, result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result > 0
                ? 'Scolarité de ${_money(result)} FCFA enregistrée pour ${child.firstName}.'
                : 'Scolarité réinitialisée pour ${child.firstName}.',
          ),
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;

    if (state.children.isEmpty) {
      return ParentPageScaffold(
        children: [
          const PageTitle(
            'Scolarité',
            subtitle: 'Enregistrez le montant de la scolarité de vos enfants.',
          ),
          AppCard(
            child: Column(
              children: [
                Icon(Icons.child_care, color: palette.onSurface(.4), size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Aucun enfant enregistré',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  'Veuillez d\'abord ajouter un enfant pour lui associer des frais de scolarité.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.onSurface(.6)),
                ),
                const SizedBox(height: 16),
                ActionButton(
                  label: 'Ajouter un enfant',
                  icon: Icons.add,
                  onPressed: () => context.push('/app/children/add'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ParentPageScaffold(
      children: [
        const PageTitle(
          'Frais de Scolarité',
          subtitle: 'Définissez le montant de la scolarité à épargner.',
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: palette.accentGreen.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: palette.accentGreen.withValues(alpha: .2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.touch_app_rounded,
                color: palette.accentGreen,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Touchez un enfant pour renseigner ou modifier le montant de sa scolarité.',
                  style: TextStyle(
                    color: palette.accentGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionLabel('Enfants'),
        for (var i = 0; i < state.children.length; i++) ...[
          _ChildSelectionTile(
            child: state.children[i],
            currentAmountText: state.children[i].tuitionAmount > 0
                ? '${_money(state.children[i].tuitionAmount)} FCFA'
                : 'Cliquer pour renseigner la scolarité',
            hasAmount: state.children[i].tuitionAmount > 0,
            onTap: () =>
                _showTuitionDialog(context, i, state.children[i], state),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        TextButton.icon(
          onPressed: () => context.push('/app/children/add'),
          icon: const Icon(Icons.add),
          label: const Text('Ajouter un autre enfant'),
        ),
        const SizedBox(height: 24),
        ActionButton(
          label: 'Terminer',
          icon: Icons.check,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/app/goals');
            }
          },
        ),
      ],
    );
  }
}

/// Page de saisie de l'objectif « Moyen de déplacement » par enfant.
class TransportGoalPage extends StatefulWidget {
  const TransportGoalPage({super.key});

  @override
  State<TransportGoalPage> createState() => _TransportGoalPageState();
}

class _TransportGoalPageState extends State<TransportGoalPage> {
  static const List<String> _transportTypes = [
    'Vélo',
    'Transport scolaire',
    'Moto / Scooter',
    'Abonnement bus',
    'Autre moyen',
  ];

  Future<void> _showTransportDialog(
    BuildContext context,
    int index,
    ChildProfile child,
    ParentAppState state,
  ) async {
    final controller = TextEditingController(
      text: child.transportAmount > 0 ? child.transportAmount.toString() : '',
    );
    String currentType =
        child.transportType != null &&
            _transportTypes.contains(child.transportType)
        ? child.transportType!
        : _transportTypes.first;
    final palette = context.palette;

    final result = await showDialog<(int, String)?>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bouton de fermeture en haut à droite
                      Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () => Navigator.of(ctx).pop(null),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close_rounded,
                              color: palette.onSurface(.45),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      // Illustration / Badge flottant centré
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B4D8).withValues(alpha: .08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.directions_bike_rounded,
                          color: Color(0xFF00B4D8),
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Titre
                      Text(
                        'Déplacement de ${child.firstName}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Sous-titre descriptif
                      Text(
                        '${child.level} · ${child.school}\nChoisissez le moyen de déplacement et fixez le budget à épargner.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: palette.onSurface(.6),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Encadrement des options de déplacement
                      Container(
                        decoration: BoxDecoration(
                          color: palette.surfaceSoft,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: palette.hairline),
                        ),
                        child: Column(
                          children: [
                            for (
                              var j = 0;
                              j < _transportTypes.length;
                              j++
                            ) ...[
                              RadioListTile<String>(
                                dense: true,
                                value: _transportTypes[j],
                                groupValue: currentType,
                                activeColor: const Color(0xFF00B4D8),
                                title: Text(
                                  _transportTypes[j],
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onChanged: (val) {
                                  if (val != null) {
                                    setDialogState(() => currentType = val);
                                  }
                                },
                              ),
                              if (j < _transportTypes.length - 1)
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: palette.hairline.withValues(alpha: .5),
                                ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Champ de saisie moderne
                      TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Icon(
                              Icons.payments_outlined,
                              color: Color(0xFF00B4D8),
                            ),
                          ),
                          suffixText: 'FCFA',
                          suffixStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                          hintText: 'Ex. 35 000',
                          filled: true,
                          fillColor: palette.surfaceSoft,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: palette.hairline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: palette.hairline),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide: BorderSide(
                              color: Color(0xFF00B4D8),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      // Bouton pilule Confirm
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: palette.primary,
                            foregroundColor: palette.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          onPressed: () {
                            final amount =
                                int.tryParse(controller.text.trim()) ?? 0;
                            Navigator.of(ctx).pop((amount, currentType));
                          },
                          child: const Text('Confirmer'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null && context.mounted) {
      final (amount, type) = result;
      await state.setChildTransport(index, amount, amount > 0 ? type : null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            amount > 0
                ? 'Moyen de déplacement ($type : ${_money(amount)} FCFA) enregistré pour ${child.firstName}.'
                : 'Moyen de déplacement réinitialisé pour ${child.firstName}.',
          ),
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;

    if (state.children.isEmpty) {
      return ParentPageScaffold(
        children: [
          const PageTitle(
            'Moyen de déplacement',
            subtitle:
                'Planifiez l\'achat d\'un vélo ou le transport de votre enfant.',
          ),
          AppCard(
            child: Column(
              children: [
                Icon(
                  Icons.directions_bike_outlined,
                  color: palette.onSurface(.4),
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Aucun enfant enregistré',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  'Veuillez d\'abord ajouter un enfant pour lui associer un moyen de déplacement.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.onSurface(.6)),
                ),
                const SizedBox(height: 16),
                ActionButton(
                  label: 'Ajouter un enfant',
                  icon: Icons.add,
                  onPressed: () => context.push('/app/children/add'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ParentPageScaffold(
      children: [
        const PageTitle(
          'Moyen de déplacement',
          subtitle: 'Préparez le déplacement de vos enfants pour l\'année.',
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF00B4D8).withValues(alpha: .08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF00B4D8).withValues(alpha: .2),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.touch_app_rounded, color: Color(0xFF00B4D8), size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Touchez un enfant pour choisir son mode de transport et renseigner le montant.',
                  style: TextStyle(
                    color: Color(0xFF00B4D8),
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionLabel('Enfants'),
        for (var i = 0; i < state.children.length; i++) ...[
          _ChildSelectionTile(
            child: state.children[i],
            currentAmountText: state.children[i].transportAmount > 0
                ? '${state.children[i].transportType ?? "Transport"} : ${_money(state.children[i].transportAmount)} FCFA'
                : 'Cliquer pour renseigner le déplacement',
            hasAmount: state.children[i].transportAmount > 0,
            onTap: () =>
                _showTransportDialog(context, i, state.children[i], state),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        TextButton.icon(
          onPressed: () => context.push('/app/children/add'),
          icon: const Icon(Icons.add),
          label: const Text('Ajouter un autre enfant'),
        ),
        const SizedBox(height: 24),
        ActionButton(
          label: 'Terminer',
          icon: Icons.check,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/app/goals');
            }
          },
        ),
      ],
    );
  }
}

class _ChildSelectionTile extends StatelessWidget {
  const _ChildSelectionTile({
    required this.child,
    required this.currentAmountText,
    required this.hasAmount,
    required this.onTap,
  });

  final ChildProfile child;
  final String currentAmountText;
  final bool hasAmount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppCard(
      onTap: onTap,
      borderColor: hasAmount
          ? palette.accentGreen.withValues(alpha: .20)
          : palette.hairline,
      color: palette.surface,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: palette.surfaceSoft,
            foregroundColor: palette.onSurface(.7),
            child: Text(
              child.firstName.isNotEmpty
                  ? child.firstName.substring(0, 1).toUpperCase()
                  : '?',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.firstName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${child.level} · ${child.school}',
                  style: TextStyle(color: palette.onSurface(.55), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            currentAmountText,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: hasAmount ? palette.accentGreen : palette.onSurface(.5),
            ),
          ),
        ],
      ),
    );
  }
}
