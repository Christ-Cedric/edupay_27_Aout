// =============================================================================
// MAIN.DART — Point d'entrée avec Providers et auth guard
// =============================================================================
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/agent_provider.dart';
import 'features/agent/screens/ag_login_screen.dart';
import 'features/agent/screens/ag_dashboard_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Best-effort : un projet Firebase mal configuré sur cet appareil ne doit
  // jamais empêcher l'app de démarrer, seulement priver l'agent du push.
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  await initializeDateFormatting('fr_FR', null);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AgentProvider()),
      ],
      child: const EduPayApp(),
    ),
  );
}

class EduPayApp extends StatelessWidget {
  const EduPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduP@y — Agent Terrain',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const _AuthGate(),
    );
  }
}

/// Auth gate: vérifie si l'utilisateur est connecté et redirige
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  StreamSubscription<RemoteMessage>? _foregroundMessageSub;

  @override
  void initState() {
    super.initState();
    // Vérifier le statut d'authentification au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuthStatus();
    });
    // Premier plan uniquement (arrière-plan/fermé : le système affiche déjà
    // la notification FCM) — rafraîchit l'inbox réelle, déjà persistée côté
    // serveur au moment où le push part.
    _foregroundMessageSub = FirebaseMessaging.onMessage.listen((_) {
      if (!mounted) return;
      context.read<AgentProvider>().loadMyNotifications();
    });
  }

  @override
  void dispose() {
    _foregroundMessageSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.unknown:
        return const _SplashScreen();
      case AuthStatus.authenticated:
        return const AgDashboardScreen();
      case AuthStatus.unauthenticated:
        return const AgLoginScreen();
    }
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: CircularProgressIndicator(color: AppColors.green),
      ),
    );
  }
}