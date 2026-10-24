import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';

/// Type of workspace tab. Mirrors the VS Code editor tabs: the dashboard is
/// the "welcome" tab, projects open one tab each.
enum WorkspaceTabType { dashboard, project }

class WorkspaceTab {
  final WorkspaceTabType type;
  final String? projectId;
  final String title;
  final String? projectKey;

  const WorkspaceTab._({
    required this.type,
    this.projectId,
    required this.title,
    this.projectKey,
  });

  const WorkspaceTab.dashboard()
      : this._(
          type: WorkspaceTabType.dashboard,
          title: 'Dashboard',
        );

  const WorkspaceTab.project({
    required String projectId,
    required String title,
    String? projectKey,
  }) : this._(
          type: WorkspaceTabType.project,
          projectId: projectId,
          title: title,
          projectKey: projectKey,
        );

  String get id =>
      type == WorkspaceTabType.dashboard ? 'dashboard' : 'project:$projectId';

  @override
  bool operator ==(Object other) => other is WorkspaceTab && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Routes that render inside a project tab (the project workspace).
final RegExp _projectListRoutePattern = RegExp(r'^/projects/([^/]+)/list$');

/// Extracts the project id from a project list route, or null.
String? projectIdFromRoute(String route) {
  final match = _projectListRoutePattern.firstMatch(route);
  return match?.group(1);
}

/// In-memory state of the open workspace tabs (one tab max per project,
/// plus the closable dashboard tab).
class WorkspaceTabsNotifier extends Notifier<List<WorkspaceTab>> {
  @override
  List<WorkspaceTab> build() => [];

  bool get isDashboardOpen =>
      state.any((t) => t.type == WorkspaceTabType.dashboard);

  WorkspaceTab? tabById(String id) {
    for (final tab in state) {
      if (tab.id == id) return tab;
    }
    return null;
  }

  WorkspaceTab? tabForProject(String projectId) {
    for (final tab in state) {
      if (tab.type == WorkspaceTabType.project && tab.projectId == projectId) {
        return tab;
      }
    }
    return null;
  }

  /// Opens the dashboard tab (idempotent). Returns the dashboard tab.
  WorkspaceTab openDashboard() {
    final existing = tabById('dashboard');
    if (existing != null) return existing;
    final tab = const WorkspaceTab.dashboard();
    state = [tab, ...state];
    return tab;
  }

  /// Opens a project tab. A project only ever appears in a single tab: if a
  /// tab already exists for it, its cached title is refreshed and returned.
  WorkspaceTab openProject({
    required String projectId,
    required String title,
    String? projectKey,
  }) {
    final index =
        state.indexWhere((t) => t.type == WorkspaceTabType.project && t.projectId == projectId);
    if (index != -1) {
      final existing = state[index];
      if (existing.title == title && existing.projectKey == projectKey) {
        return existing;
      }
      final updated = WorkspaceTab.project(
        projectId: projectId,
        title: title,
        projectKey: projectKey ?? existing.projectKey,
      );
      state = [...state]..[index] = updated;
      return updated;
    }
    final tab = WorkspaceTab.project(
      projectId: projectId,
      title: title,
      projectKey: projectKey,
    );
    state = [...state, tab];
    return tab;
  }

  /// Closes the tab with [id]. Returns the tab that should become active
  /// next (VS Code neighbour rule: tab to the left, else to the right),
  /// or null when no tab remains.
  WorkspaceTab? close(String id) {
    final index = state.indexWhere((t) => t.id == id);
    if (index == -1) return null;
    final next = [...state]..removeAt(index);
    state = next;
    if (next.isEmpty) return null;
    return next[(index - 1).clamp(0, next.length - 1)];
  }
}

final workspaceTabsProvider =
    NotifierProvider<WorkspaceTabsNotifier, List<WorkspaceTab>>(
  WorkspaceTabsNotifier.new,
);

/// Whether [tab] is the active tab given the current route and the selected
/// project. Auxiliary views (kanban, backlog, cycles) highlight the tab of
/// the project they are scoped to.
bool isWorkspaceTabActive(
  WorkspaceTab tab,
  String currentRoute,
  String? selectedProjectId,
) {
  if (tab.type == WorkspaceTabType.dashboard) {
    return currentRoute == '/dashboard';
  }
  if (projectIdFromRoute(currentRoute) == tab.projectId) return true;
  const projectScopedRoutes = ['/kanban', '/backlog', '/cycles'];
  return projectScopedRoutes.contains(currentRoute) &&
      selectedProjectId == tab.projectId;
}

/// Opens (or focuses) the dashboard tab and navigates to the dashboard.
void openDashboardTab(BuildContext context, WidgetRef ref) {
  ref.read(workspaceTabsProvider.notifier).openDashboard();
  context.go('/dashboard');
}

/// Opens (or focuses) the tab of [projectId] and navigates to its workspace.
/// The project becomes the selected project so scoped views follow the tab.
void openProjectTab(
  BuildContext context,
  WidgetRef ref, {
  required String projectId,
  String? title,
  String? projectKey,
}) {
  ref.read(workspaceTabsProvider.notifier).openProject(
        projectId: projectId,
        title: title ?? projectId,
        projectKey: projectKey,
      );
  ref.read(selectedProjectIdProvider.notifier).select(projectId);
  context.go('/projects/$projectId/list');
}

/// Navigates to the workspace of [tab] (used after activation or a close).
void navigateToTab(BuildContext context, WidgetRef ref, WorkspaceTab tab) {
  if (tab.type == WorkspaceTabType.dashboard) {
    context.go('/dashboard');
  } else if (tab.projectId != null) {
    ref.read(selectedProjectIdProvider.notifier).select(tab.projectId);
    context.go('/projects/${tab.projectId}/list');
  }
}
