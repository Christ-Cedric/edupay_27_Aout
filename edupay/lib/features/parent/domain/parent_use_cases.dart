import 'parent_models.dart';
import 'parent_repository.dart';
import 'savings_engine.dart';
import 'school_catalogue.dart';

// Le moteur d'épargne (calcul des cotisations, date limite, allocation) est
// exposé aux appelants de ce fichier (état de présentation, écrans).
export 'savings_engine.dart';

class ParentDashboardData {
  const ParentDashboardData({
    required this.profile,
    required this.children,
    required this.contributions,
  });

  final ParentProfile profile;
  final List<ChildProfile> children;
  final List<Contribution> contributions;
}

class ParentUseCases {
  const ParentUseCases(this._repository);

  final ParentRepository _repository;

  Future<ParentDashboardData> loadDashboard() async {
    final result = await Future.wait([
      _repository.getProfile(),
      _repository.getChildren(),
      _repository.getContributions(),
    ]);
    return ParentDashboardData(
      profile: result[0] as ParentProfile,
      children: result[1] as List<ChildProfile>,
      contributions: result[2] as List<Contribution>,
    );
  }

  Future<ParentProfile> saveProfile(ParentProfile profile) =>
      _repository.saveProfile(profile);
  Future<ChildProfile> addChild(ChildProfile child) =>
      _repository.saveChild(child);
  Future<void> setChildTuition(String childId, int amount) =>
      _repository.setChildTuition(childId, amount);
  Future<void> setChildTransport(String childId, int amount, String? type) =>
      _repository.setChildTransport(childId, amount, type);
  Future<void> deleteChild(ChildProfile child) =>
      _repository.removeChild(child);
  Future<void> confirmSubscriptionPlan(String frequency, {String? signature}) =>
      _repository.confirmSubscriptionPlan(frequency, signature: signature);

  /// Synchronise vers le backend le kit choisi pour chaque enfant (best-effort,
  /// enfant par enfant). Sans cela, le serveur voit des enfants sans kit (prix
  /// 0) → objectif et restes dus à 0 → cotisations enregistrées à 0. À appeler
  /// avant de confirmer la souscription.
  Future<void> syncChildrenKits(List<ChildProfile> children) async {
    for (final child in children) {
      if (child.kitSelection == null) continue;
      try {
        await _repository.updateChild(child);
      } catch (_) {
        // Best-effort : un échec réseau ne bloque pas la confirmation.
      }
    }
  }

