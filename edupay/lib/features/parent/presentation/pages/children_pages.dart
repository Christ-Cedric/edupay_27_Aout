import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/action_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/parent_models.dart';
import '../../domain/school_catalogue.dart';
import '../parent_scope.dart';
import 'page_scaffold.dart';
import '../../../../shared/widgets/progress_stepper.dart';

/// « Mes enfants » is the entry point for the whole subscription journey —
/// adding children here, then starting the plan/kits/contract flow. See
/// ai_context/BUSINESS_RULES.md « Espace "Mes enfants" ».
class ChildrenPage extends StatelessWidget {
  const ChildrenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;

    return ParentPageScaffold(
      children: [
        const ProgressStepper(currentStep: 2, totalSteps: 5),
        const PageTitle(
          'Vos enfants',
          subtitle: 'Ajoutez les enfants à inscrire pour la rentrée.',
        ),
        if (state.children.isEmpty)
          AppCard(
            child: Column(
              children: [
                Icon(Icons.child_care, color: palette.onSurface(.55), size: 42),
                const SizedBox(height: 8),
                const Text(
                  'Aucun enfant ajouté',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ajoutez au moins un enfant pour continuer.',
                  style: TextStyle(color: palette.onSurface(.55)),
                ),
              ],
            ),
          )
        else
          ...List.generate(
            state.children.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ChildCard(
                child: state.children[index],
                // Suppression possible tant que l'enfant n'a reçu aucune part
                // de cotisation ; sinon il est verrouillé (cadenas).
                onRemove: state.canRemoveChild(index)
                    ? () => state.removeChild(index)
                    : null,
              ),
            ),
          ),
        const SizedBox(height: 10),
        ActionButton(
          label: 'Ajouter un enfant',
          icon: Icons.add,
          secondary: true,
          onPressed: () => context.push('/app/children/add'),
        ),
        const SizedBox(height: 10),
        ActionButton(
          label: state.allChildrenHaveKit
              ? 'Modifier ma souscription'
              : 'Démarrer la souscription',
          onPressed: state.children.isEmpty
              ? null
              : () => context.push('/app/children/kits'),
        ),
      ],
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.child, this.onRemove});
  final ChildProfile child;

  /// `null` quand l'enfant est inscrit (contrat signé) : le bouton de
  /// suppression est alors masqué.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: palette.accentGreen,
            foregroundColor: Colors.white,
            child: Text(child.firstName.substring(0, 1).toUpperCase()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.firstName,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  '${child.level} - ${child.school}',
                  style: TextStyle(color: palette.onSurface(.55)),
                ),
                const SizedBox(height: 4),
                Text(
                  child.kitSelection?.title ?? 'Kit à choisir',
                  style: TextStyle(
                    color: child.kitSelection == null
                        ? palette.accentYellow
                        : palette.accentGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: Icon(Icons.close, color: palette.danger),
            )
          else
            Icon(Icons.lock_outline, color: palette.onSurface(.35), size: 20),
        ],
      ),
    );
  }
}

class AddChildPage extends StatelessWidget {
  const AddChildPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);

    return ParentPageScaffold(
      children: [
        const PageTitle(
          'Ajouter un enfant',
          subtitle: 'Renseignez les informations scolaires.',
        ),
        TextField(
          controller: state.childNameController,
          decoration: const InputDecoration(labelText: 'Nom Complet'),
        ),
        const SizedBox(height: 12),
        _ClassAutocompleteField(controller: state.childLevelController),
        const SizedBox(height: 12),
        TextField(
          controller: state.childSchoolController,
          decoration: const InputDecoration(labelText: 'École'),
        ),
        const SizedBox(height: 28),
        ActionButton(
          label: 'Ajouter cet enfant',
          icon: Icons.check,
          onPressed: () async {
            final router = GoRouter.of(context);
            final messenger = ScaffoldMessenger.of(context);
            final added = await state.addChild();
            if (!added) {
              final error = state.childState.error;
              final message = error is ArgumentError
                  ? (error.message as String)
                  : 'Renseignez le prénom, le niveau et l’école de l’enfant.';
              messenger.showSnackBar(SnackBar(content: Text(message)));
              return;
            }
            // Retour vers « Mes enfants ». Navigation DÉCLARATIVE (`go`) et non
            // `pop` : robuste quel que soit l'état de la pile, et surtout à
            // l'abri de la course avec le `refreshListenable` de go_router que
            // déclenche `notifyListeners()` dans `addChild()` (un `pop`
            // impératif peut être annulé par la réévaluation du `redirect`).
            router.go('/app/children');
          },
        ),
      ],
    );
  }
}

/// Champ « Classe » en autocomplétion : les suggestions viennent EXCLUSIVEMENT
/// du catalogue officiel ([SchoolCatalogue.classes], sourcé du fichier Excel).
/// Aucune valeur hors de cette liste ne doit être enregistrable — la
/// validation stricte est faite dans `ParentAppState.addChild` (bloque si
/// `!SchoolCatalogue.isValidClass(level)`), ce champ ne fait qu'aider la
/// saisie exacte.
class _ClassAutocompleteField extends StatefulWidget {
  const _ClassAutocompleteField({required this.controller});

  final TextEditingController controller;

  @override
  State<_ClassAutocompleteField> createState() =>
      _ClassAutocompleteFieldState();
}

class _ClassAutocompleteFieldState extends State<_ClassAutocompleteField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      optionsBuilder: (value) {
        if (value.text.isEmpty) return SchoolCatalogue.classes;
        final query = value.text.toLowerCase();
        return SchoolCatalogue.classes.where(
          (classLabel) => classLabel.toLowerCase().contains(query),
        );
      },
      onSelected: (selection) => widget.controller.text = selection,
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        return TextField(
          controller: textController,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Classe',
            hintText: 'Ex. CM2, 6ème, Terminale D…',
            suffixIcon: Icon(Icons.expand_more),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260, minWidth: 280),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(option),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
