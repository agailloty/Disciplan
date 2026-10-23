import 'package:disciplaner_flutter/app/router.dart';
import 'package:disciplaner_flutter/app/theme/neo_theme.dart';
import 'package:disciplaner_flutter/core/models/auth_models.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/core/storage/server_config_storage.dart';
import 'package:disciplaner_flutter/core/storage/token_storage.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_state.dart';
import 'package:disciplaner_flutter/features/dashboard/presentation/dashboard_providers.dart';
import 'package:disciplaner_flutter/features/dashboard/presentation/dashboard_screen.dart';
import 'package:disciplaner_flutter/features/projects/data/project_repository.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';
import 'package:disciplaner_flutter/features/shell/presentation/desktop_app_shell.dart';
import 'package:disciplaner_flutter/features/shell/presentation/shell_placeholders.dart';
import 'package:disciplaner_flutter/features/shell/presentation/workspace_tabs.dart';
import 'package:disciplaner_flutter/features/sprints/presentation/sprint_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/ticket_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:disciplaner_flutter/l10n/app_localizations.dart';

final testSession = AuthResponse(
  token: 'jwt_tabs_test',
  email: 'admin@disciplan.local',
  displayName: 'Alexandre Gailloty',
  roles: const ['Admin'],
  expiresAt: DateTime.now().add(const Duration(days: 7)),
);

final project1 = ProjectSummaryDto(
  id: 'proj_1',
  name: 'Campagne de Marque 2025',
  description: 'Refonte complète de la marque',
  key: 'CAMP',
  ticketCount: 18,
  sprintCount: 4,
  createdAt: DateTime.now(),
  requestingUserRole: MemberRole.admin,
  isOwner: true,
);

final project2 = ProjectSummaryDto(
  id: 'proj_2',
  name: 'Migration Disciplan',
  description: 'Portage multiplateforme Flutter',
  key: 'DISC',
  ticketCount: 42,
  sprintCount: 7,
  createdAt: DateTime.now(),
  requestingUserRole: MemberRole.member,
  isOwner: false,
);

TicketDto buildTicket(
  String id,
  int number,
  String title,
  StatusCategory category,
) {
  return TicketDto(
    id: id,
    projectId: 'proj_1',
    projectKey: 'DISC',
    ticketNumber: number,
    ticketRef: 'DISC-$number',
    title: title,
    type: TicketType.task,
    priority: CardPriority.medium,
    status: TicketStatusDto(
      id: 'status-$category',
      projectId: 'proj_1',
      name: category.name,
      color: '#9CA3AF',
      order: category.value,
      category: category,
    ),
    reporterId: 'user-1',
    reporterName: 'Alexandre Gailloty',
    assigneeId: 'user-1',
    assigneeName: 'Alexandre Gailloty',
    createdAt: DateTime.now(),
    labels: const [],
  );
}

final todoTicket = buildTicket('t-1', 1, 'Rédiger le brief créatif', StatusCategory.backlog);
final inProgressTicket = buildTicket('t-2', 2, 'Préparer la revue de sprint', StatusCategory.inProgress);
final doneTicket = buildTicket('t-3', 3, 'Archiver la campagne précédente', StatusCategory.done);

class FakeDashboardProjectRepo implements IProjectRepository {
  @override
  Future<List<ProjectSummaryDto>> getAll() async => [project1, project2];

  ProjectDetailDto _detail(ProjectSummaryDto p) => ProjectDetailDto(
        id: p.id,
        name: p.name,
        description: p.description,
        key: p.key,
        ownerId: 'admin',
        createdAt: DateTime.now(),
        statuses: const [],
        sprints: const [],
        defaultTicketType: TicketType.task,
        defaultAssigneePolicy: DefaultAssigneePolicy.none,
        members: const [],
        requestingUserRole: p.requestingUserRole,
      );

  @override
  Future<ProjectDetailDto> getById(String id) async {
    final match = [project1, project2].where((p) => p.id == id).firstOrNull;
    return _detail(match ?? project1);
  }

  @override
  Future<ProjectDetailDto> create(CreateProjectRequest request) async => getById('new');

  @override
  Future<ProjectDetailDto> update(String id, UpdateProjectRequest request) async => getById(id);

