import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/parent/presentation/parent_app_state.dart';
import '../features/parent/presentation/parent_scope.dart';
import 'config/app_dependencies.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class EduPayApp extends StatefulWidget {
  const EduPayApp({super.key});

  @override
  State<EduPayApp> createState() => _EduPayAppState();
}

class _EduPayAppState extends State<EduPayApp> {
  late final ParentAppState state;
  late final GoRouter _router;
  StreamSubscription<RemoteMessage>? _foregroundMessageSub;

  @override
  void initState() {
    super.initState();
    final services = AppDependencies.create();
    state = ParentAppState(
      services.parentRepository,
      authSession: services.authSession,
      fcmService: services.fcmService,
    );
    // Le routeur est créé UNE seule fois (il écoute déjà `state` via
    // refreshListenable) : le recréer à chaque rebuild perdrait la navigation.
    _router = AppRouter.create(state);
    // Premier plan uniquement (arrière-plan/fermé : le système affiche déjà
    // la notification FCM) — rafraîchit le fil réel plutôt que d'afficher le
    // payload push directement, l'entrée est de toute façon déjà persistée
    // côté serveur au moment où le push part (voir `notifications.service.ts`).
    _foregroundMessageSub = FirebaseMessaging.onMessage.listen((_) {
      state.loadNotifications();
    });
  }

  @override
  void dispose() {
    _foregroundMessageSub?.cancel();
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ParentScope(
      state: state,
      // Rebuild de MaterialApp au changement de thème (themeMode), sans
      // reconstruire le routeur.
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) => MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'EduP@y Parent',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: state.themeMode,
          // Fond enchaîné en douceur d'un mode à l'autre (cf. AppPalette.lerp).
          themeAnimationDuration: const Duration(milliseconds: 350),
          themeAnimationCurve: Curves.easeInOut,
          routerConfig: _router,
        ),
      ),
    );
  }
}
