import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_button.dart';
import '../../../../core/theme/widgets/app_dropdown_field.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/app_text_field.dart';
import '../../../../core/theme/widgets/app_toast.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../agents/domain/models/agent.dart';
import '../../../agents/presentation/providers/agents_providers.dart';
import '../../../kits/domain/models/kit.dart';
import '../../../kits/presentation/providers/kits_providers.dart';
import '../../../../core/domain/burkina_city.dart';
import '../../../../core/domain/school_level.dart';
import '../../domain/models/savings_plan.dart';
import '../providers/families_providers.dart';

/// Une ligne "enfant" du formulaire — prénom, niveau scolaire, école et kit
/// (seule la photo n'est pas collectée à ce stade) — chacune avec sa propre
/// vie (les contrôleurs doivent être disposés individuellement).
class _ChildFormEntry {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();
  SchoolLevel? level;
  String? kitId;

  void dispose() {
    nameController.dispose();
    schoolController.dispose();
  }
}

/// Agents proposés pour la ville/le quartier saisis — fonction pure,
/// testable sans mock de plateforme. Priorité à une correspondance exacte
/// ville + quartier ; à défaut, repli sur la ville seule ; liste vide si
/// aucun agent ne dessert cette ville (la famille reste alors sans agent).
List<Agent> matchingAgents(
  List<Agent> agents,
  BurkinaCity city,
  String? district,
) {
  bool sameCity(Agent a) =>
      a.zone.trim().toLowerCase() == city.label.trim().toLowerCase();

  final byCity = agents.where(sameCity).toList();

  final trimmedDistrict = district?.trim() ?? '';
  if (trimmedDistrict.isNotEmpty) {
    final byCityAndDistrict = byCity
        .where(
          (a) =>
              (a.district ?? '').trim().toLowerCase() ==
              trimmedDistrict.toLowerCase(),
        )
        .toList();
    if (byCityAndDistrict.isNotEmpty) return byCityAndDistrict;
  }
  return byCity;
}

/// Inscription directe d'une famille (motif `ad_in` du prototype) — passe
/// directement au statut Actif, à la différence de l'auto-inscription
/// cliente qui doit être validée (voir mémo du plan).
///
/// Un kit est choisi par enfant, pas pour toute la famille (§7 #2 du
/// contrat) : le plan de cotisation et l'agent restent au niveau du foyer,
/// l'objectif étant la somme des kits de chaque enfant.
///
/// Réutilisé par l'Admin (choix de l'agent assigné via [presetAgentName]
/// nul) et par l'Agent terrain (agent assigné imposé à la session
/// courante, dropdown masqué) plutôt que dupliqué.
class DirectEnrollmentScreen extends ConsumerStatefulWidget {
  const DirectEnrollmentScreen({
    super.key,
    this.presetAgentName,
    this.successRoutePath = '${RoutePaths.adminFamilies}/enroll/success',
  });

  /// Quand non nul, verrouille l'agent assigné (cas Agent terrain) au lieu
  /// d'afficher le menu déroulant de choix (cas Admin).
  final String? presetAgentName;
  final String successRoutePath;

  @override
  ConsumerState<DirectEnrollmentScreen> createState() =>
      _DirectEnrollmentScreenState();
}

