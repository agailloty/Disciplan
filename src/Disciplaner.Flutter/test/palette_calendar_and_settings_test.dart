import 'package:disciplaner_flutter/app/theme/neo_theme.dart';
import 'package:disciplaner_flutter/core/models/auth_models.dart';
import 'package:disciplaner_flutter/core/models/collaboration_models.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_state.dart';
import 'package:disciplaner_flutter/features/calendar/presentation/calendar_providers.dart';
import 'package:disciplaner_flutter/features/calendar/presentation/team_calendar_screen.dart';
import 'package:disciplaner_flutter/features/search/presentation/command_palette_modal.dart';
import 'package:disciplaner_flutter/features/settings/presentation/settings_providers.dart';
import 'package:disciplaner_flutter/features/settings/presentation/settings_screen.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/ticket_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:disciplaner_flutter/l10n/app_localizations.dart';

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

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

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

  final sampleAdminUser = AdminUserDto(
    id: 'user-1',
    displayName: 'Alexandre Admin',
    email: 'admin@disciplan.test',
    isActive: true,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    roles: const ['Admin', 'User'],
  );

  final sampleStandardUser = AdminUserDto(
    id: 'user-2',
    displayName: 'Sophie Dev',
    email: 'sophie@disciplan.test',
    isActive: true,
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
    roles: const ['User'],
  );

  final sampleInvitation = InvitationDto(
    id: 'inv-1',
    token: 'tok-7days-unique',
    email: 'nouveau@disciplan.test',
    invitedByUserId: 'user-1',
    createdAt: DateTime.now(),
    expiresAt: DateTime.now().add(const Duration(days: 7)),
    isUsed: false,
  );

  group('Command Palette (⌘K / Ctrl+K)', () {
    testWidgets('renders command palette overlay and filters results', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myTasksProvider.overrideWith(
              () => FakeMyTasksNotifier([sampleTicket]),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
            theme: NeoTheme.lightTheme,
            home: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: ElevatedButton(
                    onPressed: () => CommandPaletteModal.show(context),
                    child: const Text('Ouvrir la palette'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Ouvre la palette via showDialog, comme le raccourci Ctrl+K :
      // la route de dialogue ne fournit pas de Material ancestor,
      // c'est la régression « No Material widget found ».
      await tester.tap(find.text('Ouvrir la palette'));
      await tester.pumpAndSettle();

      // Search input and initial items should be visible
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Rechercher un ticket, une action ou naviguer...'), findsOneWidget);
      expect(find.text('ACTIONS RAPIDES'), findsOneWidget);
      expect(find.text('NAVIGATION'), findsOneWidget);

      // Filter by "sprint"
      await tester.enterText(find.byType(TextField), 'sprint');
      await tester.pumpAndSettle();

      expect(find.text('Créer un sprint'), findsOneWidget);

      // Keyboard navigation with ArrowDown
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Escape closes the palette
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
    });
  });

  group('Settings & Administration View', () {
    testWidgets('renders user profile, server config and admin management panel', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1000));

      final adminSession = AuthResponse(
        token: 'fake-jwt',
        email: 'admin@disciplan.test',
        displayName: 'Alexandre Admin',
        roles: const ['Admin', 'User'],
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith(
              () => FakeAuthNotifier(AuthAuthenticated(adminSession)),
            ),
            adminUsersListProvider.overrideWith(
              (ref) => Future.value([sampleAdminUser, sampleStandardUser]),
            ),
            adminInvitationsListProvider.overrideWith(
              (ref) => Future.value([sampleInvitation]),
            ),
            savedViewsListProvider.overrideWith(
              (ref) => Future.value([]),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
            theme: NeoTheme.lightTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Header and badge
      expect(find.text('Paramètres'), findsOneWidget);
      expect(find.text('Administrateur'), findsNWidgets(2));

      // User profile section
      expect(find.text('Profil & Compte'), findsOneWidget);
      expect(find.text('Alexandre Admin'), findsWidgets);
      expect(find.text('admin@disciplan.test'), findsWidgets);

      // Server Homelab section
      expect(find.text('Serveur Homelab'), findsOneWidget);

      // Administration section
      expect(find.text('Administration — Invitations (7 jours)'), findsOneWidget);
      expect(find.text('Administration — Gestion des Comptes'), findsOneWidget);
      expect(find.text('Sophie Dev'), findsOneWidget);
      expect(find.text('nouveau@disciplan.test'), findsOneWidget);
    });
  });

  group('Team Calendar Screen', () {
    testWidgets('renders monthly calendar header, filters and iCal sync button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            calendarTokenProvider.overrideWith(
              () => FakeCalendarTokenNotifier(
                CalendarTokenDto(
                  token: 'cal-token-12345',
                  createdAt: DateTime.now(),
                ),
              ),
            ),
            myTasksProvider.overrideWith(
              () => FakeMyTasksNotifier([sampleTicket]),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
            theme: NeoTheme.lightTheme,
            home: const TeamCalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Calendrier d\'Équipe'), findsOneWidget);
      expect(find.text('Synchronisation iCal / Agenda externe'), findsOneWidget);
      expect(find.text('Tout voir'), findsOneWidget);
      expect(find.text('Sprints'), findsOneWidget);
      expect(find.text('Tickets'), findsOneWidget);
    });
  });
}
