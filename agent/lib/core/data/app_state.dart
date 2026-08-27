
class AppState {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  // Liste globale des clients
  final List<Map<String, dynamic>> clients = [
    {
      'initials': 'AK',
      'name': 'Aminata Kabore',
      'phone': '+226 76 12 34 56',
      'address': 'Secteur 3, Koudougou',
      'plan': 'Hebdomadaire',
      'saved': '24 700 FCFA',
      'goal': '39 800 FCFA',
      'progress': 0.62,
      'info': 'Hebdo — 24 700F / 39 800F',
      'status': 'Actif',
      'type': 'green',
    },
    {
      'initials': 'SW',
      'name': 'Sawadogo Wendyam',
      'phone': '+226 70 99 88 77',
      'address': 'Secteur 5, Koudougou',
      'plan': 'Journalier',
      'saved': '8 100 FCFA',
      'goal': '18 000 FCFA',
      'progress': 0.45,
      'info': 'Journalier — 8 100F / 18 000F',
      'status': 'Actif',
      'type': 'green',
    },
    {
      'initials': 'CY',
      'name': 'Cedric YAMEOGO',
      'phone': '+226 54 51 59 07',
      'address': 'Secteur 7, Koudougou',
      'plan': 'Hebdomadaire',
      'saved': '4 000 FCFA',
      'goal': '20 000 FCFA',
      'progress': 0.2,
      'info': 'Hebdo — en retard 2 sem.',
      'status': '⚠',
      'type': 'red',
    },
    {
      'initials': 'KF',
      'name': 'Kabore Fatoumata',
      'phone': '+226 71 22 33 44',
      'address': 'Secteur 1, Koudougou',
      'plan': 'Mensuel',
      'saved': '50 000 FCFA',
      'goal': '50 000 FCFA',
      'progress': 1.0,
      'info': 'Mensuel — 100%',
      'status': 'Complet',
      'type': 'green',
    },
  ];

  // Transactions fictives pour l'historique
  final List<Map<String, dynamic>> history = [
    {'date': 'Aujourd\'hui', 'amount': '+ 2 000 FCFA', 'type': 'Encaissement'},
    {'date': 'Hier', 'amount': '+ 2 000 FCFA', 'type': 'Encaissement'},
    {'date': 'Il y a 3 jours', 'amount': '- 1 500 FCFA', 'type': 'Frais'},
  ];
}