class _DirectEnrollmentScreenState
    extends ConsumerState<DirectEnrollmentScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _districtController = TextEditingController();
  SavingsPlan _plan = SavingsPlan.weekly;
  // Une famille peut exister sans enfant (ex. ajoutés plus tard depuis l'app
  // Client) — dans ce cas l'objectif reste à 0, jamais un objectif fantôme
  // sans enfant pour le porter. Pas de ligne par défaut : ajouter un enfant
  // est une action volontaire de l'admin, pas une obligation.
  final List<_ChildFormEntry> _children = [];

  /// Ville de la famille — champ explicite et obligatoire, indépendant de
  /// tout agent (une famille peut ne pas avoir d'agent assigné).
  BurkinaCity? _city;
  bool _cityDefaultApplied = false;

  /// Sélection du menu déroulant Admin uniquement (nom complet d'un agent
  /// réel, cf. [agentsListProvider]) — sans effet quand
  /// [DirectEnrollmentScreen.presetAgentName] est fourni (cas Agent), où
  /// l'agent effectif est toujours lu depuis la session courante au moment
  /// de la soumission plutôt que figé dans un champ `late`. `null` est une
  /// valeur légitime : une famille peut ne pas avoir d'agent assigné.
  String? _agent;

  String? get _effectiveAgent => widget.presetAgentName ?? _agent;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _districtController.dispose();
    for (final child in _children) {
      child.dispose();
    }
    super.dispose();
  }

  void _addChild() {
    // Pas de kit par défaut : il dépend du niveau scolaire, pas encore
    // choisi pour cette nouvelle ligne.
    setState(() => _children.add(_ChildFormEntry()));
  }

  void _removeChild(int index) {
    setState(() => _children.removeAt(index).dispose());
  }

  /// Recalcule l'agent proposé après un changement de ville/quartier — ne
  /// touche pas au choix de l'admin s'il reste valide parmi les nouveaux
  /// candidats (même motif que la réinitialisation du kit d'un enfant quand
  /// son niveau scolaire change).
  void _resyncAgent(List<Agent> agents) {
    if (widget.presetAgentName != null) return;
    if (_city == null) {
      _agent = null;
      return;
    }
    final candidates = matchingAgents(agents, _city!, _districtController.text);
    final stillValid = candidates.any((a) => a.fullName == _agent);
    if (!stillValid) {
      _agent = candidates.isEmpty ? null : candidates.first.fullName;
    }
  }

  Future<void> _submit(List<Agent> agents) async {
    final effectiveAgent = _effectiveAgent;
    final childrenInput = _children
        .map(
          (c) => (
            firstName: c.nameController.text.trim(),
            level: c.level?.label,
            school: c.schoolController.text.trim().isEmpty
                ? null
                : c.schoolController.text.trim(),
            kitId: c.kitId ?? '',
          ),
        )
        .toList();
    final childrenValid = childrenInput.every(
      (c) => c.firstName.isNotEmpty && c.kitId.isNotEmpty,
    );

    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _city == null ||
        !childrenValid) {
      showAppToast(
        context,
        'Renseignez tous les champs requis',
        type: AppToastType.error,
      );
      return;
    }

    await ref
        .read(enrollmentControllerProvider.notifier)
        .enroll(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          plan: _plan,
          children: childrenInput,
          assignedAgentName: effectiveAgent,
          city: _city!.label,
          district: _districtController.text.trim().isEmpty
              ? null
              : _districtController.text.trim(),
        );
    if (!mounted) return;

    final state = ref.read(enrollmentControllerProvider);
    if (state.hasError) {
      showAppToast(
        context,
        'Une erreur est survenue',
        type: AppToastType.error,
      );
      return;
    }
    final family = state.value;
    if (family != null) {
      context.push(widget.successRoutePath, extra: family);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kitsAsync = ref.watch(kitsListProvider);
    final agentsAsync = ref.watch(agentsListProvider);

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(
        title: 'Inscrire un client',
        onBack: () => context.pop(),
      ),
      body: kitsAsync.when(
        data: (kits) => agentsAsync.when(
          data: (agents) {
            // Cas Agent terrain : la ville se pré-remplit une seule fois sur
            // celle de l'agent courant (confort, pas une contrainte) — reste
            // éditable ensuite, jamais réappliquée après ce premier calcul.
            if (widget.presetAgentName != null && !_cityDefaultApplied) {
              _cityDefaultApplied = true;
              final presetAgent = agents.cast<Agent?>().firstWhere(
                (a) => a?.fullName == widget.presetAgentName,
                orElse: () => null,
              );
              if (presetAgent != null) {
                _city = burkinaCityFromLabel(presetAgent.zone);
              }
            }
            final candidateAgents = _city == null
                ? const <Agent>[]
                : matchingAgents(agents, _city!, _districtController.text);

            return _EnrollmentForm(
              kits: kits,
              city: _city,
              onCityChanged: (city) => setState(() {
                _city = city;
                _resyncAgent(agents);
              }),
              districtController: _districtController,
              onDistrictChanged: (_) => setState(() => _resyncAgent(agents)),
              plan: _plan,
              onPlanChanged: (plan) => setState(() => _plan = plan),
              children: _children,
              onChildKitChanged: (index, kitId) =>
                  setState(() => _children[index].kitId = kitId),
              // Le kit dépend de la classe (§3.6 du contrat) : changer de
              // niveau réinitialise le kit choisi vers le premier
              // correspondant à la nouvelle classe (ou aucun s'il n'y en a
              // pas), jamais un kit d'une autre classe laissé en place.
              onChildLevelChanged: (index, level) => setState(() {
                _children[index].level = level;
                final matching = kits.where((k) => k.schoolLevel == level);
                _children[index].kitId = matching.isEmpty
                    ? null
                    : matching.first.id;
              }),
              onAddChild: _addChild,
              onRemoveChild: _removeChild,
              showAgentField: widget.presetAgentName == null,
              candidateAgents: candidateAgents,
              agent: _agent,
              onAgentChanged: (agent) => setState(() => _agent = agent),
              nameController: _nameController,
              phoneController: _phoneController,
              submitting: ref.watch(enrollmentControllerProvider).isLoading,
              onSubmit: () => _submit(agents),
            );
          },
          loading: () => const LoadingScreen(),
          error: (error, stackTrace) =>
              ErrorScreen(onRetry: () => ref.invalidate(agentsListProvider)),
        ),
        loading: () => const LoadingScreen(),
        error: (error, stackTrace) =>
            ErrorScreen(onRetry: () => ref.invalidate(kitsListProvider)),
      ),
    );
  }
}

