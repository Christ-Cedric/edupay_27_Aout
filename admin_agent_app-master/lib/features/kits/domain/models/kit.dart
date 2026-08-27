import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/domain/school_level.dart';

part 'kit.freezed.dart';

enum KitLevel { basic, intermediate, premium }

extension KitLevelLabel on KitLevel {
  String get label => switch (this) {
    KitLevel.basic => 'Kit Basique',
    KitLevel.intermediate => 'Kit Essentiel',
    KitLevel.premium => 'Kit Premium',
  };
}

/// Une fourniture d'un kit — catégorie libre (le vrai catalogue fournisseur
/// a une quinzaine de catégories différentes selon le cycle, pas un petit
/// enum fermé), quantité, unité et prix unitaire. Le prix total du kit
/// (`Kit.price`) est toujours la somme de `quantity × unitPrice` sur ses
/// fournitures — jamais un nombre saisi indépendamment.
@freezed
sealed class KitItem with _$KitItem {
  const factory KitItem({
    required String category,
    required String label,
    required int quantity,
    required String unit,
    required double unitPrice,
  }) = _KitItem;
}

extension KitItemTotal on KitItem {
  double get lineTotal => quantity * unitPrice;
}

/// Un kit de fournitures scolaires (motif `ad_ki`/`ad_ek` du prototype).
///
/// `level` est le **variant** selon le budget de la famille (Basique/
/// Essentiel/Premium) ; `schoolLevel` est la **classe ciblée** (ex.
/// CM2) — deux dimensions distinctes (contrat §3.6). Un même `schoolLevel`
/// peut avoir plusieurs kits, un par variant. `price` est calculé côté
/// serveur à partir des `items` (jamais saisi directement) — source de
/// vérité unique, cohérente avec le catalogue fournisseur d'origine.
@freezed
sealed class Kit with _$Kit {
  const factory Kit({
    required String id,
    required KitLevel level,
    required SchoolLevel schoolLevel,
    required double price,
    required List<KitItem> items,
  }) = _Kit;
}

extension KitDisplayLabel on Kit {
  /// Libellé complet classe + variant (ex. "CM2 - Kit Basique"), utilisé
  /// partout où un kit est affiché hors du catalogue lui-même (l'enfant
  /// concerné ou la classe ne sont pas toujours évidents sans ça).
  String get fullLabel => '${schoolLevel.label} - ${level.label}';
}

/// Kits ciblant ce niveau scolaire — un kit est lié à une classe précise
/// (§3.6 du contrat), pas au foyer entier. Partagé entre l'inscription
/// initiale et le choix/changement de kit d'un enfant existant, pour ne pas
/// dupliquer cette règle de filtrage à chaque écran.
List<Kit> kitsForSchoolLevel(List<Kit> kits, SchoolLevel? level) =>
    kits.where((k) => k.schoolLevel == level).toList();

/// Total calculé à partir d'une liste de fournitures — utilisé par les
/// formulaires création/édition de kit pour afficher un total qui se met à
/// jour en direct pendant la saisie, avant tout aller-retour serveur.
double computeItemsTotal(List<KitItem> items) =>
    items.fold(0, (sum, item) => sum + item.lineTotal);

/// Résumé retourné par l'import d'un catalogue Excel — jamais de suppression
/// de kit, toujours un upsert par (classe, variant) pour la saison courante.
class KitImportResult {
  const KitImportResult({
    required this.created,
    required this.updated,
    required this.warnings,
  });

  final int created;
  final int updated;
  final List<String> warnings;
}