  @override
  Future<ProjectDetailDto> updateDefaults(String id, UpdateProjectDefaultsRequest request) async => getById(id);

  @override
  Future<void> delete(String id) async {}

  @override
  Future<TicketStatusDto> addStatus(String projectId, CreateTicketStatusRequest request) async => TicketStatusDto(
        id: 'stat',
        projectId: projectId,
        name: request.name,
        color: request.color,
        order: 0,
        category: request.category,
      );

  @override
  Future<TicketStatusDto> updateStatus(
          String projectId, String statusId, UpdateTicketStatusRequest request) async =>
      TicketStatusDto(
        id: statusId,
        projectId: projectId,
        name: request.name,
        color: request.color,
        order: 0,
        category: request.category,
      );

  @override
  Future<void> deleteStatus(String projectId, String statusId) async {}

  @override
  Future<List<MemberDto>> getMembers(String projectId) async => const [];

  @override
  Future<MemberDto> addMember(String projectId, AddMemberRequest request) async => MemberDto(
        userId: request.userId,
        displayName: 'User',
        email: 'user@test.com',
        role: request.role,
        joinedAt: DateTime.now(),
      );

  @override
  Future<MemberDto> updateMemberRole(
          String projectId, String userId, UpdateMemberRoleRequest request) async =>
      MemberDto(
        userId: userId,
        displayName: 'User',
        email: 'user@test.com',
        role: request.role,
        joinedAt: DateTime.now(),
      );

  @override
  Future<void> removeMember(String projectId, String userId) async {}
}

class FakeMyTasksNotifier extends MyTasksNotifier {
  final List<TicketDto> tickets;
  FakeMyTasksNotifier(this.tickets);

  @override
  Future<List<TicketDto>> build() async => tickets;
}

class AuthenticatedMockAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => AuthAuthenticated(testSession);
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpApp(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    container = ProviderContainer(
      overrides: [
        serverConfigStorageProvider.overrideWithValue(ServerConfigStorage()),
        tokenStorageProvider.overrideWithValue(TokenStorage()),
        projectRepositoryProvider.overrideWithValue(FakeDashboardProjectRepo()),
        projectBacklogProvider.overrideWith((ref, id) async => []),
        projectSprintsProvider.overrideWith((ref, id) async => []),
        sprintTicketsProvider.overrideWith((ref, id) async => []),
        myTasksProvider.overrideWith(
          () => FakeMyTasksNotifier([todoTicket, inProgressTicket, doneTicket]),
        ),
        authNotifierProvider.overrideWith(AuthenticatedMockAuthNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) {
            final router = ref.watch(routerProvider);
            return MaterialApp.router(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('fr'),
              theme: NeoTheme.lightTheme,
              routerConfig: router,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Dashboard opens at launch with project cards and filtered my-tickets list',
      (WidgetTester tester) async {
    await pumpApp(tester, const Size(1440, 900));

    // The dashboard is the initial workspace.
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Bonjour Alexandre Gailloty'), findsOneWidget);
    expect(find.text('Campagne de Marque 2025'), findsWidgets);
    expect(find.text('Migration Disciplan'), findsWidgets);

    // One rectangle per project.
    expect(find.text('42 tickets • 7 sprints • Membre'), findsOneWidget);

    // My tickets section only shows the configured statuses (To Do + In Progress).
    expect(find.text('Mes tickets'), findsOneWidget);
    expect(find.text('Rédiger le brief créatif'), findsOneWidget);
    expect(find.text('Préparer la revue de sprint'), findsOneWidget);
    expect(find.text('Archiver la campagne précédente'), findsNothing);

    // The dashboard tab is open and active at launch.
    final tabs = container.read(workspaceTabsProvider);
    expect(tabs.length, 1);
    expect(tabs.first.type, WorkspaceTabType.dashboard);
  });

  testWidgets('Opening projects creates one unique tab per project', (WidgetTester tester) async {
    await pumpApp(tester, const Size(1440, 900));

    // Open the first project from its dashboard card.
    await tester.tap(find.descendant(
      of: find.byType(DashboardScreen),
      matching: find.text('Campagne de Marque 2025'),
    ));
    await tester.pumpAndSettle();

    var tabs = container.read(workspaceTabsProvider);
    expect(tabs.length, 2, reason: 'dashboard + project tab');
    expect(tabs.where((t) => t.projectId == 'proj_1').length, 1);

    // Go back to the dashboard and open the second project.
    await tester.tap(find.byTooltip('Tableau de bord'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
      of: find.byType(DashboardScreen),
      matching: find.text('Migration Disciplan'),
    ));
    await tester.pumpAndSettle();

    tabs = container.read(workspaceTabsProvider);
    expect(tabs.length, 3, reason: 'dashboard + two project tabs');
    expect(tabs.where((t) => t.projectId == 'proj_2').length, 1);

    // Reopening the first project must reuse its existing tab.
    await tester.tap(find.byTooltip('Tableau de bord'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
      of: find.byType(DashboardScreen),
      matching: find.text('Campagne de Marque 2025'),
    ));
    await tester.pumpAndSettle();

    tabs = container.read(workspaceTabsProvider);
    expect(tabs.length, 3, reason: 'no duplicate tab for the same project');
    expect(tabs.where((t) => t.projectId == 'proj_1').length, 1);
  });

  testWidgets('Closing the dashboard tab shows the welcome view, sidebar reopens it',
      (WidgetTester tester) async {
    await pumpApp(tester, const Size(1440, 900));

    // Close the active dashboard tab.
    final closeBtn = find.byTooltip('Fermer l\'onglet');
    expect(closeBtn, findsOneWidget);
    await tester.tap(closeBtn);
    await tester.pumpAndSettle();

    expect(container.read(workspaceTabsProvider), isEmpty);
    expect(find.byType(WorkspaceWelcomeView), findsOneWidget);
    expect(find.byType(DashboardScreen), findsNothing);

    // Reopen it from the activity bar / sidebar.
    await tester.tap(find.byTooltip('Tableau de bord'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
    final tabs = container.read(workspaceTabsProvider);
    expect(tabs.length, 1);
    expect(tabs.first.type, WorkspaceTabType.dashboard);
  });

  testWidgets('Closing a project tab activates the neighbour tab', (WidgetTester tester) async {
    await pumpApp(tester, const Size(1440, 900));

    // Open the first project, then the second from the dashboard.
    await tester.tap(find.descendant(
      of: find.byType(DashboardScreen),
      matching: find.text('Campagne de Marque 2025'),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tableau de bord'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
      of: find.byType(DashboardScreen),
      matching: find.text('Migration Disciplan'),
    ));
    await tester.pumpAndSettle();

    expect(container.read(workspaceTabsProvider).length, 3);

    // Close the active project tab: the neighbour (first project) becomes active.
    await tester.tap(find.byTooltip('Fermer l\'onglet'));
    await tester.pumpAndSettle();

    final tabs = container.read(workspaceTabsProvider);
    expect(tabs.length, 2);
    expect(tabs.where((t) => t.projectId == 'proj_1').length, 1,
        reason: 'the neighbour project tab stays open');
  });

  testWidgets('Configured statuses filter the my-tickets section', (WidgetTester tester) async {
    await pumpApp(tester, const Size(1440, 900));

    // Default configuration: To Do + In Progress.
    expect(container.read(dashboardStatusFilterProvider),
        {StatusCategory.backlog, StatusCategory.inProgress});
    expect(find.text('Archiver la campagne précédente'), findsNothing);

    // Enable the Done category through the status filter popup.
    await tester.tap(find.text('Statuts affichés'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terminé').last);
    await tester.pumpAndSettle();

    expect(container.read(dashboardStatusFilterProvider).contains(StatusCategory.done), isTrue);
    expect(find.text('Archiver la campagne précédente'), findsOneWidget);
  });

  testWidgets('Mobile dashboard renders stacked cards and ticket rows', (WidgetTester tester) async {
    await pumpApp(tester, const Size(390, 844));

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Campagne de Marque 2025'), findsOneWidget);
    expect(find.text('Migration Disciplan'), findsOneWidget);
    expect(find.text('Rédiger le brief créatif'), findsOneWidget);
    expect(find.text('Archiver la campagne précédente'), findsNothing);

    // No tab strip on mobile.
    expect(find.byType(DesktopAppShell), findsNothing);
  });
}
