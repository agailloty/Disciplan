import 'package:disciplaner_flutter/core/errors/app_failure.dart';
import 'package:disciplaner_flutter/core/models/auth_models.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/core/models/sprint_models.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/core/storage/server_config_storage.dart';
import 'package:disciplaner_flutter/core/storage/token_storage.dart';
import 'package:disciplaner_flutter/features/auth/data/auth_repository.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_state.dart';
import 'package:disciplaner_flutter/features/auth/presentation/homelab_server_card.dart';
import 'package:disciplaner_flutter/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthRepository implements IAuthRepository {
  bool setupRequired = false;
  AuthResponse? currentSession;
  bool shouldThrow = false;

  @override
  Future<SetupStatusResponse> getSetupStatus() async {
    if (shouldThrow) throw AppFailure.network();
    return SetupStatusResponse(setupRequired: setupRequired);
  }

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    if (shouldThrow) throw AppFailure.unauthorized('Identifiants invalides');
    final auth = AuthResponse(
      token: 'jwt_mock_token_123',
      email: request.email,
      displayName: 'Test User',
      roles: const ['Admin'],
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );
    currentSession = auth;
    return auth;
  }

  @override
  Future<AuthResponse> executeSetup(SetupRequest request) async {
    final auth = AuthResponse(
      token: 'jwt_setup_token_456',
      email: request.email,
      displayName: request.displayName,
      roles: const ['Admin'],
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );
    setupRequired = false;
    currentSession = auth;
    return auth;
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    final auth = AuthResponse(
      token: 'jwt_reg_token_789',
      email: request.email,
      displayName: request.displayName,
      roles: const ['Member'],
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );
    currentSession = auth;
    return auth;
  }

  @override
  Future<InvitationInfoResponse> getInvitation(String token) async {
    return InvitationInfoResponse(
      isValid: true,
      email: 'invited@test.com',
      expiresAt: DateTime.now().add(const Duration(days: 3)),
    );
  }

  @override
  Future<AuthResponse> registerInvited(InvitationRegisterRequest request) async {
    final auth = AuthResponse(
      token: 'jwt_invited_token_abc',
      email: request.email,
      displayName: request.displayName,
      roles: const ['Member'],
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );
    currentSession = auth;
    return auth;
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('JSON Serialization / Deserialization', () {
    test('AuthResponse round-trip', () {
      final now = DateTime.now();
      final auth = AuthResponse(
        token: 'token_abc',
        email: 'dev@disciplan.local',
        displayName: 'Dev User',
        roles: const ['Admin', 'Supervisor'],
        expiresAt: now,
      );
      final json = auth.toJson();
      final parsed = AuthResponse.fromJson(json);

      expect(parsed.token, 'token_abc');
      expect(parsed.email, 'dev@disciplan.local');
      expect(parsed.displayName, 'Dev User');
      expect(parsed.roles, ['Admin', 'Supervisor']);
    });

    test('TicketDto round-trip with nested Status & Labels', () {
      final now = DateTime.now();
      final status = TicketStatusDto(
        id: 'status_1',
        projectId: 'proj_1',
        name: 'In Progress',
        color: '#F59E0B',
        order: 1,
        category: StatusCategory.inProgress,
      );
      final label = LabelDto(
        id: 'label_1',
        name: 'Frontend',
        color: '#E5A800',
        createdAt: now,
      );
      final ticket = TicketDto(
        id: 'ticket_1',
        projectId: 'proj_1',
        projectKey: 'DIS',
        ticketNumber: 42,
        ticketRef: 'DIS-42',
        title: 'Implémenter le client Dio',
        description: 'Ajouter intercepteur JWT',
        type: TicketType.story,
        priority: CardPriority.critical,
        storyPoints: 5,
        dueDate: now.add(const Duration(days: 2)),
        status: status,
        sprintId: 'sprint_1',
        sprintName: 'Cycle 1',
        reporterId: 'user_1',
        reporterName: 'Alexandre',
        assigneeId: 'user_1',
        assigneeName: 'Alexandre',
        createdAt: now,
        labels: [label],
      );

      final json = ticket.toJson();
      final parsed = TicketDto.fromJson(json);

      expect(parsed.ticketRef, 'DIS-42');
      expect(parsed.type, TicketType.story);
      expect(parsed.priority, CardPriority.critical);
      expect(parsed.status.name, 'In Progress');
      expect(parsed.status.category, StatusCategory.inProgress);
      expect(parsed.labels.length, 1);
      expect(parsed.labels.first.name, 'Frontend');
    });

    test('SprintDto round-trip', () {
      final now = DateTime.now();
      final sprint = SprintDto(
        id: 'sprint_1',
        projectId: 'proj_1',
        projectName: 'Disciplan',
        projectKey: 'DIS',
        name: 'Sprint 01',
        goal: 'Délivrer le socle Flutter',
        status: SprintStatus.active,
        startDate: now,
        endDate: now.add(const Duration(days: 14)),
        createdAt: now,
        ticketCount: 12,
      );

      final json = sprint.toJson();
      final parsed = SprintDto.fromJson(json);

      expect(parsed.name, 'Sprint 01');
      expect(parsed.status, SprintStatus.active);
      expect(parsed.ticketCount, 12);
    });

    test('ProjectDetailDto round-trip', () {
      final now = DateTime.now();
      final project = ProjectDetailDto(
        id: 'proj_1',
        name: 'Disciplan Core',
        description: 'Projet principal',
        key: 'DISC',
        ownerId: 'user_admin',
        createdAt: now,
        statuses: [
          TicketStatusDto(
            id: 'stat_1',
            projectId: 'proj_1',
            name: 'Backlog',
            color: '#9CA3AF',
            order: 0,
            category: StatusCategory.backlog,
          ),
        ],
        sprints: const [],
        defaultTicketType: TicketType.task,
        defaultAssigneePolicy: DefaultAssigneePolicy.creator,
        members: [
          MemberDto(
            userId: 'user_1',
            displayName: 'Dev',
            email: 'dev@test.com',
            role: MemberRole.supervisor,
            joinedAt: now,
          ),
        ],
        requestingUserRole: MemberRole.admin,
      );

      final json = project.toJson();
      final parsed = ProjectDetailDto.fromJson(json);

      expect(parsed.name, 'Disciplan Core');
      expect(parsed.defaultTicketType, TicketType.task);
      expect(parsed.defaultAssigneePolicy, DefaultAssigneePolicy.creator);
      expect(parsed.statuses.first.name, 'Backlog');
      expect(parsed.members.first.role, MemberRole.supervisor);
    });
  });

  group('Storage & AuthNotifier', () {
    test('ServerConfigStorage updates and sanitizes URL', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = ServerConfigStorage(prefs);

      expect(storage.getBaseUrl(), 'http://localhost:8080');

      await storage.setBaseUrl('192.168.1.100:9000/');
      expect(storage.getBaseUrl(), 'http://192.168.1.100:9000');

      await storage.setBaseUrl('https://disciplan.myhomelab.com');
      expect(storage.getBaseUrl(), 'https://disciplan.myhomelab.com');
    });

    test('TokenStorage saves and clears session via fallback', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = TokenStorage(fallbackPrefs: prefs);

      final auth = AuthResponse(
        token: 'token_xyz',
        email: 'user@test.local',
        displayName: 'Test',
        roles: const ['Admin'],
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      await storage.saveSession(auth);
      final retrieved = await storage.getSession();
      expect(retrieved?.token, 'token_xyz');

      await storage.clear();
      final afterClear = await storage.getSession();
      expect(afterClear, isNull);
    });

    test('AuthNotifier workflow: checkStatus, login, logout', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final serverStorage = ServerConfigStorage(prefs);
      final tokenStorage = TokenStorage(fallbackPrefs: prefs);
      final mockRepo = MockAuthRepository();

      final container = ProviderContainer(
        overrides: [
          serverConfigStorageProvider.overrideWithValue(serverStorage),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          authRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(authNotifierProvider), const AuthInitial());

      // Check status with setup required
      mockRepo.setupRequired = true;
      await container.read(authNotifierProvider.notifier).checkStatusAndSession();
      expect(container.read(authNotifierProvider), const AuthNeedsInitialSetup());

      // Perform initial setup
      await container.read(authNotifierProvider.notifier).setupInitialAdmin(
            email: 'admin@test.com',
            displayName: 'Admin Root',
            password: 'password123',
          );
      expect(container.read(authNotifierProvider), isA<AuthAuthenticated>());

      // Logout
      await container.read(authNotifierProvider.notifier).logout();
      expect(container.read(authNotifierProvider), const AuthUnauthenticated());

      // Login
      await container.read(authNotifierProvider.notifier).login('admin@test.com', 'password123');
      expect(container.read(authNotifierProvider), isA<AuthAuthenticated>());
      final session = (container.read(authNotifierProvider) as AuthAuthenticated).session;
      expect(session.email, 'admin@test.com');
    });
  });

  group('Presentation Widgets', () {
    testWidgets('LoginScreen and HomelabServerCard render properly', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final serverStorage = ServerConfigStorage(prefs);
      final tokenStorage = TokenStorage(fallbackPrefs: prefs);
      final mockRepo = MockAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            serverConfigStorageProvider.overrideWithValue(serverStorage),
            tokenStorageProvider.overrideWithValue(tokenStorage),
            authRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      expect(find.text('Connexion à Disciplan'), findsOneWidget);
      expect(find.text('SERVEUR HOMELAB'), findsOneWidget);
      expect(find.byType(HomelabServerCard), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);

      // Switch to invitation mode
      await tester.tap(find.text('Vous avez reçu une invitation ?'));
      await tester.pumpAndSettle();

      expect(find.text('Rejoindre une Équipe'), findsOneWidget);
      expect(find.text('Valider l\'invitation'), findsOneWidget);
    });
  });
}
