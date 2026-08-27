import 'dart:convert';

import 'parent_models.dart';

/// Un article priced tel que décrit dans le fichier Excel officiel (catégorie,
/// libellé, quantité, prix unitaire) — aucune de ces valeurs n'est retapée à la
/// main dans le code : elles viennent toutes de `school_catalogue.json`
/// (généré depuis le fichier source par `tools/generate_catalogue.py`).
class CatalogueArticle {
  const CatalogueArticle({
    required this.id,
    required this.category,
    required this.label,
    required this.quantity,
    required this.unitPrice,
  });

  /// Identifiant stable au sein d'une classe (dérivé de catégorie+libellé par
  /// le script de génération) — sert de clé pour le kit personnalisé.
  final String id;
  final String category;
  final String label;
  final int quantity;
  final int unitPrice;

  int get subtotal => quantity * unitPrice;

  CatalogueArticle copyWith({int? quantity}) => CatalogueArticle(
    id: id,
    category: category,
    label: label,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice,
  );
}

/// Kit résolu pour un enfant donné : titre affichable, prix total et détail
/// des articles, calculés à partir du catalogue pour SA classe précise.
class ResolvedKit {
  const ResolvedKit({
    required this.title,
    required this.price,
    required this.lineItems,
  });

  final String title;
  final int price;
  final List<CatalogueArticle> lineItems;
}

class _ClassCatalogue {
  _ClassCatalogue({
    required this.cycle,
    required this.kits,
    required this.articles,
  });

  final String cycle;
  final Map<SchoolKit, List<CatalogueArticle>> kits;

  /// Union (dédupliquée par id) des articles de la classe, toutes catégories
  /// confondues — utilisée pour la personnalisation « à la carte ».
  final List<CatalogueArticle> articles;

  CatalogueArticle? articleById(String id) {
    for (final article in articles) {
      if (article.id == id) return article;
    }
    return null;
  }
}

/// Source de données officielle des classes, fournitures et prix — reflet
/// exact du fichier Excel `EduPay_Catalogue_Fournitures_3Kits`. Aucune autre
/// donnée de classe/fourniture ne doit être introduite ailleurs dans le code :
/// tout passe par ce catalogue.
///
/// Volontairement 100% Dart pur (pas de dépendance Flutter) : le chargement
/// (lecture de l'asset via `rootBundle`) est fait par l'appelant (voir
/// `main.dart`), qui transmet simplement la chaîne JSON à [loadFromJson]. Ceci
/// permet de réutiliser/tester ce fichier hors du framework Flutter, et de
/// charger un catalogue de test dans les tests unitaires.
class SchoolCatalogue {
  SchoolCatalogue._();

  static Map<String, _ClassCatalogue> _byClass = {};

  /// Libellés de classe exacts du fichier, dans l'ordre du fichier source.
  static List<String> classes = const [];

  static bool get isLoaded => _byClass.isNotEmpty;

  /// Charge (ou remplace) le catalogue à partir du JSON généré par
  /// `tools/generate_catalogue.py`. Idempotent : un rechargement remplace
  /// entièrement l'état précédent (utile pour les tests).
  static void loadFromJson(String source) {
    final decoded = jsonDecode(source) as Map<String, dynamic>;
    final classesJson = (decoded['classes'] as List<dynamic>? ?? const [])
        .map((e) => e as String)
        .toList();
    final levelsJson = decoded['levels'] as Map<String, dynamic>? ?? const {};

    final byClass = <String, _ClassCatalogue>{};
    for (final entry in levelsJson.entries) {
      final levelJson = entry.value as Map<String, dynamic>;
      final kitsJson = levelJson['kits'] as Map<String, dynamic>? ?? const {};
      final kits = <SchoolKit, List<CatalogueArticle>>{};
      for (final kitEntry in kitsJson.entries) {
        final tier = _tierFromCode(kitEntry.key);
        if (tier == null) continue;
        final kitJson = kitEntry.value as Map<String, dynamic>;
        final items = (kitJson['items'] as List<dynamic>? ?? const [])
            .map((item) => _articleFromJson(item as Map<String, dynamic>))
            .toList();
        kits[tier] = items;
      }
      final articles = (levelJson['articles'] as List<dynamic>? ?? const [])
          .map((item) => _articleFromJson(item as Map<String, dynamic>))
          .toList();
      byClass[entry.key] = _ClassCatalogue(
        cycle: levelJson['cycle'] as String? ?? '',
        kits: kits,
        articles: articles,
      );
    }

    _byClass = byClass;
    classes = classesJson;
  }

  /// Réinitialise le catalogue (tests uniquement).
  static void reset() {
    _byClass = {};
    classes = const [];
  }

  static SchoolKit? _tierFromCode(String code) => switch (code) {
    'basic' => SchoolKit.basic,
    'comfort' => SchoolKit.comfort,
    'complete' => SchoolKit.complete,
    _ => null,
  };

  /// `level` (DTO backend `GET /catalog/kits`) utilise une nomenclature
  /// différente des clés internes du JSON (voir `kits.serializer.ts::levelToTier`
  /// côté backend — même mapping, dupliqué ici faute de types partagés).
  static SchoolKit? _tierFromLevel(String level) => switch (level) {
    'basic' => SchoolKit.basic,
    'intermediate' => SchoolKit.comfort,
    'premium' => SchoolKit.complete,
    _ => null,
  };

