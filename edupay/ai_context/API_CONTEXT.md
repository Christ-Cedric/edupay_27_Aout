# Contexte API

Les routes API de l'application sont centralisées dans `features/parent/data/services/parent_api_service.dart` ou `api_routes.dart` selon l'implémentation complète. À ce stade, les services mockés utilisent des objets statiques, mais la structure d'API déduite par les modèles et les requêtes est la suivante :

## Endpoints (Hypothétiques & Déduits des `UseCases`)

### 1. Authentification
- `POST /api/auth/request-otp` : Demande d'un OTP pour un numéro de téléphone donné.
- `POST /api/auth/verify-otp` : Vérification du code OTP. (Retourne probablement un JWT / token).

### 2. Profil Parent
- `GET /api/parents/profile` : Récupère les données du parent (nom, ville, quartier).
- `PUT /api/parents/profile` : Met à jour les informations du parent.
  - Payload : `{"full_name": "...", "phone": "...", "city": "...", "district": "..."}`

### 3. Gestion des Enfants (Children)
- `GET /api/parents/children` : Récupère la liste des enfants associés au parent.
- `POST /api/parents/children` : Ajoute un nouvel enfant.
  - Payload : `{"first_name": "...", "level": "...", "school": "...", "kit": "comfort", "saved_amount": 0}`
- `DELETE /api/parents/children/{id}` : Supprime un enfant de la liste.

### 4. Cotisations & Paiements
- `GET /api/parents/contributions` : Récupère l'historique des paiements.
- `POST /api/payments/contribute` : Initie un paiement Mobile Money.
  - La réponse attendue confirmerait le succès de la transaction et créerait un historique. L'API d'order de kits standardisés s'insère ici ou dans un endpoint distinct.
  - Payload d'order des kits : `{"standard_kits": [...], "custom_items": [...], "total_amount": X, "currency": "XOF"}`

## Note Importante
Toutes ces requêtes (sauf auth) nécessiteraient d'embarquer un header `Authorization: Bearer <token>` dans le client HTTP de la couche Data. L'architecture `ParentApiService` s'en chargera.
