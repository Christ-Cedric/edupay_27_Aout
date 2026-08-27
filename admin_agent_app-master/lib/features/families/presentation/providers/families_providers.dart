import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/fake_family_data_source.dart';
import '../../data/family_data_source.dart';
import '../../data/family_repository.dart';
import '../../data/family_repository_impl.dart';
import '../../data/rest_family_data_source.dart';
import '../../domain/models/family.dart';
import '../../domain/models/family_filter.dart';
import '../../domain/models/savings_plan.dart';

part 'families_providers.g.dart';

/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.
@Riverpod(keepAlive: true)
FamilyDataSource familyDataSource(Ref ref) {
  if (ref.watch(usesMockDataProvider)) {
    return FakeFamilyDataSource();
  }
  return RestFamilyDataSource(ref.watch(apiClientProvider));
}

@Riverpod(keepAlive: true)
FamilyRepository familyRepository(Ref ref) {
  return FamilyRepositoryImpl(ref.watch(familyDataSourceProvider));
}

@riverpod
Future<List<Family>> familiesList(Ref ref, FamilyFilter filter) {
  return ref.watch(familyRepositoryProvider).getFamilies(filter);
}

@riverpod
Future<Family> familyDetail(Ref ref, String id) {
  return ref.watch(familyRepositoryProvider).getFamilyById(id);
}

@riverpod
Future<List<Family>> pendingValidationList(Ref ref) {
  return ref.watch(familyRepositoryProvider).getPendingValidationFamilies();
}

/// Gère l'inscription directe d'une famille (motif `ad_in` du prototype).
@riverpod
class EnrollmentController extends _$EnrollmentController {
  @override
  FutureOr<Family?> build() => null;

  Future<void> enroll({
    required String fullName,
    required String phone,
    required SavingsPlan plan,
    required List<ChildEnrollmentInput> children,
    String? assignedAgentName,
    required String city,
    String? district,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final family = await ref
          .read(familyRepositoryProvider)
          .enrollFamily(
            fullName: fullName,
            phone: phone,
            plan: plan,
            children: children,
            assignedAgentName: assignedAgentName,
            city: city,
            district: district,
          );
      ref.invalidate(familiesListProvider);
      return family;
    });
  }
}

/// Approuve/rejette les comptes en attente de validation (règle métier
/// ajoutée par le client, absente du prototype — voir mémo de validation).
@riverpod
class ValidationController extends _$ValidationController {
  @override
  FutureOr<void> build() {}

  Future<void> approve(String familyId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(familyRepositoryProvider).approveFamily(familyId);
      ref.invalidate(pendingValidationListProvider);
      ref.invalidate(familiesListProvider);
    });
  }

  Future<void> approveAll(Iterable<String> familyIds) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Une validation par compte préserve les notifications et l'audit déjà
      // garantis par le backend pour chaque approbation.
      for (final familyId in familyIds) {
        await ref.read(familyRepositoryProvider).approveFamily(familyId);
      }
      ref.invalidate(pendingValidationListProvider);
      ref.invalidate(familiesListProvider);
    });
  }

  Future<void> reject(String familyId, String reason) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(familyRepositoryProvider).rejectFamily(familyId, reason);
      ref.invalidate(pendingValidationListProvider);
      ref.invalidate(familiesListProvider);
    });
  }
}

/// Enregistre un encaissement cash (dossier famille → « Enregistrer un
/// encaissement »).
@riverpod
class RecordContributionController extends _$RecordContributionController {
  @override
  FutureOr<Family?> build() => null;

  Future<void> record({
    required String familyId,
    required int amount,
    String? collectedByAgentId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final family = await ref
          .read(familyRepositoryProvider)
          .recordCashContribution(
            familyId: familyId,
            amount: amount,
            collectedByAgentId: collectedByAgentId,
          );
      ref.invalidate(familyDetailProvider(familyId));
      ref.invalidate(familiesListProvider);
      return family;
    });
  }
}

/// Ajout/modification/retrait d'un enfant et choix de son kit pour la saison
/// en cours (dossier famille → « Enfants ») — un enfant persiste
/// indépendamment des saisons ; le kit, lui, est choisi séparément, saison
/// par saison.
@riverpod
class ChildController extends _$ChildController {
  @override
  FutureOr<Family?> build() => null;

  Future<void> add({
    required String familyId,
    required String firstName,
    String? level,
    String? school,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final family = await ref
          .read(familyRepositoryProvider)
          .addChild(
            familyId: familyId,
            firstName: firstName,
            level: level,
            school: school,
          );
      ref.invalidate(familyDetailProvider(familyId));
      ref.invalidate(familiesListProvider);
      return family;
    });
  }

  Future<void> updateChild({
    required String familyId,
    required String childId,
    String? level,
    String? school,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final family = await ref
          .read(familyRepositoryProvider)
          .updateChild(
            familyId: familyId,
            childId: childId,
            level: level,
            school: school,
          );
      ref.invalidate(familyDetailProvider(familyId));
      ref.invalidate(familiesListProvider);
      return family;
    });
  }

  Future<void> remove({
    required String familyId,
    required String childId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final family = await ref
          .read(familyRepositoryProvider)
          .removeChild(familyId: familyId, childId: childId);
      ref.invalidate(familyDetailProvider(familyId));
      ref.invalidate(familiesListProvider);
      return family;
    });
  }

  Future<void> assignKit({
    required String familyId,
    required String childId,
    required String kitId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final family = await ref
          .read(familyRepositoryProvider)
          .assignKit(familyId: familyId, childId: childId, kitId: kitId);
      ref.invalidate(familyDetailProvider(familyId));
      ref.invalidate(familiesListProvider);
      return family;
    });
  }
}
