/// Mode de collecte d'une cotisation sur le terrain (motif `ag_en` du
/// prototype).
enum CollectionMode { cash, orangeMoney, moovMoney }

extension CollectionModeLabel on CollectionMode {
  String get label => switch (this) {
    CollectionMode.cash => 'Espèces en main',
    CollectionMode.orangeMoney => 'Orange Money reçu',
    CollectionMode.moovMoney => 'Moov Money reçu',
  };
}
