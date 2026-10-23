import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/auth_state.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/setup_screen.dart';
import '../features/kanban/presentation/kanban_adaptive_screen.dart';
import '../features/projects/presentation/projects_adaptive_screen.dart';
import '../features/shell/presentation/adaptive_app_shell.dart';
import '../features/sprints/presentation/cycles_overview_screen.dart';
import '../features/tickets/presentation/my_tasks_view.dart';
import '../features/tickets/presentation/project_list_view.dart';
import '../features/tickets/presentation/ticket_detail_screen.dart';
import '../features/calendar/presentation/team_calendar_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/my-tasks',
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
        if (loc == '/login' || loc == '/setup' || loc == '/') return '/my-tasks';
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
            builder: (context, state) => const ProjectsAdaptiveScreen(
              showAllProjectsOverview: true,
            ),
          ),
          GoRoute(
            path: '/backlog',
            builder: (context, state) => const ProjectsAdaptiveScreen(
              showAllProjectsOverview: false,
            ),
          ),
          GoRoute(
            path: '/projects/:id/list',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return ProjectListView(projectId: id);
            },
          ),
          GoRoute(
            path: '/my-tasks',
            builder: (context, state) => const MyTasksView(),
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
