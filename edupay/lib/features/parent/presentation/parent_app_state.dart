import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/network/api_exception.dart';
import '../../../app/services/fcm_service.dart';
import '../domain/auth_session.dart';
import '../domain/parent_models.dart';
import '../domain/parent_repository.dart';
import '../domain/parent_use_cases.dart';
import '../domain/quota_engine.dart';
import '../domain/school_catalogue.dart';

/// `restoring` : session en cours de rechargement au démarrage (aucun écran
/// d'auth affiché tant que l'état n'est pas tranché, pour éviter un flash de
/// l'écran de connexion chez un utilisateur déjà connecté).
/// `pendingApproval` : compte créé et connecté, mais en attente de
/// validation admin (`User.status == pendingValidation` côté backend) — ni
/// l'écran de connexion, ni la home, un écran d'attente dédié.
enum AuthStatus {
  restoring,
  unauthenticated,
  onboarding,
  pendingApproval,
  authenticated,
}

enum AuthFlow { signIn, signUp, forgotPassword }

enum RequestStatus { idle, loading, success, error }

/// Langue de l'interface (français par défaut ; l'anglais arrivera avec l'i18n).
enum AppLanguage { french, english }

/// Catégories de notifications activables individuellement par le parent.
enum AppNotification {
  savingReminder,
  paymentConfirmed,
  delivery,
  newKits,
  promotions,
  paymentOverdue,
}

/// Immutable state exposed by asynchronous presentation actions.
class RequestState<T> {
  const RequestState._({required this.status, this.data, this.error});

  const RequestState.idle() : this._(status: RequestStatus.idle);
  const RequestState.loading({T? data})
    : this._(status: RequestStatus.loading, data: data);
  const RequestState.success(T data)
    : this._(status: RequestStatus.success, data: data);
  const RequestState.error(Object error, {T? data})
    : this._(status: RequestStatus.error, data: data, error: error);

  final RequestStatus status;
  final T? data;
  final Object? error;
  bool get isLoading => status == RequestStatus.loading;
}

/// Presentation view-model. It owns form controllers and delegates all rules
/// and persistence to [ParentUseCases].
class ParentAppState extends ChangeNotifier {
  ParentAppState(
    this.repository, {
    required AuthSession authSession,
    FcmService? fcmService,
  }) : _useCases = ParentUseCases(repository),
       _auth = authSession,
       _fcm = fcmService {
    _auth.setSessionExpiredListener(_handleSessionExpired);
    _bootstrap();
  }

  final ParentRepository repository;
  final ParentUseCases _useCases;
  final AuthSession _auth;
  final FcmService? _fcm;

  AuthStatus authStatus = AuthStatus.restoring;

  /// Recharge une session persistée au lancement de l'app : tant qu'un
  /// utilisateur ne s'est pas déconnecté explicitement, il retrouve son
  /// compte sans repasser par l'écran de connexion.
  Future<void> _bootstrap() async {
    final hasSession = await _auth.restoreSession();
    authStatus = hasSession
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    notifyListeners();
    if (hasSession) unawaited(_fcm?.registerCurrentDevice());
  }

  /// Refresh token rejeté par le backend (expiré/révoqué) : on ramène
  /// l'utilisateur à l'écran de connexion et on purge les données de session,
  /// comme pour une déconnexion volontaire.
  void _handleSessionExpired() {
    authStatus = AuthStatus.unauthenticated;
    profile = null;
    children = [];
    contributions = [];
    homeLoaded = false;
    deliveryLoaded = false;
    notifyListeners();
  }

  ParentProfile? profile;
  List<ChildProfile> children = [];
  List<Contribution> contributions = [];
  List<TransportVehicle> availableVehicles = [];
  AppSeason? currentSeason;
  SavingsPlan plan = SavingsPlan.weekly;
  PaymentMethod paymentMethod = PaymentMethod.orangeMoney;
  AuthFlow authFlow = AuthFlow.signUp;

  /// `true` une fois que le parent a coché la case d'acceptation du contrat
  /// (case à cocher simple — pas de tracé manuscrit, en attendant le vrai
  /// contrat détaillé prévu ultérieurement).
  bool signed = false;

  /// Système de quotas figés (règle métier 2026-07-24) : `null` tant que la
  /// souscription n'a pas été confirmée. Une fois figé, `quotaValue` ne change
  /// plus jusqu'à la fin de la campagne (voir quota_engine.dart). Ne remplace
  /// PAS la logique de barre de progression/verrou 75 %/réinitialisation, qui
  /// reste entièrement inchangée (elle lit toujours `savedAmount`).
  QuotaState? quotaState;

  /// Mode d'affichage (Dark par défaut). Basculable depuis l'écran « Thème ».
  ThemeMode themeMode = ThemeMode.system;
  bool get isLightMode => themeMode == ThemeMode.light;

  void setThemeMode(ThemeMode mode) {
    if (themeMode == mode) return;
    themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    setThemeMode(isLightMode ? ThemeMode.dark : ThemeMode.light);
  }

  /// Langue de l'interface. Le changement est réactif ; la traduction complète
  /// (i18n) reste à brancher, mais le choix est mémorisé.
  AppLanguage language = AppLanguage.french;

  void setLanguage(AppLanguage value) {
    if (language == value) return;
    language = value;
    notifyListeners();
  }

  /// Déverrouillage par empreinte digitale — pas encore implémenté (aucune
  /// vérification biométrique native branchée) ; le bouton correspondant est
  /// désactivé côté UI plutôt que de laisser croire à un réglage actif.
  final bool biometricEnabled = false;

  /// Préférences de notification affichées à titre indicatif — pas encore
  /// synchronisées avec le serveur, qui ne filtre rien selon elles ; les
  /// bascules correspondantes sont désactivées côté UI (voir `profile_pages.dart`).
  final Map<AppNotification, bool> notificationPrefs = {
    AppNotification.savingReminder: true,
    AppNotification.paymentConfirmed: true,
    AppNotification.delivery: true,
    AppNotification.newKits: false,
    AppNotification.promotions: false,
    AppNotification.paymentOverdue: true,
  };

