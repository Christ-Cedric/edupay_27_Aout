import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_role.dart';

part 'session.freezed.dart';
part 'session.g.dart';

/// Session authentifiée (admin ou agent). Persistée via
/// `SecureStorageService` pour survivre au redémarrage de l'app tant qu'elle
/// n'a pas expiré.
@freezed
sealed class Session with _$Session {
  const factory Session({
    required String userId,
    required String displayName,
    required String phone,
    required UserRole role,
    required String token,
  }) = _Session;

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);
}
