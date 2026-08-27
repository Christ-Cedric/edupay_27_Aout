/// Plan d'épargne d'une famille (motif `plan` du prototype).
enum SavingsPlan { daily, weekly, monthly }

extension SavingsPlanLabel on SavingsPlan {
  String get label => switch (this) {
    SavingsPlan.daily => 'Journalier',
    SavingsPlan.weekly => 'Hebdomadaire',
    SavingsPlan.monthly => 'Mensuel',
  };

  /// Montant de la cotisation périodique, en FCFA.
  int get amount => switch (this) {
    SavingsPlan.daily => 300,
    SavingsPlan.weekly => 2000,
    SavingsPlan.monthly => 8500,
  };

  String get labelWithAmount => switch (this) {
    SavingsPlan.daily => '$label - $amount FCFA/jour',
    SavingsPlan.weekly => '$label - $amount FCFA/sem.',
    SavingsPlan.monthly => '$label - $amount FCFA/mois',
  };
}