  bool isNotificationEnabled(AppNotification kind) =>
      notificationPrefs[kind] ?? false;

  DeliveryOrder deliveryOrder = DeliveryOrder(
    registrationDate: DateTime(2026, 6, 24),
    orderDate: DateTime(2026, 8, 10),
    status: DeliveryStatus.preparation,
  );
  List<DeliveryIssueReport> issueReports = [];

  RequestState<ParentDashboardData> homeState = const RequestState.idle();
  RequestState<void> registrationState = const RequestState.idle();
  RequestState<PaymentResult> paymentState = const RequestState.idle();
  RequestState<void> profileState = const RequestState.idle();
  RequestState<void> childState = const RequestState.idle();
  RequestState<void> authState = const RequestState.idle();

  bool get loading =>
      homeState.isLoading ||
      registrationState.isLoading ||
      paymentState.isLoading ||
      profileState.isLoading ||
      childState.isLoading ||
      authState.isLoading;
  Object? get lastError => [
    homeState.error,
    registrationState.error,
    paymentState.error,
    profileState.error,
    childState.error,
    authState.error,
  ].firstWhere((error) => error != null, orElse: () => null);

  final phoneController = TextEditingController();
  final nameController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final childNameController = TextEditingController();
  final childLevelController = TextEditingController();
  final childSchoolController = TextEditingController();
  final otpController = TextEditingController();
  // Mot de passe choisi à l'inscription (après vérification OTP).
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  // Mot de passe saisi lors d'une reconnexion (numéro + mot de passe, sans OTP).
  final loginPasswordController = TextEditingController();
  final refundReasonController = TextEditingController();
  String otpValue = '';

  /// Plan d'épargne recalculé en continu par le [computeSavingsPlan] : source
  /// unique de vérité pour l'objectif, le reste, la cotisation et la date
  /// limite. Recalculé à chaque lecture, donc toujours à jour après un
  /// paiement, un ajout/suppression d'enfant, un changement de kit ou de date.
  SavingsPlanComputation get savingsPlan =>
      computeSavingsPlan(children: children, frequency: plan);

  SavingsPlanComputation savingsPlanFor(SavingsGoalType type) =>
      computeSavingsPlan(
        children: children,
        frequency: plan,
        targetGoalType: type,
      );

  int get totalSaved => savingsPlan.totalSaved;
  int get totalGoal => savingsPlan.totalGoal;
  int get progress => savingsPlan.progressPercent;
  String get displayName => profile?.fullName ?? nameController.text;
  String get qrPayload => profile?.qrPayload ?? '';

  /// Reste global à épargner (Σ des restes dus de chaque enfant).
  int get globalRemaining => savingsPlan.globalRemaining;

  /// Objectif de cotisation atteint : le reste global est nul. Au-delà, toute
  /// nouvelle cotisation est bloquée (on ne laisse pas le parent sur-cotiser).
  bool get goalReached => savingsPlan.goalReached;

  /// True once every child has a kit assigned (Étape 1 de BUSINESS_RULES.md).
  bool get allChildrenHaveKit =>
      children.isNotEmpty &&
      children.every((child) => child.suppliesCost > 0 || isKitLocked(child));

  /// True once every child has at least one objective assigned (kits, scolarité, transport).
  bool get allChildrenHaveGoal =>
      children.isNotEmpty && children.every((child) => child.hasAnyGoal);

  /// Nombre de périodes restantes avant la date limite pour la fréquence choisie.
  int get remainingPeriods => savingsPlan.periodsRemaining;

  /// Montant à cotiser à la prochaine échéance. **Avant** la confirmation de
  /// la souscription (`quotaState` encore nul) : reste global réparti sur le
  /// temps restant, recalculé à chaque lecture (aperçu). **Après** : la valeur
  /// de quota est FIGÉE (règle métier « Calcul des quotas ») et ne change plus
  /// jusqu'à la fin de la campagne, quels que soient les événements suivants.
  int get installmentAmount =>
      quotaState?.quotaValue ?? savingsPlan.perPeriodAmount;

  /// Nombre de quotas entièrement validés depuis le début de la campagne
  /// (`0` tant que la souscription n'est pas confirmée).
  int get quotasAcquired => quotaState?.quotasAcquired ?? 0;

  /// Reliquat en attente (< valeur d'un quota) : montant déjà versé mais pas
  /// encore suffisant pour compléter un quota complet. Aucun montant versé
  /// n'est perdu — il est automatiquement reporté sur le prochain paiement.
  int get pendingQuotaBalance => quotaState?.availableBalance ?? 0;

  /// Règle métier §6 : vrai dès que le dossier accuse ≥ 3 périodes de retard
  /// sur les quotas qui auraient dû être validés depuis le début de la
  /// campagne.
  bool get isPaymentOverdue => quotaState != null && isInArrears(quotaState!);

  /// Contributions that allocated at least part of their amount to [childFirstName].
  List<Contribution> contributionsFor(String childFirstName) => contributions
      .where(
        (contribution) => contribution.allocations.any(
          (allocation) => allocation.childFirstName == childFirstName,
        ),
      )
      .toList();

  /// This child's share of a given contribution (0 if it wasn't part of it).
  int shareOf(Contribution contribution, String childFirstName) => contribution
      .allocations
      .where((allocation) => allocation.childFirstName == childFirstName)
      .fold(0, (total, allocation) => total + allocation.amount);

  /// Progression (0.0–1.0) du financement du kit d'un enfant.
  double kitProgressOf(ChildProfile child) {
    final price = child.resolvedKit?.price ?? 0;
    if (price <= 0) return 0;
    return (child.savedAmount / price).clamp(0.0, 1.0);
  }

