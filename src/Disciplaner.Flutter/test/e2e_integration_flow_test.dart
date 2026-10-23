import 'package:disciplaner_flutter/app/theme/neo_theme.dart';
import 'package:disciplaner_flutter/core/models/auth_models.dart';
import 'package:disciplaner_flutter/core/models/collaboration_models.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_state.dart';
import 'package:disciplaner_flutter/features/calendar/presentation/calendar_providers.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';
import 'package:disciplaner_flutter/features/search/presentation/command_palette_modal.dart';
import 'package:disciplaner_flutter/features/shell/presentation/adaptive_app_shell.dart';
import 'package:disciplaner_flutter/features/shell/presentation/desktop_app_shell.dart';
import 'package:disciplaner_flutter/features/shell/presentation/mobile_app_shell.dart';
import 'package:disciplaner_flutter/features/sprints/presentation/sprint_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/ticket_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/desktop_create_ticket_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class FakeMyTasksNotifier extends MyTasksNotifier {
  final List<TicketDto> tickets;
  FakeMyTasksNotifier(this.tickets);

  @override
  Future<List<TicketDto>> build() async => tickets;
}

class FakeCalendarTokenNotifier extends CalendarTokenNotifier {
  final CalendarTokenDto? tokenDto;
  FakeCalendarTokenNotifier(this.tokenDto);

  @override
  Future<CalendarTokenDto?> build() async => tokenDto;
}

class FakeAuthNotifier extends AuthNotifier {
  final AuthState initial;
  FakeAuthNotifier(this.initial);

  @override
  AuthState build() => initial;
}

class FakeSelectedProjectIdNotifier extends SelectedProjectIdNotifier {
  final String? initialId;
  FakeSelectedProjectIdNotifier(this.initialId);

  @override
  String? build() => initialId;
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final sampleProject = ProjectSummaryDto(
    id: 'proj-1',
    name: 'Campagne Neo-Linear',
    key: 'DISC',
    description: 'Migration multiplateforme Disciplan',
    ticketCount: 12,
    sprintCount: 3,
    createdAt: DateTime.now(),
    requestingUserRole: MemberRole.admin,
    isOwner: true,
  );

  final sampleProjectDetail = ProjectDetailDto(
    id: 'proj-1',
    name: 'Campagne Neo-Linear',
    key: 'DISC',
    description: 'Migration multiplateforme Disciplan',
    ownerId: 'user-1',
    createdAt: DateTime.now(),
    statuses: const [],
    sprints: const [],
    defaultTicketType: TicketType.task,
    defaultAssigneePolicy: DefaultAssigneePolicy.none,
    members: const [],
    requestingUserRole: MemberRole.admin,
  );

  final sampleTicket = TicketDto(
    id: 'ticket-14',
    projectId: 'proj-1',
    projectKey: 'DISC',
    ticketNumber: 14,
    ticketRef: 'DISC-14',
    title: 'Déclinaison affichage urbain 4x3 & abribus',
    description: 'Campagne média estivale',
    type: TicketType.task,
    priority: CardPriority.high,
    storyPoints: 5,
    dueDate: DateTime.now().add(const Duration(days: 3)),
    status: const TicketStatusDto(
      id: 'status-1',
      projectId: 'proj-1',
      name: 'En cours',
      color: '#F59E0B',
      order: 1,
      category: StatusCategory.inProgress,
    ),
    reporterId: 'user-1',
    reporterName: 'Alexandre M.',
    assigneeId: 'user-1',
    assigneeName: 'Alexandre M.',
    createdAt: DateTime.now(),
    labels: const [],
  );

  final testSession = AuthResponse(
    token: 'jwt-e2e-valid-token',
    email: 'admin@disciplan.test',
    displayName: 'Alexandre M.',
    roles: const ['Admin', 'User'],
    expiresAt: DateTime.now().add(const Duration(days: 7)),
  );

