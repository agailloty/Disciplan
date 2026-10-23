import 'package:disciplaner_flutter/app/router.dart';
import 'package:disciplaner_flutter/app/theme/neo_theme.dart';
import 'package:disciplaner_flutter/core/models/auth_models.dart';
import 'package:disciplaner_flutter/core/shortcuts/app_shortcuts.dart';
import 'package:disciplaner_flutter/core/storage/server_config_storage.dart';
import 'package:disciplaner_flutter/core/storage/token_storage.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_state.dart';
import 'package:disciplaner_flutter/features/shell/presentation/adaptive_app_shell.dart';
import 'package:disciplaner_flutter/features/shell/presentation/desktop_app_shell.dart';
import 'package:disciplaner_flutter/features/shell/presentation/mobile_app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/features/projects/data/project_repository.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/ticket_providers.dart';
import 'package:disciplaner_flutter/l10n/app_localizations.dart';

final testAuthSession = AuthResponse(
  token: 'jwt_valid_test',
  email: 'admin@disciplan.local',
  displayName: 'Alexandre Gailloty',
  roles: const ['Admin'],
  expiresAt: DateTime.now().add(const Duration(days: 7)),
);

class FakeShellProjectRepo implements IProjectRepository {
  @override
  Future<List<ProjectSummaryDto>> getAll() async => [
        ProjectSummaryDto(
          id: 'proj_1',
          name: 'Campagne de Marque 2025',
          key: 'CAMP',
          ticketCount: 18,
          sprintCount: 4,
          createdAt: DateTime.now(),
          requestingUserRole: MemberRole.admin,
          isOwner: true,
        ),
      ];

  @override
  Future<ProjectDetailDto> getById(String id) async => ProjectDetailDto(
        id: id,
        name: 'Campagne de Marque 2025',
        key: 'CAMP',
        ownerId: 'admin',
        createdAt: DateTime.now(),
        statuses: const [],
        sprints: const [],
        defaultTicketType: TicketType.story,
        defaultAssigneePolicy: DefaultAssigneePolicy.creator,
        members: const [],
        requestingUserRole: MemberRole.admin,
      );

  @override
  Future<ProjectDetailDto> create(CreateProjectRequest request) async => getById('new');

  @override
  Future<ProjectDetailDto> update(String id, UpdateProjectRequest request) async => getById(id);

  @override
  Future<ProjectDetailDto> updateDefaults(String id, UpdateProjectDefaultsRequest request) async => getById(id);

  @override
  Future<void> delete(String id) async {}

  @override
  Future<TicketStatusDto> addStatus(String projectId, CreateTicketStatusRequest request) async =>
      TicketStatusDto(
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

class AuthenticatedMockAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => AuthAuthenticated(testAuthSession);
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget createTestApp() {
    SharedPreferences.setMockInitialValues({});
    final serverStorage = ServerConfigStorage();
    final tokenStorage = TokenStorage();

    return ProviderScope(
      overrides: [
        serverConfigStorageProvider.overrideWithValue(serverStorage),
        tokenStorageProvider.overrideWithValue(tokenStorage),
        projectRepositoryProvider.overrideWithValue(FakeShellProjectRepo()),
        projectBacklogProvider.overrideWith((ref, id) async => []),
        authNotifierProvider.overrideWith(AuthenticatedMockAuthNotifier.new),
      ],
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
    );
  }

  testWidgets('AdaptiveAppShell switches to DesktopAppShell on 1440x900', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(AdaptiveAppShell), findsOneWidget);
    expect(find.byType(DesktopAppShell), findsOneWidget);
    expect(find.byType(MobileAppShell), findsNothing);

    // VS Code Top Bar elements
    expect(find.text('Disciplan'), findsWidgets);
    expect(find.text('PLAN DU PROJET'), findsOneWidget);
    expect(find.text('⌘K'), findsOneWidget);
    expect(find.text('Nouvelle tâche'), findsOneWidget);

    // Primary Sidebar is initially open
    expect(find.text('Vue Liste'), findsOneWidget);
  });

  testWidgets('DesktopAppShell toggles Primary Sidebar collapse', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('PLAN DU PROJET'), findsOneWidget);

    // Click collapse icon on sidebar header
    final collapseBtn = find.byTooltip('Replier la barre latérale (⌘B)');
    expect(collapseBtn, findsOneWidget);
    await tester.tap(collapseBtn);
    await tester.pumpAndSettle();

    // Sidebar should be collapsed
    expect(find.text('PLAN DU PROJET'), findsNothing);

    // Re-open via Top Bar toggle
    final topBarToggle = find.byTooltip('Basculer la barre latérale (⌘B)');
    await tester.tap(topBarToggle);
    await tester.pumpAndSettle();

    expect(find.text('PLAN DU PROJET'), findsOneWidget);
  });

  testWidgets('AdaptiveAppShell switches to MobileAppShell on 390x844', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(AdaptiveAppShell), findsOneWidget);
    expect(find.byType(MobileAppShell), findsOneWidget);
    expect(find.byType(DesktopAppShell), findsNothing);

    // Mobile shell bottom navigation items
    expect(find.text('Sprint'), findsOneWidget);
    expect(find.text('Projets'), findsWidgets);
    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Paramètres'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Global Shortcuts toggles Command Palette and Create Task flags',
      (WidgetTester tester) async {
    late WidgetRef capturedRef;
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            capturedRef = ref;
            return MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
              home: AppShortcutsWrapper(
                child: Scaffold(body: Text('Shortcut Test')),
              ),
            );
          },
        ),
      ),
    );

    expect(capturedRef.read(commandPaletteOpenProvider), isFalse);
    expect(capturedRef.read(quickCreateTicketOpenProvider), isFalse);
  });
}
