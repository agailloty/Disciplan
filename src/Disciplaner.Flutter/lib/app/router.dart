import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/auth_state.dart';
import '../features/auth/presentation/landing_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/setup_screen.dart';
import '../features/auth/presentation/setup_server_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/kanban/presentation/kanban_adaptive_screen.dart';
import '../features/projects/presentation/projects_adaptive_screen.dart';
import '../features/shell/presentation/adaptive_app_shell.dart';
import '../features/shell/presentation/shell_placeholders.dart';
import '../features/sprints/presentation/cycles_overview_screen.dart';
import '../features/tickets/presentation/project_list_view.dart';
import '../features/tickets/presentation/ticket_detail_screen.dart';
import '../features/calendar/presentation/team_calendar_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

/// Déclenche la réévaluation de la redirection du GoRouter quand l'état
/// d'authentification change, sans recréer le routeur (une recréation
/// réinitialiserait la navigation à '/' et renverrait l'utilisateur sur la
/// page de présentation au milieu d'une connexion).
class AuthRefreshListenable extends ChangeNotifier {
  AuthRefreshListenable(Ref ref) {
    ref.listen<AuthState>(authNotifierProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = AuthRefreshListenable(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final loc = state.matchedLocation;
      // Page publique isolée : aucun état d'authentification requis.
      if (loc == '/setup-server') return null;
      if (authState is AuthNeedsInitialSetup) {
        // La page d'accueil reste visible ; seule l'installation crée le
        // premier compte administrateur.
        if (loc != '/' && loc != '/setup') return '/setup';
        return null;
      }
      if (authState is AuthUnauthenticated || authState is AuthUnconfiguredServer) {
        // La page d'accueil, la connexion et l'installation restent publiques.
        if (loc != '/' && loc != '/login' && loc != '/setup') return '/';
        return null;
      }
      if (authState is AuthAuthenticated) {
        if (loc == '/' || loc == '/login' || loc == '/setup') return '/dashboard';
        return null;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SelectionArea(child: LandingScreen()),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const SelectionArea(child: LoginScreen()),
      ),
      GoRoute(
        path: '/setup',
        builder: (context, state) => const SelectionArea(child: SetupScreen()),
      ),
      GoRoute(
        path: '/setup-server',
        builder: (context, state) => const SelectionArea(child: SetupServerScreen()),
      ),
      ShellRoute(
        builder: (context, state, child) => AdaptiveAppShell(
          currentRoute: state.matchedLocation,
          // Autorise la sélection puis la copie (Ctrl+C / clic droit) du
          // texte des écrans authentifiés. Le SelectionArea doit se
          // trouver sous le Navigator pour disposer de l'Overlay du menu
          // contextuel.
          child: SelectionArea(child: child),
        ),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/welcome',
            builder: (context, state) => const WorkspaceWelcomeView(),
          ),
          GoRoute(
            path: '/backlog',
            builder: (context, state) => const ProjectsAdaptiveScreen(),
          ),
          GoRoute(
            path: '/projects/:id/list',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return ProjectListView(projectId: id);
            },
          ),
          GoRoute(
            path: '/kanban',
            builder: (context, state) => const KanbanAdaptiveScreen(),
          ),
          GoRoute(
            path: '/cycles',
            builder: (context, state) => const CyclesOverviewScreen(),
          ),
          GoRoute(
            path: '/tickets/:ref',
            builder: (context, state) {
              final ref = state.pathParameters['ref'] ?? '';
              return TicketDetailScreen(ticketRef: ref);
            },
          ),
          GoRoute(
            path: '/calendar',
            builder: (context, state) => const TeamCalendarScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