  /// Distribue [amount] entre les enfants au prorata de leur **reste dû** (via
  /// [allocateContribution]), plafonné à ce que chacun doit encore. L'excédent
  /// éventuel (paiement supérieur au reste global) n'est pas alloué, et le
  /// montant réellement enregistré reflète ce qui a servi à financer les
  /// objectifs. Cette répartition garantit que tous les enfants convergent vers
  /// 100 % à la même échéance.
  ///
  /// [amount] est le montant à CRÉDITER aux enfants (barre de progression,
  /// inchangée) — avec le système de quotas (§ règles quotas), ce n'est pas
  /// forcément le montant réellement versé par le parent : un paiement peut ne
  /// compléter aucun quota (amount=0, reliquat seul) ou en compléter plusieurs
  /// d'un coup. [displayAmount], s'il est fourni, est le montant réellement
  /// versé par le parent, affiché sur le reçu/l'historique (défaut : `amount`).
  Future<PaymentResult> makePayment({
    required List<ChildProfile> children,
    required int amount,
    required PaymentMethod paymentMethod,
    int? displayAmount,
    SavingsGoalType? targetGoalType,
  }) async {
    final remainings = [
      for (final child in children)
        targetGoalType == null
            ? child.totalCost - child.savedAmount
            : switch (targetGoalType) {
                SavingsGoalType.supplies ||
                SavingsGoalType.exam ||
                SavingsGoalType.canteen ||
                SavingsGoalType.uniform =>
                  child.suppliesCost - child.kitSavedAmount,
                SavingsGoalType.registration =>
                  child.tuitionAmount - child.tuitionSavedAmount,
                SavingsGoalType.transport =>
                  child.transportAmount - child.transportSavedAmount,
              },
    ];
    final shares = allocateContribution(
      remainingByChild: remainings,
      amount: amount,
    );

    final updatedChildren = <ChildProfile>[];
    final allocations = <ContributionAllocation>[];
    var allocated = 0;
    for (var i = 0; i < children.length; i++) {
      final share = shares[i];
      allocated += share;

      var updatedChild = children[i].copyWith(
        savedAmount: children[i].savedAmount + share,
      );
      if (targetGoalType != null) {
        switch (targetGoalType) {
          case SavingsGoalType.supplies:
          case SavingsGoalType.exam:
          case SavingsGoalType.canteen:
          case SavingsGoalType.uniform:
            updatedChild = updatedChild.copyWith(
              kitSavedAmount: updatedChild.kitSavedAmount + share,
            );
            break;
          case SavingsGoalType.registration:
            updatedChild = updatedChild.copyWith(
              tuitionSavedAmount: updatedChild.tuitionSavedAmount + share,
            );
            break;
          case SavingsGoalType.transport:
            updatedChild = updatedChild.copyWith(
              transportSavedAmount: updatedChild.transportSavedAmount + share,
            );
            break;
        }
      }
      updatedChildren.add(updatedChild);

      if (share > 0) {
        allocations.add(
          ContributionAllocation(
            childFirstName: children[i].firstName,
            amount: share,
          ),
        );
      }
    }

    // Montant affiché sur le reçu : le montant réellement versé si fourni,
    // sinon le montant réellement alloué (borne le cas « paiement > reste »).
    final localAmount = displayAmount ?? (allocated > 0 ? allocated : amount);
    var contribution = Contribution(
      date: 'Aujourd’hui',
      method: switch (paymentMethod) {
        PaymentMethod.orangeMoney => 'Orange Money',
        PaymentMethod.moovMoney => 'Moov Money',
        PaymentMethod.cashAgent => 'Espèces - Agent',
      },
      reference: _localReference(),
      amount: localAmount,
      success: true,
      allocations: allocations,
      targetGoalType: targetGoalType?.backendCode,
    );

    // L'app est la source de vérité (épargne calculée localement). La
    // persistance backend est best-effort : le serveur recalcule le montant de
    // SON côté (et peut renvoyer 0 si sa copie des enfants/kits n'est pas
    // synchronisée), donc on NE laisse PAS sa réponse écraser le montant local.
    // On récupère seulement la référence/date serveur si elles sont fournies.
    try {
      final server = await _repository.recordContribution(contribution);
      contribution = Contribution(
        date: server.date.isNotEmpty ? server.date : contribution.date,
        method: contribution.method,
        reference: server.reference.isNotEmpty
            ? server.reference
            : contribution.reference,
        amount: localAmount,
        success: server.success,
        allocations: allocations,
      );
    } catch (e, stackTrace) {
      // ignore: avoid_print
      print('[EduPay] ❌ Erreur serveur lors de recordContribution: $e');
      // ignore: avoid_print
      print('[EduPay] StackTrace: $stackTrace');
      // Le backend a rejeté la cotisation (ou est injoignable).
      // On ne masque plus l'erreur : on la relance pour empêcher la
      // mise à jour de la barre de progression locale.
      rethrow;
    }

    return PaymentResult(children: updatedChildren, contribution: contribution);
  }

  /// Référence locale de secours quand le backend n'en fournit pas.
  String _localReference() {
    final now = DateTime.now();
    final suffix = (now.millisecondsSinceEpoch % 10000).toString().padLeft(
      4,
      '0',
    );
    return 'EP-RC-${now.year}-$suffix';
  }
}

class PaymentResult {
  const PaymentResult({required this.children, required this.contribution});

  final List<ChildProfile> children;
  final Contribution contribution;
}
