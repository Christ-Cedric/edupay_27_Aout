import 'package:edupay/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('loads the EduP@y app shell', (tester) async {
    await tester.pumpWidget(const EduPayApp());
    // Laisse le temps à la restauration de session (lecture asynchrone du
    // trousseau sécurisé) de se résoudre avant d'attendre l'écran d'accueil.
    await tester.pumpAndSettle();

    expect(find.text('Creer mon compte'), findsOneWidget);
    expect(find.text('J ai deja un compte'), findsOneWidget);
  });
}