class _EnrollmentForm extends StatelessWidget {
  const _EnrollmentForm({
    required this.kits,
    required this.plan,
    required this.onPlanChanged,
    required this.children,
    required this.onChildKitChanged,
    required this.onChildLevelChanged,
    required this.onAddChild,
    required this.onRemoveChild,
    required this.showAgentField,
    required this.candidateAgents,
    required this.agent,
    required this.onAgentChanged,
    required this.city,
    required this.onCityChanged,
    required this.districtController,
    required this.onDistrictChanged,
    required this.nameController,
    required this.phoneController,
    required this.submitting,
    required this.onSubmit,
  });

  final List<Kit> kits;
  final SavingsPlan plan;
  final ValueChanged<SavingsPlan> onPlanChanged;

  final List<_ChildFormEntry> children;
  final void Function(int index, String kitId) onChildKitChanged;
  final void Function(int index, SchoolLevel? level) onChildLevelChanged;
  final VoidCallback onAddChild;
  final ValueChanged<int> onRemoveChild;

  /// `false` quand l'agent est imposé par la session (cas Agent terrain) —
  /// masque le menu déroulant.
  final bool showAgentField;

  /// Agents déjà filtrés/priorisés pour la ville et le quartier saisis
  /// (voir [matchingAgents]) — peut être vide, auquel cas seule l'option
  /// "Sans agent assigné" reste proposée.
  final List<Agent> candidateAgents;
  final String? agent;
  final ValueChanged<String?> onAgentChanged;

  /// Ville explicite et obligatoire — indépendante de l'agent.
  final BurkinaCity? city;
  final ValueChanged<BurkinaCity?> onCityChanged;
  final TextEditingController districtController;
  final ValueChanged<String> onDistrictChanged;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final bool submitting;
  final VoidCallback onSubmit;