  group('Multiplatform Responsive Breakpoints Verification', () {
    testWidgets('360x780 Mobile layout renders MobileAppShell with navigation bar and no overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 780));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith(
              () => FakeAuthNotifier(AuthAuthenticated(testSession)),
            ),
            projectsListProvider.overrideWith(
              (ref) => Future.value([sampleProject]),
            ),
            selectedProjectIdProvider.overrideWith(
              () => FakeSelectedProjectIdNotifier('proj-1'),
            ),
            myTasksProvider.overrideWith(
              () => FakeMyTasksNotifier([sampleTicket]),
            ),
          ],
          child: MaterialApp(
            theme: NeoTheme.lightTheme,
            home: const AdaptiveAppShell(
              currentRoute: '/projects',
              child: Scaffold(body: Center(child: Text('Mobile Content'))),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MobileAppShell), findsOneWidget);
      expect(find.byType(DesktopAppShell), findsNothing);
      expect(find.text('Tâches'), findsOneWidget);
      expect(find.text('Mobile Content'), findsOneWidget);
    });

    testWidgets('768x1024 Tablet layout adapts gracefully without layout overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(768, 1024));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith(
              () => FakeAuthNotifier(AuthAuthenticated(testSession)),
            ),
            projectsListProvider.overrideWith(
              (ref) => Future.value([sampleProject]),
            ),
            selectedProjectIdProvider.overrideWith(
              () => FakeSelectedProjectIdNotifier('proj-1'),
            ),
          ],
          child: MaterialApp(
            theme: NeoTheme.lightTheme,
            home: const AdaptiveAppShell(
              currentRoute: '/projects',
              child: Scaffold(body: Center(child: Text('Tablet Content'))),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MobileAppShell), findsOneWidget);
      expect(find.text('Tablet Content'), findsOneWidget);
    });

    testWidgets('1920x1080 Desktop large layout renders full Activity Bar and Primary Sidebar', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith(
              () => FakeAuthNotifier(AuthAuthenticated(testSession)),
            ),
            projectsListProvider.overrideWith(
              (ref) => Future.value([sampleProject]),
            ),
            selectedProjectIdProvider.overrideWith(
              () => FakeSelectedProjectIdNotifier('proj-1'),
            ),
            currentProjectDetailProvider.overrideWith(
              (ref) => Future.value(sampleProjectDetail),
            ),
            myTasksProvider.overrideWith(
              () => FakeMyTasksNotifier([sampleTicket]),
            ),
          ],
          child: MaterialApp(
            theme: NeoTheme.lightTheme,
            home: const AdaptiveAppShell(
              currentRoute: '/projects',
              child: Scaffold(body: Center(child: Text('Desktop Large Content'))),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(DesktopAppShell), findsOneWidget);
      expect(find.byType(MobileAppShell), findsNothing);
      expect(find.text('Campagne Neo-Linear'), findsWidgets);
      expect(find.text('Nouvelle tâche'), findsOneWidget);
      expect(find.text('Desktop Large Content'), findsOneWidget);
    });
  });

  group('E2E Interaction: Ticket Creation Modal & Command Palette', () {
    testWidgets('opens DesktopCreateTicketDialog and fills ticket properties', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith(
              () => FakeAuthNotifier(AuthAuthenticated(testSession)),
            ),
            projectsListProvider.overrideWith(
              (ref) => Future.value([sampleProject]),
            ),
            selectedProjectIdProvider.overrideWith(
              () => FakeSelectedProjectIdNotifier('proj-1'),
            ),
            currentProjectDetailProvider.overrideWith(
              (ref) => Future.value(sampleProjectDetail),
            ),
            projectSprintsProvider('proj-1').overrideWith(
              (ref) => Future.value([]),
            ),
          ],
          child: MaterialApp(
            theme: NeoTheme.lightTheme,
            home: const Scaffold(
              body: DesktopCreateTicketDialog(initialProjectId: 'proj-1'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Nouvelle tâche'), findsOneWidget);
      expect(find.text('Créer la tâche'), findsOneWidget);
      expect(find.text('Créer une autre tâche'), findsOneWidget);

      final titleField = find.widgetWithText(TextField, 'Titre de la tâche...');
      expect(titleField, findsOneWidget);

      await tester.enterText(titleField, 'Intégration du système de notification');
      await tester.pump();

      expect(find.text('Intégration du système de notification'), findsOneWidget);
    });

    testWidgets('renders Command Palette modal and executes search filter', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myTasksProvider.overrideWith(
              () => FakeMyTasksNotifier([sampleTicket]),
            ),
          ],
          child: MaterialApp(
            theme: NeoTheme.lightTheme,
            home: const Scaffold(
              body: CommandPaletteModal(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Rechercher un ticket, une action ou naviguer...'), findsOneWidget);
      expect(find.text('ACTIONS RAPIDES'), findsOneWidget);
      expect(find.text('NAVIGATION'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'DISC-14');
      await tester.pumpAndSettle();

      expect(find.text('DISC-14'), findsWidgets);
      expect(find.text('Déclinaison affichage urbain 4x3 & abribus'), findsOneWidget);
    });
  });
}
