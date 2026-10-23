import 'package:disciplaner_flutter/app/theme/neo_theme.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/core/models/sprint_models.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/features/kanban/presentation/desktop_sprint_kanban_view.dart';
import 'package:disciplaner_flutter/features/kanban/presentation/kanban_providers.dart';
import 'package:disciplaner_flutter/features/kanban/presentation/mobile_sprint_kanban_view.dart';
import 'package:disciplaner_flutter/features/sprints/presentation/sprint_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeDateFormatting('fr_FR', null);
  });

  const statusTodo = TicketStatusDto(
    id: 'status-todo',
    projectId: 'p1',
    name: 'À faire',
    color: '#9CA3AF',
    order: 0,
    category: StatusCategory.backlog,
  );

  const statusInProgress = TicketStatusDto(
    id: 'status-in-progress',
    projectId: 'p1',
    name: 'En cours',
    color: '#F59E0B',
    order: 1,
    category: StatusCategory.inProgress,
  );

  const statusDone = TicketStatusDto(
    id: 'status-done',
    projectId: 'p1',
    name: 'Terminé',
    color: '#10B981',
    order: 2,
    category: StatusCategory.done,
  );

  final sampleTicket1 = TicketDto(
    id: 't1',
    projectId: 'p1',
    projectKey: 'DISC',
    ticketNumber: 14,
    ticketRef: 'DISC-14',
    title: 'Déclinaison affichage urbain 4x3',
    type: TicketType.task,
    priority: CardPriority.high,
    status: statusInProgress,
    reporterId: 'u1',
    reporterName: 'Alexandre M.',
    assigneeId: 'u2',
    assigneeName: 'Camille D.',
    createdAt: DateTime.now(),
  );

  final sampleTicket2 = TicketDto(
    id: 't2',
    projectId: 'p1',
    projectKey: 'DISC',
    ticketNumber: 18,
    ticketRef: 'DISC-18',
    title: 'Adaptation stories sponsorisées',
    type: TicketType.task,
    priority: CardPriority.low,
    status: statusTodo,
    reporterId: 'u1',
    reporterName: 'Alexandre M.',
    assigneeId: 'u1',
    assigneeName: 'Alexandre M.',
    createdAt: DateTime.now(),
  );

  final sampleSprint = SprintDto(
    id: 'sprint-4',
    projectId: 'p1',
    name: 'Sprint 04 — Campagne de Marque',
    goal: 'Validation et production des assets',
    status: SprintStatus.active,
    startDate: DateTime.now().subtract(const Duration(days: 2)),
    endDate: DateTime.now().add(const Duration(days: 12)),
    createdAt: DateTime.now(),
    ticketCount: 2,
  );

  group('KanbanState Filter Unit Tests', () {
    test('filters tickets by search query, assignee and priority', () {
      final state = KanbanState(
        statuses: const [statusTodo, statusInProgress, statusDone],
        ticketsByStatus: {
          statusTodo.id: [sampleTicket2],
          statusInProgress.id: [sampleTicket1],
          statusDone.id: [],
        },
      );

      // No filter: returns all
      expect(state.getFilteredTicketsForStatus(statusInProgress.id, 'u1').length, 1);

      // Search matching title
      final searchedState = state.copyWith(searchQuery: 'affichage');
      expect(searchedState.getFilteredTicketsForStatus(statusInProgress.id, 'u1').length, 1);
      expect(searchedState.getFilteredTicketsForStatus(statusTodo.id, 'u1').length, 0);

      // Only assigned to me (u1)
      final myTasksState = state.copyWith(onlyAssignedToMe: true);
      expect(myTasksState.getFilteredTicketsForStatus(statusInProgress.id, 'u1').length, 0); // assigned to u2
      expect(myTasksState.getFilteredTicketsForStatus(statusTodo.id, 'u1').length, 1); // assigned to u1

      // Priority filter
      final highPriorityState = state.copyWith(selectedPriority: CardPriority.high);
      expect(highPriorityState.getFilteredTicketsForStatus(statusInProgress.id, 'u1').length, 1);
      expect(highPriorityState.getFilteredTicketsForStatus(statusTodo.id, 'u1').length, 0);
    });
  });

  group('DesktopSprintKanbanView Widget Test', () {
    testWidgets('renders Kanban columns and cards', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            kanbanStateProvider('sprint-4').overrideWith(
              () => _MockKanbanNotifier(
                'sprint-4',
                KanbanState(
                  statuses: const [statusTodo, statusInProgress, statusDone],
                  ticketsByStatus: {
                    statusTodo.id: [sampleTicket2],
                    statusInProgress.id: [sampleTicket1],
                    statusDone.id: [],
                  },
                ),
              ),
            ),
            sprintMetricsProvider('sprint-4').overrideWith(
              (ref) async => const SprintMetrics(
                totalTickets: 2,
                closedTickets: 0,
                completionPercentage: 0,
                totalPoints: 8,
                completedPoints: 0,
                daysRemaining: 12,
                activeMemberNames: ['Camille D.', 'Alexandre M.'],
              ),
            ),
          ],
          child: MaterialApp(
            theme: NeoTheme.lightTheme,
            home: DesktopSprintKanbanView(sprint: sampleSprint),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Headers and columns
      expect(find.text('À faire'), findsOneWidget);
      expect(find.text('En cours'), findsWidgets);
      expect(find.text('Terminé'), findsOneWidget);

      // Cards
      expect(find.text('DISC-14'), findsOneWidget);
      expect(find.text('Déclinaison affichage urbain 4x3'), findsOneWidget);
      expect(find.text('DISC-18'), findsOneWidget);
      expect(find.text('Adaptation stories sponsorisées'), findsOneWidget);
    });
  });

  group('MobileSprintKanbanView Widget Test', () {
    testWidgets('renders horizontal status tab pills and switches column view on tap',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            kanbanStateProvider('sprint-4').overrideWith(
              () => _MockKanbanNotifier(
                'sprint-4',
                KanbanState(
                  statuses: const [statusTodo, statusInProgress, statusDone],
                  ticketsByStatus: {
                    statusTodo.id: [sampleTicket2],
                    statusInProgress.id: [sampleTicket1],
                    statusDone.id: [],
                  },
                ),
              ),
            ),
            sprintMetricsProvider('sprint-4').overrideWith(
              (ref) async => const SprintMetrics(
                totalTickets: 2,
                closedTickets: 0,
                completionPercentage: 0,
                totalPoints: 8,
                completedPoints: 0,
                daysRemaining: 12,
                activeMemberNames: ['Camille D.'],
              ),
            ),
          ],
          child: MaterialApp(
            theme: NeoTheme.lightTheme,
            home: MobileSprintKanbanView(sprint: sampleSprint),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial tab is statusTodo (index 0)
      expect(find.text('DISC-18'), findsOneWidget);
      expect(find.text('Adaptation stories sponsorisées'), findsOneWidget);

      // Tap on 'En cours' tab pill
      await tester.tap(find.text('En cours'));
      await tester.pumpAndSettle();

      // Now active column is statusInProgress
      expect(find.text('DISC-14'), findsOneWidget);
      expect(find.text('Déclinaison affichage urbain 4x3'), findsOneWidget);
    });
  });
}

class _MockKanbanNotifier extends KanbanNotifier {
  final KanbanState initialData;

  _MockKanbanNotifier(super.sprintId, this.initialData);

  @override
  Future<KanbanState> build() async {
    return initialData;
  }
}
