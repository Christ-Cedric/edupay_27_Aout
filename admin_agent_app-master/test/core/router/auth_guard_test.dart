import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import 'package:edupay_admin/core/router/auth_guard.dart';
import 'package:edupay_admin/core/router/route_paths.dart';
import 'package:edupay_admin/features/auth/domain/models/session.dart';
import 'package:edupay_admin/features/auth/domain/models/user_role.dart';

void main() {
  const adminSession = Session(
    userId: 'admin-1',
    displayName: 'DERRA Bassirou',
    phone: '+22676691911',
    role: UserRole.admin,
    token: 'tok',
  );

  const agentSession = Session(
    userId: 'agent-1',
    displayName: 'Konate Ali',
    phone: '+22670112233',
    role: UserRole.agent,
    token: 'tok',
  );

  test('reste sur /splash pendant le chargement initial', () {
    final redirect = authGuardRedirect(
      sessionState: const AsyncLoading<Session?>(),
      location: RoutePaths.splash,
    );
    expect(redirect, isNull);
  });

  test(
    'redirige vers /splash si une autre route est visée pendant le chargement',
    () {
      final redirect = authGuardRedirect(
        sessionState: const AsyncLoading<Session?>(),
        location: RoutePaths.adminDashboard,
      );
      expect(redirect, RoutePaths.splash);
    },
  );

  test('redirige de /splash vers /login une fois résolu sans session', () {
    final redirect = authGuardRedirect(
      sessionState: const AsyncData<Session?>(null),
      location: RoutePaths.splash,
    );
    expect(redirect, RoutePaths.login);
  });

  test('reste sur /login sans session', () {
    final redirect = authGuardRedirect(
      sessionState: const AsyncData<Session?>(null),
      location: RoutePaths.login,
    );
    expect(redirect, isNull);
  });

  test(
    'redirige un utilisateur authentifié loin de /login vers son dashboard',
    () {
      final redirect = authGuardRedirect(
        sessionState: const AsyncData<Session?>(adminSession),
        location: RoutePaths.login,
      );
      expect(redirect, RoutePaths.adminDashboard);
    },
  );

  test('laisse passer un utilisateur authentifié sur une route protégée', () {
    final redirect = authGuardRedirect(
      sessionState: const AsyncData<Session?>(adminSession),
      location: RoutePaths.adminDashboard,
    );
    expect(redirect, isNull);
  });

  test('la galerie de composants dev reste toujours accessible', () {
    final redirect = authGuardRedirect(
      sessionState: const AsyncData<Session?>(null),
      location: RoutePaths.devWidgetGallery,
    );
    expect(redirect, isNull);
  });

  test(
    'une session agent (persistance obsolète) est traitée comme non '
    'authentifiée : redirigée vers /login',
    () {
      final redirect = authGuardRedirect(
        sessionState: const AsyncData<Session?>(agentSession),
        location: RoutePaths.login,
      );
      expect(redirect, isNull);
    },
  );

  test(
    "une session agent (persistance obsolète) ne peut pas atteindre une "
    "route admin : redirigée vers /login",
    () {
      final redirect = authGuardRedirect(
        sessionState: const AsyncData<Session?>(agentSession),
        location: '${RoutePaths.adminSettings}/agents',
      );
      expect(redirect, RoutePaths.login);
    },
  );
}
