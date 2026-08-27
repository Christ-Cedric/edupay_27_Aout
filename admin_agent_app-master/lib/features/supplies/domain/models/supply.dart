import 'package:freezed_annotation/freezed_annotation.dart';

part 'supply.freezed.dart';

/// Une fourniture du catalogue réutilisable — l'admin la gère une fois puis
/// pioche dedans pour composer un kit (`KitItem` en copie les valeurs au
/// moment de l'ajout, reste éditable indépendamment ensuite).
@freezed
sealed class Supply with _$Supply {
  const factory Supply({
    required String id,
    required String category,
    required String label,
    required String unit,
    required double unitPrice,
  }) = _Supply;
}