  /// Règle métier : dès qu’un paiement a été reçu pour un enfant, son kit est
  /// verrouillé — on ne peut plus le modifier, le remplacer ni le supprimer
  /// (stabilité de la commande). On garde aussi le verrouillage au seuil de
  /// 75 % pour les cas où le montant est déjà très avancé sans paiement direct.
  bool isKitLocked(ChildProfile child) {
    if (child.savedAmount > 0) return true;
    return kitProgressOf(child) >= kKitLockThreshold;
  }

  bool isKitLockedAt(int index) =>
      index >= 0 && index < children.length && isKitLocked(children[index]);

  Future<void> assignStandardKit(int childIndex, SchoolKit kit) async {
    // Kit verrouillé (≥ 75 %) : aucune modification autorisée.
    if (isKitLockedAt(childIndex)) return;
    final selection = ChildKitSelection.standard(kit);
    _updateChildKit(childIndex, selection);
    await persistChildKit(childIndex);
  }

  Future<void> persistChildKit(int childIndex) async {
    if (childIndex < 0 || childIndex >= children.length) return;
    final child = children[childIndex];
    if (child.id != null) {
      try {
        final updatedChild = await _useCases.updateChild(child);
        final next = [...children];
        next[childIndex] = updatedChild;
        children = next;
        notifyListeners();
      } catch (err) {
        debugPrint('[EduPay] ⚠️ Erreur persistance kit en base: $err');
      }
    }
  }

  /// [articleId] provient du catalogue officiel pour la classe de l'enfant
  /// (voir `SchoolCatalogue.articlesFor`).
  void toggleCustomKitItem(int childIndex, String articleId) {
    if (isKitLockedAt(childIndex)) return;
    final current = Map<String, int>.from(
      children[childIndex].kitSelection?.customItemIds ?? {},
    );
    if (current.containsKey(articleId)) {
      current.remove(articleId);
    } else {
      current[articleId] = 1;
    }
    _updateChildKit(childIndex, ChildKitSelection.custom(current));
  }

  void changeCustomKitItemQuantity(
    int childIndex,
    String articleId,
    int delta,
  ) {
    if (isKitLockedAt(childIndex)) return;
    final current = Map<String, int>.from(
      children[childIndex].kitSelection?.customItemIds ?? {},
    );
    final nextQuantity = (current[articleId] ?? 0) + delta;
    if (nextQuantity <= 0) {
      current.remove(articleId);
    } else {
      current[articleId] = nextQuantity;
    }
    _updateChildKit(childIndex, ChildKitSelection.custom(current));
  }

  void _updateChildKit(int childIndex, ChildKitSelection selection) {
    final updated = [...children];
    updated[childIndex] = updated[childIndex].copyWith(kitSelection: selection);
    children = updated;
    notifyListeners();
  }

  /// Définit le montant de la scolarité pour un enfant donné et l'enregistre.
  /// En cas d'ajout (isCumulative), additionne le reste dû de l'ancien objectif au nouveau montant.
  Future<void> setChildTuition(
    int childIndex,
    int amount, {
    bool isCumulative = false,
  }) async {
    if (childIndex < 0 || childIndex >= children.length) return;
    final child = children[childIndex];
    int effectiveAmount = amount;
    if (isCumulative && child.tuitionAmount > 0) {
      effectiveAmount = calculateCumulativeGoalTotal(
        oldTargetAmount: child.tuitionAmount,
        oldSavedAmount: child.tuitionSavedAmount,
        newGoalAmount: amount,
      );
    }
    if (child.id != null) {
      await _useCases.setChildTuition(child.id!, effectiveAmount);
    }
    final updated = [...children];
    updated[childIndex] = updated[childIndex].copyWith(tuitionAmount: effectiveAmount);
    children = updated;
    notifyListeners();
  }

  /// Définit le moyen de déplacement, son montant et sa date de fin personnalisée
  /// pour un enfant donné et l'enregistre.
  /// En cas d'ajout (isCumulative), additionne le reste dû de l'ancien objectif au nouveau montant.
  /// [clearTransportDeadline] : si true, efface la date de fin (retour à la date globale).
  Future<void> setChildTransport(
    int childIndex,
    int amount,
    String? type, {
    DateTime? deadline,
    bool isCumulative = false,
    bool clearTransportDeadline = false,
  }) async {
    if (childIndex < 0 || childIndex >= children.length) return;
    final child = children[childIndex];
    int effectiveAmount = amount;
    if (isCumulative && child.transportAmount > 0) {
      effectiveAmount = calculateCumulativeGoalTotal(
        oldTargetAmount: child.transportAmount,
        oldSavedAmount: child.transportSavedAmount,
        newGoalAmount: amount,
      );
    }
    if (child.id != null) {
      await _useCases.setChildTransport(child.id!, effectiveAmount, type);
    }
    final updated = [...children];
    updated[childIndex] = updated[childIndex].copyWith(
      transportAmount: effectiveAmount,
      transportType: type,
      // clearTransportDeadline=true efface la date, sinon garde deadline ?? existante
      transportDeadline: clearTransportDeadline ? null : (deadline ?? child.transportDeadline),
    );
    children = updated;
    notifyListeners();
  }

  /// Empêche `loadHomeData` de se redéclencher en boucle à chaque
  /// reconstruction : un compte neuf a légitimement `children` vide même
  /// après un chargement réussi, donc ce n'est pas un signal fiable de
  /// "pas encore chargé". Voir aussi [deliveryLoaded].
  bool homeLoaded = false;

