import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/fake_refund_data_source.dart';
import '../../data/refund_data_source.dart';
import '../../data/refund_repository.dart';
import '../../data/refund_repository_impl.dart';
import '../../data/rest_refund_data_source.dart';
import '../../domain/models/refund_detail.dart';
import '../../domain/models/refund_month_summary.dart';
import '../../domain/models/refund_request.dart';

part 'refunds_providers.g.dart';

/// Composition root : mock par défaut, REST si `APP_ENV` cible un backend.
@Riverpod(keepAlive: true)
RefundDataSource refundDataSource(Ref ref) {
  if (ref.watch(usesMockDataProvider)) {
    return FakeRefundDataSource();
  }
  return RestRefundDataSource(ref.watch(apiClientProvider));
}

@Riverpod(keepAlive: true)
RefundRepository refundRepository(Ref ref) {
  return RefundRepositoryImpl(ref.watch(refundDataSourceProvider));
}

@riverpod
Future<List<RefundRequest>> pendingRefunds(Ref ref) {
  return ref.watch(refundRepositoryProvider).getPendingRefunds();
}

@riverpod
Future<RefundDetail> refundDetail(Ref ref, String id) {
  return ref.watch(refundRepositoryProvider).getRefundById(id);
}

@riverpod
Future<RefundMonthSummary> refundMonthSummary(Ref ref) {
  return ref.watch(refundRepositoryProvider).getMonthSummary();
}

@riverpod
class RefundValidationController extends _$RefundValidationController {
  @override
  FutureOr<void> build() {}

  Future<void> approve(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(refundRepositoryProvider).approveRefund(id);
      ref.invalidate(pendingRefundsProvider);
      ref.invalidate(refundMonthSummaryProvider);
      ref.invalidate(refundDetailProvider(id));
    });
  }

  Future<void> reject(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(refundRepositoryProvider).rejectRefund(id);
      ref.invalidate(pendingRefundsProvider);
      ref.invalidate(refundDetailProvider(id));
    });
  }
}
