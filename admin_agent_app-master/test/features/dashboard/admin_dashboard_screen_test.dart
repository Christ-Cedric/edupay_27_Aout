import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edupay_admin/features/dashboard/data/dashboard_repository.dart';
import 'package:edupay_admin/features/dashboard/domain/models/dashboard_alert.dart';
import 'package:edupay_admin/features/dashboard/domain/models/dashboard_summary.dart';
import 'package:edupay_admin/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:edupay_admin/features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'package:edupay_admin/features/notifications/data/notifications_repository.dart';
import 'package:edupay_admin/features/notifications/domain/models/notification_entry.dart';
import 'package:edupay_admin/features/notifications/presentation/providers/notifications_providers.dart';

const _summary = DashboardSummary(
  season: 'Saison 2025-2026',
  activeFamilies: 47,
  totalCollected: 1200000,
  collectionRate: 0.89,
  overduePayments: 5,
  activeAgents: 3,
  pendingDeliveries: 12,
  alerts: [
    DashboardAlert(
      title: '5 familles - impayés +14 jours',
      subtitle: 'Action requise - relancer les agents',
      severity: DashboardAlertSeverity.danger,
      kind: DashboardAlertKind.overduePayments,
    ),
  ],
);

class _FakeDashboardRepository implements DashboardRepository {
  _FakeDashboardRepository(this._result);
  final Future<DashboardSummary> Function() _result;

  @override
  Future<DashboardSummary> getSummary() => _result();
}

/// Résout instantanément (sans le délai simulé de [FakeNotificationsDataSource])
/// — l'écran dashboard n'exerce ici que son propre chargement, pas celui du
/// badge de notifications.
class _FakeNotificationsRepository implements NotificationsRepository {
  @override
  Future<List<NotificationEntry>> getRecent() async => const [];

  @override
  Future<void> markRead(String id) async {}
}

Future<void> _pump(WidgetTester tester, DashboardRepository repository) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        dashboardRepositoryProvider.overrideWithValue(repository),
        notificationsRepositoryProvider.overrideWithValue(_FakeNotificationsRepository()),
      ],
      child: const MaterialApp(home: AdminDashboardScreen()),
    ),
  );
}

void main() {
  testWidgets(
    'affiche un indicateur de chargement avant que les données arrivent',
    (tester) async {
      // Vérifié juste après pumpWidget, avant tout pump() supplémentaire : la
      // fake repository résout en une micro-tâche, donc l'état "chargement"
      // n'est observable qu'à ce tout premier instant.
      await _pump(tester, _FakeDashboardRepository(() async => _summary));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets('affiche les KPI une fois les données chargées', (tester) async {
    await _pump(tester, _FakeDashboardRepository(() async => _summary));
    await tester.pumpAndSettle();

    expect(find.text('47'), findsOneWidget);
    expect(find.text('1,2M F'), findsOneWidget);
    expect(find.text('89%'), findsOneWidget);

    // La section alertes est plus bas dans la liste ; sur le viewport de
    // test par défaut (800×600), la ListView (lazy) ne l'a pas encore
    // construite tant qu'on ne défile pas jusqu'à elle. Les KpiGrid internes
    // sont aussi des Scrollable (non interactifs), d'où le drag direct sur
    // la ListView plutôt qu'un `scrollUntilVisible` ambigu entre elles.
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text('5 familles - impayés +14 jours'), findsOneWidget);
  });

  testWidgets(
    'affiche un écran d\'erreur si la récupération échoue durablement',
    (tester) async {
      var attempts = 0;
      await _pump(
        tester,
        _FakeDashboardRepository(() async {
          attempts++;
          throw Exception('boom');
        }),
      );
      // Riverpod réessaie automatiquement plusieurs fois avant d'abandonner ;
      // pumpAndSettle avance le temps virtuel jusqu'à épuisement des essais.
      await tester.pumpAndSettle();

      expect(find.text('Erreur de connexion'), findsOneWidget);

      final attemptsBeforeRetry = attempts;
      await tester.tap(find.text('Réessayer'));
      await tester.pumpAndSettle();

      expect(attempts, greaterThan(attemptsBeforeRetry));
    },
  );
}