  Future<void> loadHomeData() async {
    homeLoaded = true;
    homeState = RequestState.loading(data: homeState.data);
    notifyListeners();
    try {
      final data = await _useCases.loadDashboard();
      // Locally entered data stays authoritative until the backend confirms it.
      profile ??= data.profile;
      plan = data.profile.plan;
      if (data.children.isNotEmpty || children.isEmpty) {
        children = data.children;
      }
      contributions = data.contributions;
      // Aligne le prix/contenu des kits standards sur le backend (source
      // partagée avec l'app agent) au lieu du catalogue statique embarqué —
      // fire-and-forget : la home reste utilisable avec les valeurs du JSON
      // en attendant, aucune erreur réseau ne doit bloquer le chargement.
      unawaited(_syncKitPricesForChildren());
      unawaited(loadNotifications());
      unawaited(loadCurrentSeason());
      unawaited(loadVehicles());
      // Au retour dans l'app, on infère que le contrat a déjà été signé si des
      // données ne peuvent exister qu'après signature (cotisations, statut actif,
      // ou épargne déjà constituée) :
      if (!signed &&
          (data.profile.status == 'active' ||
              contributions.isNotEmpty ||
              children.any((child) => child.savedAmount > 0))) {
        signed = true;
      }
      homeState = RequestState.success(data);
    } catch (error) {
      homeState = RequestState.error(error, data: homeState.data);
    }
    notifyListeners();
  }

  /// Récupère, pour chaque classe distincte parmi [children], le kit réel du
  /// backend et l'applique à [SchoolCatalogue] (voir `applyBackendKits`).
  /// Best-effort par classe : l'échec d'une classe (réseau, classe encore
  /// absente côté backend) n'empêche pas les autres de se synchroniser.
  Future<void> _syncKitPricesForChildren() async {
    final levels = children
        .map((c) => c.level)
        .where((l) => l.isNotEmpty)
        .toSet();
    if (levels.isEmpty) return;
    try {
      final results = await Future.wait(
        levels.map((level) async {
          try {
            final kits = await repository.fetchKitsForClass(level);
            return (level, kits);
          } catch (_) {
            return (level, const []);
          }
        }),
      );
      var changed = false;
      for (final item in results) {
        final level = item.$1;
        final kits = item.$2;
        if (kits.isNotEmpty) {
          SchoolCatalogue.applyBackendKits(level, kits);
          changed = true;
        }
      }
      if (changed && !_disposed) notifyListeners();
    } catch (_) {}
  }

  List<NotificationItem> notifications = [];
  RequestState<void> notificationsState = const RequestState.idle();
  int get unreadNotificationsCount =>
      notifications.where((n) => !n.isRead).length;

  /// Charge le vrai fil de notifications serveur (`GET /parents/me/notifications`).
  Future<void> loadNotifications() async {
    notificationsState = const RequestState.loading();
    notifyListeners();
    try {
      final result = await repository.getNotifications();
      if (_disposed) return;
      notifications = result;
      notificationsState = const RequestState.success(null);
    } catch (error) {
      if (_disposed) return;
      notificationsState = RequestState.error(error);
    }
    notifyListeners();
  }

