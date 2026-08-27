# Design System

Le Design System du projet est centralisé dans `app/theme/`.

## Couleurs (AppColors)
Le fichier `app/theme/app_colors.dart` dicte la palette suivante, de style très moderne (Mode sombre prédominant) :
- `nightBlue` (`#0A1628`) : Couleur de fond principale (AppBar, backgrounds profonds).
- `brightGreen` (`#00C853`) : Couleur d'accentuation, utilisée pour le succès, les validations, les boutons d'action d'argent (Success/Money).
- `sunYellow` (`#FFD600`) : Accent secondaire, probablement utilisé pour des alertes ou des mises en avant.
- `surface` (`#0D1D34`) : Couleur des conteneurs, cartes (Surfaces de niveau 1).
- `surfaceSoft` (`#13253F`) : Couleur de fond légèrement plus claire pour différencier les éléments interactifs.
- `textMuted` (`#9AA5B4`) : Texte secondaire, sous-titres, texte non prioritaire.
- `danger` (`#E53935`) : Rouge pour les erreurs, la suppression (ex: supprimer un enfant).
- `page` (`#F0F4F8`) : Optionnel (probablement utilisé si un mode clair existait ou pour certains fonds spécifiques).

## Typographie
Les thèmes de texte sont générés par le `ThemeData` global (probablement via un Google Font, bien que non précisé).
- L'accent est mis sur les textes très lisibles.
- Hiérarchie : Titres gras pour les écrans, sous-titres en `textMuted`.

## Composants Partagés
- **ActionButton** : Bouton standard, large (généralement pleine largeur), avec gestion de son état de chargement.
- **AppCard** : Conteneur arrondi avec une ombre subtile ou une élévation spécifique pour regrouper les données (ex: Carte enfant, Carte cotisation).
- **EduPay Logo** : Élément de branding visuel.
- **ParentShell** : Structure d'écran avec AppBar pré-configurée (Titre, bouton retour automatique via GoRouter), et gestion d'une vue sécurisée.

## Animations & Espacements
Les espacements sont souvent gérés via des `SizedBox(height: 16)` standardisés, en gardant des marges (Padding) autour de `16.0` ou `24.0` pour les Layouts principaux. L'aspect arrondi des cartes et boutons est souvent géré avec des `BorderRadius.circular`.
