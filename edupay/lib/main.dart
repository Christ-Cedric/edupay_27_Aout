import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:intl/date_symbol_data_local.dart';

import 'app/edupay_app.dart';
import 'features/parent/domain/school_catalogue.dart';
export 'app/edupay_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeDateFormatting('fr_FR', null);
  } catch (_) {}
  // Best-effort : un projet Firebase mal configuré sur cet appareil ne doit
  // jamais empêcher l'app de démarrer, seulement priver l'utilisateur du push.
  try {
    await Firebase.initializeApp().timeout(const Duration(seconds: 3));
  } catch (_) {}
  // Catalogue officie l des classes/fournitures/prix (§ règle métier « Classe
  // en autocomplétion ») : chargé une seule fois avant le premier écran, pour
  // que toute résolution de kit soit synchrone ensuite.
  final catalogueJson = await rootBundle.loadString(
    'assets/data/school_catalogue.json',
  );
  SchoolCatalogue.loadFromJson(catalogueJson);
  runApp(const EduPayApp());
}
