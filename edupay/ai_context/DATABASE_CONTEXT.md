# Database Context (Modèles de Données)

Ce projet ne comporte pas (à ce stade) de base de données locale complexe de type SQLite/Room, mais modélise fortement les données échangées avec le serveur via les fichiers `domain/parent_models.dart`.

## Modèles Principaux
- **ParentProfile** : Identité du parent (Nom complet, Téléphone, Ville, Quartier).
- **ChildProfile** : Identité de l'enfant (Prénom, Niveau, École) et informations sur son financement (Kit sélectionné, Montant déjà épargné `savedAmount`).
- **Contribution** : Historique des paiements (Date, Méthode, Référence de transaction, Montant, Statut de succès).

## Énumérations (Enums & Configurations)
- **SavingsPlan** : Plan de cotisation (daily=300XOF, weekly=2000XOF, monthly=8500XOF).
- **SchoolKit** : Kits standards (basic=12000XOF, comfort=18500XOF, complete=27000XOF) avec définition de contenu (ex: 5 cahiers, stylos...).
- **CustomKitItem** : Articles à l'unité pour constitution de kit personnalisé (cahiers, sac, calculatrice, etc.).
- **PaymentMethod** : (Orange Money, Moov Money, Cash Agent).

## Sérialisation (JSON)
Chaque modèle dispose des méthodes `fromJson` et `toJson` pour faciliter la communication avec le backend. On note que les noms de clés JSON respectent le `snake_case` (ex: `first_name`, `saved_amount`) alors que Dart utilise le `camelCase`.

## Flux de données
1. **Lecture** : Le serveur renvoie un objet JSON -> `ParentApiService` -> `RestParentRepository` convertit le JSON via `.fromJson()` -> `ParentUseCases` consolide les modèles -> `ParentAppState` met à jour la vue.
2. **Écriture** : L'utilisateur modifie l'UI -> `ParentAppState` appelle `UseCases` avec des entités -> `RestParentRepository` convertit l'entité via `.toJson()` -> `ParentApiService` effectue la requête POST/PUT.
