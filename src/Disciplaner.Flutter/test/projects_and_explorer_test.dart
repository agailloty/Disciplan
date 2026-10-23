import 'package:disciplaner_flutter/app/theme/neo_theme.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/features/projects/data/project_repository.dart';
import 'package:disciplaner_flutter/features/projects/presentation/create_project_modal.dart';
import 'package:disciplaner_flutter/features/projects/presentation/mobile_projects_view.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class MockProjectRepository implements IProjectRepository {
  final List<ProjectSummaryDto> projects = [];
  ProjectDetailDto? detail;

  @override
  Future<List<ProjectSummaryDto>> getAll() async => projects;

  @override
  Future<ProjectDetailDto> getById(String id) async {
    return detail ??
        ProjectDetailDto(
          id: id,
          name: 'Projet Test',
          key: 'TEST',
          ownerId: 'owner_1',
          createdAt: DateTime.now(),
          statuses: const [],
          sprints: const [],
          defaultTicketType: TicketType.story,
          defaultAssigneePolicy: DefaultAssigneePolicy.creator,
          members: const [],
          requestingUserRole: MemberRole.admin,
        );
  }

  @override
  Future<ProjectDetailDto> create(CreateProjectRequest request) async {
    final created = ProjectDetailDto(
      id: 'proj_${projects.length + 1}',
      name: request.name,
      key: request.key,
      description: request.description,
      ownerId: 'owner_1',
      createdAt: DateTime.now(),
      statuses: const [],
      sprints: const [],
      defaultTicketType: TicketType.task,
      defaultAssigneePolicy: DefaultAssigneePolicy.none,
      members: const [],
      requestingUserRole: MemberRole.admin,
    );
    projects.add(
      ProjectSummaryDto(
        id: created.id,
        name: created.name,
        key: created.key,
        description: created.description,
        ticketCount: 0,
        sprintCount: 0,
        createdAt: created.createdAt,
        requestingUserRole: MemberRole.admin,
        isOwner: true,
      ),
    );
    detail = created;
    return created;
  }

  @override
  Future<ProjectDetailDto> update(String id, UpdateProjectRequest request) async {
    detail = detail != null
        ? ProjectDetailDto(
            id: detail!.id,
            name: request.name,
            key: detail!.key,
            description: request.description,
            ownerId: detail!.ownerId,
            createdAt: detail!.createdAt,
            statuses: detail!.statuses,
            sprints: detail!.sprints,
            defaultTicketType: detail!.defaultTicketType,
            defaultAssigneePolicy: detail!.defaultAssigneePolicy,
            members: detail!.members,
            requestingUserRole: detail!.requestingUserRole,
          )
        : null;
    return detail!;
  }

  @override
  Future<ProjectDetailDto> updateDefaults(String id, UpdateProjectDefaultsRequest request) async {
    return detail!;
  }

  @override
  Future<void> delete(String id) async {
    projects.removeWhere((p) => p.id == id);
  }

  @override
  Future<TicketStatusDto> addStatus(String projectId, CreateTicketStatusRequest request) async {
    return TicketStatusDto(
      id: 'stat_new',
      projectId: projectId,
      name: request.name,
      color: request.color,
      order: 0,
      category: request.category,
    );
  }

  @override
  Future<TicketStatusDto> updateStatus(
    String projectId,
    String statusId,
    UpdateTicketStatusRequest request,
  ) async {
    return TicketStatusDto(
      id: statusId,
      projectId: projectId,
      name: request.name,
      color: request.color,
      order: 0,
      category: request.category,
    );
  }

  @override
  Future<void> deleteStatus(String projectId, String statusId) async {}

  @override
  Future<List<MemberDto>> getMembers(String projectId) async => const [];

  @override
  Future<MemberDto> addMember(String projectId, AddMemberRequest request) async {
    return MemberDto(
      userId: request.userId,
      displayName: 'New Member',
      email: 'member@test.local',
      role: request.role,
      joinedAt: DateTime.now(),
    );
  }

  @override
  Future<MemberDto> updateMemberRole(
    String projectId,
    String userId,
    UpdateMemberRoleRequest request,
  ) async {
    return MemberDto(
      userId: userId,
      displayName: 'Member',
      email: 'member@test.local',
      role: request.role,
      joinedAt: DateTime.now(),
    );
  }

  @override
  Future<void> removeMember(String projectId, String userId) async {}
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('generateProjectKey helper', () {
    test('generates expected keys from project names', () {
      expect(generateProjectKey('Disciplan'), 'DISC');
      expect(generateProjectKey('Refonte Identité Visuelle'), 'RIV');
      expect(generateProjectKey('Campagne Marque 2025'), 'CM2');
      expect(generateProjectKey('API'), 'API');
      expect(generateProjectKey(''), '');
    });
  });

  group('ProjectRepository unit test', () {
    test('creates and retrieves projects', () async {
      final mockRepo = MockProjectRepository();
      final created = await mockRepo.create(
        const CreateProjectRequest(
          name: 'Nouveau Studio',
          key: 'STUD',
          description: 'Espace de design',
        ),
      );

      expect(created.name, 'Nouveau Studio');
      expect(created.key, 'STUD');

      final list = await mockRepo.getAll();
      expect(list.length, 1);
      expect(list.first.key, 'STUD');

      final fetched = await mockRepo.getById(created.id);
      expect(fetched.id, created.id);
    });
  });

  group('CreateProjectModal widget test', () {
    testWidgets('renders inputs and auto-generates key', (WidgetTester tester) async {
      final mockRepo = MockProjectRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            theme: NeoTheme.lightTheme,
            home: const Scaffold(
              body: CreateProjectModal(),
            ),
          ),
        ),
      );

      expect(find.text('Créer un nouveau projet'), findsOneWidget);
      expect(find.text('NOM DU PROJET *'), findsOneWidget);

      // Saisir un nom de projet
      await tester.enterText(find.byType(TextField).first, 'Campagne Marque');
      await tester.pump();

      // Vérifier que la clé est auto-générée
      expect(find.text('CM-1'), findsOneWidget);

      // Soumettre le formulaire
      await tester.tap(find.text('Créer le projet'));
      await tester.pumpAndSettle();

      expect(mockRepo.projects.length, 1);
      expect(mockRepo.projects.first.name, 'Campagne Marque');
    });
  });

  group('MobileProjectsView widget test', () {
    testWidgets('renders filter pills and project cards', (WidgetTester tester) async {
      final mockRepo = MockProjectRepository();
      mockRepo.projects.add(
        ProjectSummaryDto(
          id: 'proj_demo',
          name: 'Campagne Marque 2025',
          key: 'CAMP',
          description: 'Déploiement marketing',
          ticketCount: 18,
          sprintCount: 4,
          createdAt: DateTime.now(),
          requestingUserRole: MemberRole.admin,
          isOwner: true,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            theme: NeoTheme.lightTheme,
            home: const MobileProjectsView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Projets & Équipes'), findsOneWidget);
      expect(find.text('Tous'), findsOneWidget);
      expect(find.text('En cours'), findsOneWidget);
      expect(find.text('Favoris'), findsOneWidget);

      // Card
      expect(find.text('CAMP'), findsOneWidget);
      expect(find.text('Campagne Marque 2025'), findsOneWidget);
      expect(find.text('18 tickets • 4 sprints'), findsOneWidget);
    });
  });
}
