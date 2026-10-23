import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/auth_state.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/setup_screen.dart';
import '../features/shell/presentation/adaptive_app_shell.dart';
import '../features/shell/presentation/shell_placeholders.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/projects',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (authState is AuthNeedsInitialSetup) {
        if (loc != '/setup') return '/setup';
        return null;
      }
      if (authState is AuthUnauthenticated || authState is AuthUnconfiguredServer) {
        if (loc != '/login' && loc != '/setup') return '/login';
        return null;
      }
      if (authState is AuthAuthenticated) {
        if (loc == '/login' || loc == '/setup' || loc == '/') return '/projects';
        return null;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/setup',
        builder: (context, state) => const SetupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdaptiveAppShell(
          currentRoute: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/projects',
            builder: (context, state) => const ShellPlaceholderView(
              title: 'Explorateur de Projets',
              subtitle: 'Navigation dans les projets, sprints et statuts du workspace.',
              icon: Icons.folder_copy,
            ),
          ),
          GoRoute(
            path: '/my-tasks',
            builder: (context, state) => const ShellPlaceholderView(
              title: 'Mes Tâches',
              subtitle: 'Vue compacte des tickets assignés et rapportés.',
              icon: Icons.checklist,
            ),
          ),
          GoRoute(
            path: '/kanban',
            builder: (context, state) => const ShellPlaceholderView(
              title: 'Tableau Kanban',
              subtitle: 'Gestion visuelle en colonnes du sprint en cours.',
              icon: Icons.view_kanban,
            ),
          ),
          GoRoute(
            path: '/cycles',
            builder: (context, state) => const ShellPlaceholderView(
              title: 'Cycles & Sprints',
              subtitle: 'Planification temporelle et métriques de progression.',
              icon: Icons.timelapse,
            ),
          ),
          GoRoute(
            path: '/calendar',
            builder: (context, state) => const ShellPlaceholderView(
              title: 'Calendrier d\'Équipe',
              subtitle: 'Jalons de sprint et flux de synchronisation iCal.',
              icon: Icons.calendar_today,
            ),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const ShellPlaceholderView(
              title: 'Paramètres & Administration',
              subtitle: 'Configuration du profil, membres et serveur Homelab.',
              icon: Icons.settings,
            ),
          ),
        ],
      ),
    ],
  );
});
