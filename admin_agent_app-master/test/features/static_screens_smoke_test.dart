import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:edupay_admin/features/alerts/presentation/screens/overdue_alerts_screen.dart';
import 'package:edupay_admin/features/deliveries/presentation/screens/deliveries_screen.dart';
import 'package:edupay_admin/features/reports/presentation/screens/reports_screen.dart';
import 'package:edupay_admin/features/settings/presentation/screens/season_settings_screen.dart';

/// Tests de fumée pour des écrans à faible logique (pas de flux à tester
/// bout en bout ailleurs) : vérifie juste qu'ils se construisent sans
/// erreur et affichent leur contenu clé.
void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  Future<void> pumpScreen(WidgetTester tester, Widget screen) {
    return tester.pumpWidget(ProviderScope(child: MaterialApp(home: screen)));
  }

  testWidgets('OverdueAlertsScreen affiche les familles en retard', (
    tester,
  ) async {
    await pumpScreen(tester, const OverdueAlertsScreen());
    await tester.pumpAndSettle();
    expect(find.text('Bila Ouedraogo'), findsOneWidget);
    expect(find.text('📢 Envoyer SMS de relance groupe'), findsOneWidget);
  });

  testWidgets('DeliveriesScreen affiche les KPI et le planning', (
    tester,
  ) async {
    await pumpScreen(tester, const DeliveriesScreen());
    await tester.pumpAndSettle();
    expect(find.text('PLANNING'), findsOneWidget);
    expect(find.text('Aminata Kabore'), findsOneWidget);
  });

  testWidgets('ReportsScreen affiche les 4 rapports exportables', (
    tester,
  ) async {
    await pumpScreen(tester, const ReportsScreen());
    expect(find.textContaining('Rapport cotisations'), findsOneWidget);
    expect(find.textContaining('Rapport livraisons'), findsOneWidget);
  });

  testWidgets('SeasonSettingsScreen affiche les tarifs de la saison', (
    tester,
  ) async {
    await pumpScreen(tester, const SeasonSettingsScreen());
    await tester.pumpAndSettle();
    expect(find.text('300 FCFA/jour'), findsOneWidget);
    expect(find.text('Agents terrain'), findsOneWidget);
    expect(find.text('Catalogue de kits'), findsOneWidget);
  });
}