  /// Remplace, pour [classLabel], le prix/contenu des kits standards par la
  /// réponse réelle de `GET /catalog/kits?level_scope=<classLabel>` — le
  /// backend (géré par l'Admin) devient la source de vérité du prix
  /// réellement enregistré (`savingsGoal.targetAmount`), au lieu du JSON
  /// statique embarqué au build. Les `articles` (kit personnalisé « à la
  /// carte ») restent ceux du JSON — hors périmètre de cette synchronisation.
  /// Sans effet si [classLabel] est inconnue du catalogue local (ne devrait
  /// pas arriver : les deux sources listent les mêmes classes).
  static void applyBackendKits(String classLabel, List<dynamic> kitDtos) {
    final existing = _byClass[classLabel];
    if (existing == null) return;

    final kits = Map<SchoolKit, List<CatalogueArticle>>.from(existing.kits);
    for (final dto in kitDtos) {
      final kitJson = dto as Map<String, dynamic>;
      final tier = _tierFromLevel(kitJson['level'] as String? ?? '');
      if (tier == null) continue;
      final items = (kitJson['items'] as List<dynamic>? ?? const [])
          .map((item) => _backendItemToArticle(item as Map<String, dynamic>))
          .toList();
      kits[tier] = items;
    }

    _byClass[classLabel] = _ClassCatalogue(
      cycle: existing.cycle,
      kits: kits,
      articles: existing.articles,
    );
  }

  static CatalogueArticle _backendItemToArticle(Map<String, dynamic> json) =>
      CatalogueArticle(
        id: '${json['category']}_${json['label']}',
        category: json['category'] as String? ?? '',
        label: json['label'] as String? ?? '',
        quantity: (json['quantity'] as num? ?? 0).toInt(),
        unitPrice: (json['unit_price'] as num? ?? 0).toInt(),
      );

  static CatalogueArticle _articleFromJson(Map<String, dynamic> json) =>
      CatalogueArticle(
        id: json['id'] as String? ?? '',
        category: json['category'] as String? ?? '',
        label: json['label'] as String? ?? '',
        quantity: (json['quantity'] as num? ?? 0).toInt(),
        unitPrice: (json['unitPrice'] as num? ?? 0).toInt(),
      );

  /// Vrai si [label] correspond exactement (casse incluse) à une classe du
  /// fichier officiel. Utilisé pour bloquer l'enregistrement d'une classe
  /// invalide lors de l'ajout/modification d'un enfant.
  static bool isValidClass(String label) => _byClass.containsKey(label);

  /// Tous les articles connus pour [classLabel] (toutes catégories confondues,
  /// dédupliqués), pour l'écran de personnalisation « à la carte ». Liste vide
  /// si la classe est inconnue.
  static List<CatalogueArticle> articlesFor(String classLabel) =>
      _byClass[classLabel]?.articles ?? const [];

  /// Résout le prix et le détail d'une sélection de kit pour la classe donnée.
  /// Renvoie `null` si la classe est inconnue du catalogue.
  static ResolvedKit? resolve(String classLabel, ChildKitSelection selection) {
    final classCatalogue = _byClass[classLabel];
    if (classCatalogue == null) return null;

    switch (selection.type) {
      case KitSelectionType.standard:
        final tier = selection.standardKit!;
        final items = classCatalogue.kits[tier] ?? const [];
        final price = items.fold<int>(
          0,
          (total, item) => total + item.subtotal,
        );
        return ResolvedKit(title: tier.title, price: price, lineItems: items);
      case KitSelectionType.custom:
        final items = <CatalogueArticle>[];
        var price = 0;
        for (final entry in selection.customItemIds.entries) {
          final article = classCatalogue.articleById(entry.key);
          if (article == null) continue;
          final resolved = article.copyWith(quantity: entry.value);
          items.add(resolved);
          price += resolved.subtotal;
        }
        return ResolvedKit(
          title: 'Kit personnalisé',
          price: price,
          lineItems: items,
        );
    }
  }
}

/// Résolution du kit et du coût total d'un enfant à partir de SA classe précise — c'est le
/// point d'entrée à utiliser partout dans l'app (jamais de prix/contenu de
/// kit sans passer par le catalogue officiel).
extension ChildKitResolution on ChildProfile {
  ResolvedKit? get resolvedKit {
    final selection = kitSelection;
    if (selection == null) return null;
    return SchoolCatalogue.resolve(level, selection);
  }

  /// Coût des fournitures scolaires.
  int get suppliesCost {
    final resolved = resolvedKit?.price ?? 0;
    if (resolved > 0) return resolved;
    if (targetAmount != null && targetAmount! > 0) return targetAmount!;
    return 0;
  }

  /// Coût total de tous les objectifs confondus pour cet enfant
  /// (Fournitures + Scolarité + Moyen de déplacement).
  int get totalCost => suppliesCost + tuitionAmount + transportAmount;

  /// Vrai si l'enfant a au moins un objectif défini (fournitures, scolarité ou transport).
  bool get hasAnyGoal => totalCost > 0;
}
