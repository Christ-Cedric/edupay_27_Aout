// =============================================================================
// CORE/PROVIDERS/AUTH_PROVIDER.DART — Gestion de l'authentification
// =============================================================================
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/fcm_service.dart';
import '../storage/token_storage.dart';
import '../models/agent_model.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  AgentModel? _agent;
  String? _errorMessage;
  bool _isLoading = false;

  AuthStatus get status => _status;
  AgentModel? get agent => _agent;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // Vérifier si l'utilisateur est déjà connecté au démarrage
  Future<void> checkAuthStatus() async {
    final hasToken = await TokenStorage.hasValidToken();
    if (hasToken) {
      try {
        await _loadProfile();
        _status = AuthStatus.authenticated;
        unawaited(FcmService.registerCurrentDevice());
      } catch (_) {
        await TokenStorage.clearAll();
        _status = AuthStatus.unauthenticated;
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // Connexion avec numéro de téléphone + PIN
  Future<bool> loginWithPin({
    required String phone,
    required String pin,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.post(
        '/auth/login',
        {'phone': phone, 'password': pin},
        auth: false,
      );

      final data = response.containsKey('data') ? response['data'] : response;

      // Le backend retourne les tokens directement (pas de wrapper 'data')
      await TokenStorage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );

      await _loadProfile();
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      unawaited(FcmService.registerCurrentDevice());
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Erreur: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _loadProfile() async {
    // Le backend retourne les objets directement (pas de wrapper 'data')
    final userResponse = await ApiClient.get('/auth/me');
    final userData = userResponse.containsKey('data') ? userResponse['data'] : userResponse;

    // Cette app est réservée aux comptes agent — un compte admin/client qui
    // se connecterait ici échouerait de toute façon sur `/agent/me` (aucun
    // enregistrement Agent associé), mais avec un message générique. Ce
    // filet donne un message clair avant même cet appel superflu.
    if (userData['role'] != 'agent') {
      throw ApiException(
        403,
        'Ce compte n\'est pas un compte agent — utilisez l\'application dédiée à votre rôle.',
      );
    }

    final agentResponse = await ApiClient.get('/agent/me');
    final agentData = agentResponse.containsKey('data') ? agentResponse['data'] : agentResponse;

    // Fusionner user + agent
    final merged = <String, dynamic>{
      ...agentData,
      'user': userData,
    };

    _agent = AgentModel.fromJson(merged);
    await TokenStorage.saveUser(jsonEncode(merged));
  }

  // Déconnexion
  Future<void> logout(BuildContext context) async {
    // Avant de révoquer la session : le retrait nécessite encore un token
    // valide pour s'authentifier auprès de `/notifications/device-token`.
    await FcmService.unregisterCurrentDevice();
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken != null) {
        await ApiClient.post(
          '/auth/logout',
          {'refresh_token': refreshToken},
          auth: false,
        );
      }
    } catch (_) {
      // Ignorer si le logout backend échoue
    } finally {
      await TokenStorage.clearAll();
      _agent = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }
}
