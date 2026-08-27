import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:edupay_admin/features/agents/presentation/screens/agents_list_screen.dart';
import 'package:edupay_admin/features/agents/presentation/screens/new_agent_screen.dart';

Widget _app() {
  final router = GoRouter(
    initialLocation: '/admin/settings/agents',
    routes: [
      GoRoute(
        path: '/admin/settings/agents',
        builder: (context, state) => const AgentsListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const NewAgentScreen(),
          ),
        ],
      ),
    ],
  );
  return ProviderScope(child: MaterialApp.router(routerConfig: router));
}

void main() {
  testWidgets('affiche les agents seedés du prototype', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Konate Ali'), findsOneWidget);
    expect(find.text('Sana Wendyam'), findsOneWidget);
  });

  testWidgets('créer un agent le fait apparaître dans la liste', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('+ Ajouter un agent'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Traore Salif');
    await tester.enterText(fields.at(1), '+226 60 11 22 33');
    await tester.enterText(fields.at(2), 'motdepasse123');
    await tester.enterText(fields.at(3), 'motdepasse123');
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Créer le compte agent'));
    await tester.pumpAndSettle();

    expect(find.byType(AgentsListScreen), findsOneWidget);
    expect(find.text('Traore Salif'), findsOneWidget);
  });
}