  List<Kit> _kitsFor(SchoolLevel? level) => kitsForSchoolLevel(kits, level);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Nouvelle inscription', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Remplissez les informations du client',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Nom et prénom',
            controller: nameController,
            hintText: 'Ouedraogo Marie',
            enabled: !submitting,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Téléphone',
            controller: phoneController,
            hintText: '+226 70 45 67 89',
            keyboardType: TextInputType.phone,
            enabled: !submitting,
          ),
          const SizedBox(height: AppSpacing.md),
          AppDropdownField<SavingsPlan>(
            label: "Plan d'épargne",
            value: plan,
            items: SavingsPlan.values
                .map(
                  (plan) => DropdownMenuItem(
                    value: plan,
                    child: Text(plan.labelWithAmount),
                  ),
                )
                .toList(),
            onChanged: submitting ? null : (value) => onPlanChanged(value!),
          ),
          const SizedBox(height: AppSpacing.md),
          AppDropdownField<BurkinaCity?>(
            label: 'Ville',
            value: city,
            items: [
              const DropdownMenuItem(child: Text('Choisissez une ville')),
              ...BurkinaCity.values.map(
                (c) => DropdownMenuItem(value: c, child: Text(c.label)),
              ),
            ],
            onChanged: submitting ? null : onCityChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Quartier (optionnel)',
            controller: districtController,
            hintText: 'Secteur 15',
            enabled: !submitting,
            onChanged: onDistrictChanged,
          ),
          if (showAgentField) ...[
            const SizedBox(height: AppSpacing.md),
            AppDropdownField<String?>(
              label: 'Agent assigné (optionnel)',
              value: agent,
              items: [
                const DropdownMenuItem(child: Text('Sans agent assigné')),
                ...candidateAgents.map(
                  (a) => DropdownMenuItem(
                    value: a.fullName,
                    child: Text('${a.fullName} - ${a.zone}'),
                  ),
                ),
              ],
              onChanged: submitting ? null : onAgentChanged,
            ),
            if (city != null && candidateAgents.isEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Aucun agent dans cette ville — la famille sera enregistrée '
                'sans agent assigné.',
                style: AppTextStyles.bodySecondary,
              ),
            ],
          ],
          const SizedBox(height: AppSpacing.lg),
          const Text('ENFANTS', style: AppTextStyles.sectionLabel),
          const SizedBox(height: AppSpacing.sm),
          if (children.isEmpty)
            const Text(
              'Aucun enfant pour l\'instant — optionnel, peut être ajouté '
              'plus tard. Sans enfant, l\'objectif reste à 0.',
              style: AppTextStyles.bodySecondary,
            ),
          for (var i = 0; i < children.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Prénom de l\'enfant',
                    controller: children[i].nameController,
                    hintText: 'Fatoumata',
                    enabled: !submitting,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  onPressed: submitting ? null : () => onRemoveChild(i),
                  icon: const Icon(Icons.close, color: AppColors.danger),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            AppDropdownField<SchoolLevel?>(
              label: 'Niveau scolaire',
              value: children[i].level,
              items: [
                const DropdownMenuItem(child: Text('Choisissez le niveau')),
                ...SchoolLevel.values.map(
                  (level) =>
                      DropdownMenuItem(value: level, child: Text(level.label)),
                ),
              ],
              onChanged: submitting
                  ? null
                  : (value) => onChildLevelChanged(i, value),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: 'Nom de l\'école',
              controller: children[i].schoolController,
              hintText: 'École Centre - Koudougou',
              enabled: !submitting,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (children[i].level == null)
              const Text(
                'Choisissez d\'abord le niveau scolaire',
                style: AppTextStyles.bodySecondary,
              )
            else if (_kitsFor(children[i].level).isEmpty)
              const Text(
                'Aucun kit pour ce niveau — créez-en un dans le catalogue.',
                style: AppTextStyles.bodySecondary,
              )
            else
              _KitChoices(
                kits: _kitsFor(children[i].level),
                selectedKitId: children[i].kitId,
                enabled: !submitting,
                onSelected: (kitId) => onChildKitChanged(i, kitId),
              ),
            const SizedBox(height: AppSpacing.md),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: submitting ? null : onAddChild,
              icon: const Icon(Icons.add, color: AppColors.green),
              label: const Text(
                'Ajouter un enfant',
                style: TextStyle(color: AppColors.green),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Inscrire ce client',
            loading: submitting,
            onPressed: submitting ? null : onSubmit,
          ),
        ],
      ),
    );
  }
}

/// Même disposition que l'app Client : les trois formules sont des cartes
/// directement sélectionnables, au lieu d'être cachées dans une liste déroulante.
class _KitChoices extends StatelessWidget {
  const _KitChoices({
    required this.kits,
    required this.selectedKitId,
    required this.enabled,
    required this.onSelected,
  });

  final List<Kit> kits;
  final String? selectedKitId;
  final bool enabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('KIT D’ÉPARGNE', style: AppTextStyles.sectionLabel),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Choisissez la formule adaptée à cet enfant.',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final kit in kits)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _KitChoiceCard(
              kit: kit,
              selected: selectedKitId == null
                  ? kit == kits.first
                  : selectedKitId == kit.id,
              enabled: enabled,
              onTap: () => onSelected(kit.id),
            ),
          ),
      ],
    );
  }
}

class _KitChoiceCard extends StatelessWidget {
  const _KitChoiceCard({
    required this.kit,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final Kit kit;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? const Color(0x1A00C853) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.surfaceBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.shopping_basket_rounded,
              color: selected ? AppColors.green : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(kit.level.label, style: AppTextStyles.bodyStrong),
                  Text(
                    '${kit.items.length} fourniture(s) incluse(s)',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            Text(
              '${kit.price.toStringAsFixed(0)} FCFA',
              style: AppTextStyles.bodyStrong.copyWith(color: AppColors.green),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? AppColors.green : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
