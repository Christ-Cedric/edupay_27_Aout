# Dépendances (Dependencies)

Analyse basée sur le `pubspec.yaml`.

## Dépendances Principales
- **flutter** : Le framework UI cross-platform.
- **go_router: ^17.3.0** : Solution de routage officielle maintenue par l'équipe Flutter. Essentielle pour la navigation imbriquée (`StatefulShellRoute`), la gestion des redirections, et le deep linking.
- **cupertino_icons: ^1.0.8** : Jeu d'icônes style iOS. Le framework s'appuie également sur `uses-material-design: true` pour le set d'icônes Material (`Icons.*`).

## Gestion d'état
Bien que `provider` ne soit pas explicitement listé dans le petit extrait du `pubspec.yaml` vu, l'utilisation de `ChangeNotifier` et de concepts de "Provider/Scope" dans les dossiers laisse entendre une injection de dépendance (soit via le package `provider`, soit via une version héritée de `InheritedWidget` dans le code, comme `parent_scope.dart`). 

## Dépendances de Développement
- **flutter_test** : Outils pour les tests unitaires et widgets.
- **flutter_lints: ^6.0.0** : Règles officielles strictes pour la qualité du code Dart. À respecter (`analysis_options.yaml`).

## Contraintes d'environnement
- **Dart SDK** : `^3.12.2`. Cela implique l'utilisation systématique de fonctionnalités modernes de Dart (Pattern matching via `switch (this)`, sealed classes, records, non-nullable by default - null safety).