  /// Marque une notification comme lue (optimiste : l'UI se met à jour avant
  /// la confirmation serveur, best-effort en cas d'échec réseau).
  Future<void> markNotificationRead(String id) async {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index == -1 || notifications[index].isRead) return;
    notifications[index] = notifications[index].markedRead(DateTime.now());
    notifyListeners();
    try {
      await repository.markNotificationRead(id);
    } catch (_) {
      // Best-effort : l'état local reste marqué lu même si la sync échoue.
    }
  }

  Future<void> loadCurrentSeason() async {
    try {
      final season = await repository.getCurrentSeason();
      if (season != null) {
        currentSeason = season;
        setSeasonDeadline(season.deliveryDeadline);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> loadVehicles() async {
    try {
      final list = await repository.getVehicles();
      if (list.isNotEmpty) {
        availableVehicles = list;
      } else if (availableVehicles.isEmpty) {
        availableVehicles = _fallbackVehicles();
      }
      notifyListeners();
    } catch (_) {
      if (availableVehicles.isEmpty) {
        availableVehicles = _fallbackVehicles();
        notifyListeners();
      }
    }
  }

  static List<TransportVehicle> _fallbackVehicles() => const [
    TransportVehicle(
      id: 'moto-default',
      name: 'Moto Yamaha YBR 125',
      description: 'Moto solide et économe, idéale pour le transport des enfants et déplacements professionnels.',
      price: 650000,
      images: ['https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=600'],
      isAvailable: true,
    ),
    TransportVehicle(
      id: 'velo-default',
      name: 'Vélo Tout-Terrain (VTT) Junior',
      description: 'Vélo robuste équipé pour la piste, adapté aux élèves de collège et lycée.',
      price: 95000,
      images: ['https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=600'],
      isAvailable: true,
    ),
    TransportVehicle(
      id: 'tricycle-default',
      name: 'Tricycle KAVAKI Cargo 200cc',
      description: 'Engin 3 roues grand volume pour le transport familial et marchandises.',
      price: 1200000,
      images: ['https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=600'],
      isAvailable: true,
    ),
  ];

  void startAuth(AuthFlow flow) {
    authFlow = flow;
    resetOtp(notify: false);
    notifyListeners();
  }

  /// Étape 1 de l'inscription : demande l'envoi de l'OTP au numéro saisi.
  /// Retourne false si le numéro est vide ou si l'envoi échoue.
  Future<bool> requestOtp() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      authState = RequestState.error(
        ArgumentError('Entrez votre numéro de téléphone.'),
      );
      notifyListeners();
      return false;
    }
    authState = const RequestState.loading();
    notifyListeners();
    try {
      await _auth.requestOtp(phone);
      resetOtp(notify: false);
      authState = const RequestState.success(null);
      notifyListeners();
      return true;
    } catch (error) {
      authState = RequestState.error(error);
      notifyListeners();
      return false;
    }
  }

  /// Étape 1 du mot de passe oublié : demande l'envoi de l'OTP de réinitialisation.
  Future<bool> requestForgotOtp() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      authState = RequestState.error(
        ArgumentError('Entrez votre numéro de téléphone.'),
      );
      notifyListeners();
      return false;
    }
    authState = const RequestState.loading();
    notifyListeners();
    try {
      await _auth.requestPasswordReset(phone);
      resetOtp(notify: false);
      authState = const RequestState.success(null);
      notifyListeners();
      return true;
    } catch (error) {
      authState = RequestState.error(error);
      notifyListeners();
      return false;
    }
  }

  /// L'OTP ne sert qu'à la création de compte : on vérifie le code auprès du
  /// backend puis on passe à l'onboarding (profil + mot de passe). La
  /// reconnexion utilise [signIn] (numéro + mot de passe), sans OTP.
  Future<bool> completeOtp() async {
    authState = const RequestState.loading();
    notifyListeners();
    try {
      await _auth.verifyOtp(phone: phoneController.text.trim(), code: otpValue);
      if (authFlow == AuthFlow.forgotPassword) {
        authState = const RequestState.success(null);
      } else {
        authStatus = AuthStatus.onboarding;
        authState = const RequestState.success(null);
      }
      notifyListeners();
      return true;
    } catch (error) {
      authState = RequestState.error(error);
      resetOtp();
      return false;
    }
  }

  /// Réinitialise le mot de passe après validation de l'OTP.
  Future<bool> resetPassword() async {
    final passwordError = validateSignUpPassword();
    if (passwordError != null) {
      authState = RequestState.error(ArgumentError(passwordError));
      notifyListeners();
      return false;
    }
    authState = const RequestState.loading();
    notifyListeners();
    try {
      await _auth.resetPassword(newPassword: passwordController.text);
      authStatus = AuthStatus.authenticated;
      homeLoaded = false;
      await loadHomeData();
      authState = const RequestState.success(null);
      notifyListeners();
      return true;
    } catch (error) {
      authState = RequestState.error(error);
      notifyListeners();
      return false;
    }
  }

  /// Étape 2 de l'inscription : crée le compte (profil + mot de passe). Le
  /// numéro est porté par le registrationToken côté service, jamais renvoyé ici.
  Future<bool> registerAccount() async {
    final passwordError = validateSignUpPassword();
    if (passwordError != null) {
      profileState = RequestState.error(ArgumentError(passwordError));
      notifyListeners();
      return false;
    }
    final draft = ParentProfile(
      fullName: nameController.text.trim(),
      phone: phoneController.text.trim(),
      city: cityController.text.trim(),
      district: districtController.text.trim(),
    );
    profileState = const RequestState.loading();
    notifyListeners();
    try {
      final status = await _auth.register(
        fullName: draft.fullName,
        city: draft.city,
        district: draft.district,
        password: passwordController.text,
      );
      profile = draft;
      profileState = const RequestState.success(null);
      authStatus = status == 'pendingValidation'
          ? AuthStatus.pendingApproval
          : AuthStatus.authenticated;
      notifyListeners();
      unawaited(_fcm?.registerCurrentDevice());
      return true;
    } catch (error) {
      profileState = RequestState.error(error);
      notifyListeners();
      return false;
    }
  }

  /// Reconnexion d'un compte existant avec numéro + mot de passe (aucun OTP).
  Future<bool> signIn() async {
    final phone = phoneController.text.trim();
    final password = loginPasswordController.text;
    if (phone.isEmpty || password.isEmpty) {
      authState = RequestState.error(
        ArgumentError('Renseignez votre numéro et votre mot de passe.'),
      );
      notifyListeners();
      return false;
    }
    authState = const RequestState.loading();
    notifyListeners();
    try {
      final status = await _auth.login(phone: phone, password: password);
      authState = const RequestState.success(null);
      unawaited(_fcm?.registerCurrentDevice());
      if (status == 'pendingValidation') {
        authStatus = AuthStatus.pendingApproval;
        notifyListeners();
        return true;
      }
      authStatus = AuthStatus.authenticated;
      notifyListeners();
      await loadHomeData();
      return true;
    } catch (error) {
      authState = RequestState.error(error);
      notifyListeners();
      return false;
    }
  }

  /// Rappelée depuis l'écran d'attente de validation (« Vérifier à nouveau ») :
  /// recharge le profil et débloque vers la home si l'admin a validé le
  /// compte entre-temps. Ne fait rien de visible si le compte est toujours
  /// `pendingValidation` (pas d'erreur affichée — ce n'est pas un échec).
  Future<void> checkPendingApproval() async {
    try {
      final fresh = await repository.getProfile();
      if (fresh.status != 'pendingValidation') {
        profile = fresh;
        authStatus = AuthStatus.authenticated;
        notifyListeners();
        await loadHomeData();
      }
    } catch (_) {
      // Erreur réseau : on reste sur l'écran d'attente, l'utilisateur peut réessayer.
    }
  }

  /// Valide la paire de mots de passe saisie à l'inscription. Retourne null si
  /// tout est correct, sinon un message d'erreur à afficher. La longueur
  /// minimale (8) reflète la politique du backend (§5.2.5).
  String? validateSignUpPassword() {
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;
    if (password.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères.';
    }
    if (password != confirm) {
      return 'Les mots de passe ne correspondent pas.';
    }
    return null;
  }

  /// L'OTP backend fait 6 chiffres (§5.2.1).
  static const otpLength = 6;

  void appendOtpDigit(String digit) {
    if (otpValue.length >= otpLength) return;
    otpValue += digit;
    otpController.text = otpValue;
    notifyListeners();
  }

  void removeOtpDigit() {
    if (otpValue.isEmpty) return;
    otpValue = otpValue.substring(0, otpValue.length - 1);
    otpController.text = otpValue;
    notifyListeners();
  }

  void resetOtp({bool notify = true}) {
    otpValue = '';
    otpController.clear();
    if (notify) notifyListeners();
  }

  void selectPlan(SavingsPlan nextPlan) {
    plan = nextPlan;
    notifyListeners();
  }

  void setContractAgreed(bool value) {
    signed = value;
    notifyListeners();
  }

  void selectPaymentMethod(PaymentMethod method) {
    paymentMethod = method;
    notifyListeners();
  }

  Future<void> saveProfile() async {
    final draft = ParentProfile(
      fullName: nameController.text.trim(),
      phone: phoneController.text.trim(),
      city: cityController.text.trim(),
      district: districtController.text.trim(),
    );
    profile = draft;
    profileState = const RequestState.loading();
    notifyListeners();
    try {
      profile = await _useCases.saveProfile(draft);
      profileState = const RequestState.success(null);
    } catch (error) {
      profileState = RequestState.error(error);
    }
    notifyListeners();
  }

  /// Returns true only when the child has been accepted by the repository.
  /// Keeping this boundary explicit prevents the UI from closing the form on
  /// an API failure.
  Future<bool> addChild() async {
    final firstName = childNameController.text.trim();
    final level = childLevelController.text.trim();
    final school = childSchoolController.text.trim();
    if (firstName.isEmpty || level.isEmpty || school.isEmpty) {
      childState = RequestState.error(
        ArgumentError(
          'Renseignez le prénom, le niveau et l’école de l’enfant.',
        ),
      );
      notifyListeners();
      return false;
    }
    // Règle métier : la classe doit être une des classes officielles du
    // catalogue (fichier Excel) — aucune valeur libre n'est acceptée.
    if (!SchoolCatalogue.isValidClass(level)) {
      childState = RequestState.error(
        ArgumentError(
          'Classe invalide : choisissez une classe dans la liste proposée.',
        ),
      );
      notifyListeners();
      return false;
    }

    final child = ChildProfile(
      firstName: firstName,
      level: level,
      school: school,
      savedAmount: 0,
    );

    // Ajout optimiste pour ne pas bloquer l'interface
    children = [...children, child];
    childNameController.clear();
    childLevelController.clear();
    childSchoolController.clear();

    // Sauvegarde en arrière-plan sans bloquer
    _useCases
        .addChild(child)
        .then((serverChild) {
          // La création renvoie l'UUID serveur : remplaçons le brouillon optimiste
          // afin que les futures modifications/suppressions ciblent la bonne route.
          children = [
            for (final current in children)
              if (identical(current, child)) serverChild else current,
          ];
          notifyListeners();
        })
        .catchError((error) {
          children = children.where((c) => !identical(c, child)).toList();
          childState = RequestState.error(error);
          notifyListeners();
        });

    notifyListeners();
    return true;
  }

  /// Règle métier : un enfant peut être retiré **tant qu'aucun quota ne lui a
  /// encore été attribué**. `savedAmount`/les allocations de cotisation ne
  /// grossissent QUE lorsqu'un quota est validé (voir quota_engine.dart) —
  /// donc `savedAmount > 0` (ou une présence dans les allocations d'une
  /// cotisation) signifie exactement « cet enfant a reçu au moins un quota ».
  /// Dès lors, il est verrouillé afin de préserver l'intégrité des calculs et
  /// de l'historique des cotisations. Un enfant ajouté après la signature
  /// reste donc supprimable jusqu'à ce qu'un quota lui soit effectivement
  /// attribué.
  bool canRemoveChild(int index) {
    if (index < 0 || index >= children.length) return false;
    final child = children[index];
    if (child.savedAmount > 0) return false;
    return !contributions.any(
      (contribution) => contribution.allocations.any(
        (allocation) => allocation.childFirstName == child.firstName,
      ),
    );
  }

  Future<void> removeChild(int index) async {
    // Garde-fou métier : aucune suppression dès qu'une part de cotisation a été
    // attribuée à cet enfant.
    if (!canRemoveChild(index)) {
      childState = RequestState.error(
        StateError(
          'Cet enfant a déjà reçu une part de cotisation et ne peut plus être retiré.',
        ),
      );
      notifyListeners();
      return;
    }
    final child = children[index];
    children = [...children]..removeAt(index);
    childState = const RequestState.loading();
    notifyListeners();
    try {
      await _useCases.deleteChild(child);
      childState = const RequestState.success(null);
    } catch (error) {
      childState = RequestState.error(error);
    }
    notifyListeners();
  }

  Future<void> confirmSubscriptionPlan() async {
    registrationState = const RequestState.loading();
    notifyListeners();
    try {
      // 1) Synchronise d'abord les kits des enfants vers le backend, sinon le
      //    serveur voit des enfants sans kit (prix 0) et calcule un objectif et
      //    des restes dus à 0 → cotisations enregistrées à 0.
      await _useCases.syncChildrenKits(children);
      // 2) La fréquence choisie (journalier/hebdo/mensuel) est transmise au
      //    backend pour être persistée (§4.1) ; le serveur recalcule alors
      //    l'objectif et la cotisation à partir des kits synchronisés.
      //    L'acceptation du contrat est une simple case à cocher côté client
      //    (voir `signed`) — pas de signature manuscrite envoyée au serveur.
      await _useCases.confirmSubscriptionPlan(plan.name);
      registrationState = const RequestState.success(null);
    } catch (error) {
      registrationState = RequestState.error(error);
    }
    // Figé/recalculé indépendamment du résultat de la synchronisation
    // backend : l'app reste la source de vérité locale.
    _freezeOrRecalculateQuota();
    notifyListeners();
  }

  /// Règle métier « Calcul des quotas » (figé une seule fois) + règle
  /// « Recalcul lors de l'ajout d'un nouveau kit ». Le quota n'est recalculé
  /// QUE si le montant total des kits a changé depuis le dernier calcul (un
  /// nouveau kit vient d'être sélectionné et validé pour un enfant) : un
  /// enfant ajouté SANS kit, ou un simple changement de fréquence, ne
  /// déclenche jamais de recalcul. Les quotas déjà validés
  /// (`quotasAcquired`) et le reliquat (`availableBalance`) sont toujours
  /// conservés tels quels — seule la valeur du quota et les périodes
  /// restantes changent, redistribuées de façon à ce que tous les kits
  /// atteignent 100 % à la même date (propriété déjà garantie par
  /// `savingsPlan.perPeriodAmount`, qui divise le reste global — kits déjà
  /// financés déduits — par les périodes restantes jusqu'à la fin de la
  /// campagne).
  void _freezeOrRecalculateQuota() {
    final currentGoal = savingsPlan.totalGoal;
    final existing = quotaState;
    if (existing == null) {
      quotaState = QuotaState(
        quotaValue: savingsPlan.perPeriodAmount,
        subscriptionStartDate: DateTime.now(),
        frequency: plan,
        totalGoalAtFreeze: currentGoal,
      );
      return;
    }
    if (currentGoal == existing.totalGoalAtFreeze) {
      // Aucun nouveau kit sélectionné/validé depuis le dernier calcul.
      return;
    }
    quotaState = existing.copyWith(
      quotaValue: savingsPlan.perPeriodAmount,
      totalGoalAtFreeze: currentGoal,
    );
  }

  void finishOnboarding() {
    authStatus = AuthStatus.authenticated;
    notifyListeners();
  }

  /// Cotisation. [amount] permet de payer un montant **supérieur** ou
  /// **inférieur** à la valeur du quota (règles métier §3/§4) :
  /// - le montant versé est d'abord ajouté au solde disponible (reliquat) ;
  /// - le système valide ensuite autant de quotas COMPLETS que possible
  ///   (chacun crédité aux enfants via le mécanisme de répartition existant,
  ///   qui pilote la barre de progression — **inchangé**, voir règle §7) ;
  /// - un paiement qui ne complète aucun quota ne fait que grossir le
  ///   reliquat (aucun montant versé n'est perdu, reporté sur le prochain
  ///   paiement).
  ///
  /// Par défaut on cotise la valeur du quota. Le montant est borné au reste
  /// global (aucune sur-épargne au-delà de l'objectif).
  Future<void> pay({int? amount, SavingsGoalType? targetGoalType}) async {
    final plan = targetGoalType != null
        ? savingsPlanFor(targetGoalType)
        : savingsPlan;
    // Garde-fou : aucune cotisation une fois l'objectif atteint.
    if (plan.goalReached) {
      paymentState = RequestState.error(
        ArgumentError('Objectif de cotisation déjà atteint.'),
      );
      notifyListeners();
      return;
    }
    final requested = amount ?? installmentAmount;
    // Au moins 1 F, jamais plus que le reste global (le surplus au-delà de
    // l'objectif n'est pas prélevé).
    final effective = requested.clamp(1, plan.globalRemaining);
    paymentState = const RequestState.loading();
    notifyListeners();
    try {
      // Synchronise les kits / objectifs vers le backend pour garantir que
      // la base de données enregistre bien la cotisation et l'épargne.
      await _useCases.syncChildrenKits(children);

      // Filet de sécurité : la souscription gèle normalement le quota à sa
      // confirmation (confirmSubscriptionPlan). S'il manque encore (compte
      // ancien, paiement direct en test), on le fige maintenant.
      final baseQuota =
          quotaState ??
          QuotaState(
            quotaValue: installmentAmount,
            subscriptionStartDate: DateTime.now(),
            frequency: this.plan,
            totalGoalAtFreeze: savingsPlan.totalGoal,
          );
      // Calculé sans muter l'état courant : tant que le serveur n'a pas
      // confirmé la cotisation, ni le quota ni l'épargne des enfants ne
      // doivent avancer, sous peine d'afficher une progression que
      // l'historique (« Echoue ») contredirait juste en dessous.
      final quotaResult = applyQuotaPayment(baseQuota, effective);
      // L'intégralité du montant versé (`effective`) est créditée aux
      // enfants selon la règle de répartition et le type d'objectif ciblé.
      final result = await _useCases.makePayment(
        children: children,
        amount: effective,
        paymentMethod: paymentMethod,
        displayAmount: effective,
        targetGoalType: targetGoalType,
      );
      contributions = [result.contribution, ...contributions];
      quotaState = quotaResult.state;
      children = result.children;
      paymentState = RequestState.success(result);
    } catch (error) {
      paymentState = RequestState.error(error);
    }
    notifyListeners();
  }

  static const _cityCoordinates = {
    'Ouagadougou': (12.3714, -1.5197),
    'Koudougou': (12.2529, -2.3620),
    'Bobo-Dioulasso': (11.1771, -4.2979),
  };

  /// Charge l'état de livraison depuis le backend (silencieux en cas d'échec :
  /// on conserve l'état local courant).
  bool deliveryLoaded = false;

  Future<void> loadDelivery() async {
    deliveryLoaded = true;
    try {
      deliveryOrder = await repository.getDelivery();
    } catch (_) {
      // conserve l'état local
    }
    notifyListeners();
  }

  /// The PARENT sends their own position so the delivery agent knows where to
  /// bring the order. Coordonnées dérivées de la ville/quartier (pas de GPS
  /// réel), puis envoyées au backend ; repli local si le réseau échoue.
  Future<void> sendDeliveryLocation() async {
    final city = profile?.city ?? cityController.text;
    final district = profile?.district ?? districtController.text;
    final coordinates =
        _cityCoordinates[city] ?? _cityCoordinates['Koudougou']!;
    final address = '$district, $city';
    try {
      deliveryOrder = await repository.sendDeliveryLocation(
        lat: coordinates.$1,
        lng: coordinates.$2,
        address: address,
      );
    } catch (_) {
      deliveryOrder = deliveryOrder.copyWith(
        location: DeliveryLocation(
          lat: coordinates.$1,
          lng: coordinates.$2,
          address: address,
          sentAt: DateTime.now(),
        ),
      );
    }
    notifyListeners();
  }

  /// Renvoie `true` si le serveur a bien enregistré la confirmation. En cas
  /// d'échec, l'état local (livraison, enfants, cotisations, quota) reste
  /// intact — on ne clôt le cycle d'épargne que si le serveur l'a réellement
  /// acté, sinon un simple hoquet réseau effacerait l'épargne accumulée.
  Future<bool> confirmDeliveryReceipt({String? signature}) async {
    try {
      deliveryOrder = await repository.confirmDeliveryReceipt(
        signature: signature,
      );
    } catch (_) {
      notifyListeners();
      return false;
    }
    // Règle métier : la réception clôt le cycle en cours et en ouvre un neuf.
    _startNewSavingsCycle();
    notifyListeners();
    return true;
  }

  /// Ouvre un nouveau cycle d'épargne après la confirmation de réception :
  /// tous les compteurs de progression repassent à 0 % et l'ensemble des kits
  /// sélectionnés est retiré. Les enfants restent inscrits (mêmes profils) ;
  /// les montants d'objectifs permanents (scolarité, transport) sont préservés.
  /// Le parent peut aussitôt refaire une sélection de kits et re-souscrire.
  void _startNewSavingsCycle() {
    children = [
      for (final child in children)
        ChildProfile(
          id: child.id,
          firstName: child.firstName,
          level: child.level,
          school: child.school,
          savedAmount: 0,
          kitSavedAmount: 0,
          // kitSelection non fourni → remis à null (nouvelle sélection à faire).
          // Préservation des objectifs permanents — ils ne dépendent pas du cycle de kits :
          tuitionAmount: child.tuitionAmount,
          tuitionSavedAmount: 0,
          transportAmount: child.transportAmount,
          transportSavedAmount: 0,
          transportType: child.transportType,
          transportDeadline: child.transportDeadline,
        ),
    ];
    contributions = [];
    // Nouveau cycle : le contrat devra être re-signé pour la nouvelle sélection.
    signed = false;
    // Nouveau cycle = nouveau calcul de quota (re-figé à la prochaine
    // confirmation de souscription, une fois les nouveaux kits choisis).
    quotaState = null;
  }

  void submitIssueReport(DeliveryIssueReport report) {
    issueReports = [report, ...issueReports];
    notifyListeners();
    // Persistance best-effort (la photo locale n'est pas encore uploadée).
    repository
        .reportDeliveryIssue(type: report.type, description: report.description)
        .catchError((_) {});
  }

  /// Dernière demande de remboursement acceptée par le serveur — montant et
  /// référence de dossier réels (voir `RefundRequest`), affichés sur l'écran
  /// de confirmation au lieu d'une valeur recalculée côté client.
  RefundRequest? lastRefundRequest;

  /// Demande de remboursement. Retourne false en cas d'échec réseau (le
  /// motif reste alors dans `refundReasonController` pour une nouvelle
  /// tentative).
  Future<bool> requestRefund({String? reason}) async {
    try {
      lastRefundRequest = await repository.requestRefund(reason: reason);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() async {
    // 1. Purge locale immédiate : l'utilisateur quitte l'espace connecté instantanément (< 50ms)
    _purgeSession();
    // 2. Révocation réseau et retrait FCM en arrière-plan sans bloquer l'UI
    unawaited(() async {
      try {
        await _fcm?.unregisterCurrentDevice().timeout(const Duration(seconds: 2));
      } catch (_) {}
      try {
        await _auth.signOut().timeout(const Duration(seconds: 3));
      } catch (_) {}
    }());
  }

  /// Change le mot de passe côté backend. Retourne `null` en cas de succès, ou
  /// un message d'erreur prêt à afficher (ex. mot de passe actuel incorrect).
  Future<String?> changePassword({
    required String current,
    required String next,
  }) async {
    try {
      await _auth.changePassword(current: current, next: next);
      return null;
    } on ApiException catch (error) {
      return switch (error.code) {
        'INVALID_CURRENT_PASSWORD' => 'Mot de passe actuel incorrect.',
        'WEAK_PASSWORD' => 'Mot de passe trop faible (8 caractères minimum).',
        _ => error.message,
      };
    } catch (_) {
      return 'Impossible de modifier le mot de passe. Vérifiez votre connexion.';
    }
  }

  /// Liste les appareils/sessions actifs du compte.
  Future<List<ActiveSession>> loadSessions() => _auth.listSessions();

  /// Déconnecte un appareil distant (révoque sa session).
  Future<void> revokeSession(String id) => _auth.revokeSession(id);

  /// Déconnexion de TOUS les appareils (y compris celui-ci).
  Future<void> signOutAllDevices() async {
    _purgeSession();
    unawaited(() async {
      try {
        await _fcm?.unregisterCurrentDevice().timeout(const Duration(seconds: 2));
      } catch (_) {}
      try {
        await _auth.revokeAllSessions().timeout(const Duration(seconds: 3));
      } catch (_) {}
    }());
  }

  /// Remet l'app à l'état déconnecté et purge les données de session pour
  /// éviter tout report entre comptes.
  void _purgeSession() {
    authStatus = AuthStatus.unauthenticated;
    profile = null;
    children = [];
    contributions = [];
    homeLoaded = false;
    deliveryLoaded = false;
    loginPasswordController.clear();
    resetOtp(notify: false);
    notifyListeners();
  }

  /// Garde contre les callbacks fire-and-forget (`loadNotifications`,
  /// `_syncKitPricesForChildren`...) qui résolvent après que l'état a été
  /// disposé (ex. déconnexion pendant un chargement en arrière-plan) — sans
  /// cette garde, leur `notifyListeners()` tardif lève sur un
  /// `ChangeNotifier` déjà disposé.
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    phoneController.dispose();
    nameController.dispose();
    cityController.dispose();
    districtController.dispose();
    childNameController.dispose();
    childLevelController.dispose();
    childSchoolController.dispose();
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    loginPasswordController.dispose();
    refundReasonController.dispose();
    super.dispose();
  }
}
