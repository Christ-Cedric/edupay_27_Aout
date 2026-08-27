import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/config/app_environment.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/notifications/presentation/providers/notifications_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Best-effort : un projet Firebase mal configuré sur cet appareil ne doit
  // jamais empêcher l'app de démarrer, seulement priver l'admin du push.
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  await initializeDateFormatting('fr_FR');
  runApp(const ProviderScope(child: EduPayAdminApp()));
}

class EduPayAdminApp extends ConsumerStatefulWidget {
  const EduPayAdminApp({super.key});

  @override
  ConsumerState<EduPayAdminApp> createState() => _EduPayAdminAppState();
}

class _EduPayAdminAppState extends ConsumerState<EduPayAdminApp> {
  StreamSubscription<RemoteMessage>? _foregroundMessageSub;

  @override
  void initState() {
    super.initState();
    // Premier plan uniquement (arrière-plan/fermé : le système affiche déjà
    // la notification FCM) — rafraîchit l'inbox réelle, déjà persistée côté
    // serveur au moment où le push part.
    _foregroundMessageSub = FirebaseMessaging.onMessage.listen((_) {
      ref.invalidate(notificationsListProvider);
    });
  }

  @override
  void dispose() {
    _foregroundMessageSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'EduP@y Admin',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
      // Bandeau permanent (y compris en release) tant que l'app tourne sur
      // les FakeDataSource en mémoire — sans backend réel, `APP_ENV` par
      // défaut. Évite qu'un build oublié sans `--dart-define=APP_ENV=...`
      // (démo, TestFlight) paraisse fonctionnel sans jamais parler au serveur.
      builder: (context, child) {
        if (!AppEnvironmentConfig.usesMockData || child == null)
          return child ?? const SizedBox.shrink();
        return Banner(
          message: 'MODE DÉMO',
          location: BannerLocation.topEnd,
          color: Colors.redAccent,
          child: child,
        );
      },
    );
  }
}
