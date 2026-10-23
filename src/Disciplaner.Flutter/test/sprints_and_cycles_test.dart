import 'package:disciplaner_flutter/app/theme/neo_theme.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/core/models/sprint_models.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/features/sprints/presentation/sprint_providers.dart';
import 'package:disciplaner_flutter/features/sprints/presentation/widgets/create_sprint_modal.dart';
import 'package:disciplaner_flutter/features/sprints/presentation/widgets/sprint_metrics_header.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/ticket_providers.dart';
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

  group('SprintMetrics Unit Tests', () {
    test('SprintMetrics.fromTickets calculates completion percentage and points correctly', () {
      final tickets = [
        TicketDto(
          id: '1',
          projectId: 'p1',
          projectKey: 'DISC',
          ticketNumber: 1,
          ticketRef: 'DISC-1',
          title: 'Ticket 1',
          type: TicketType.task,
          priority: CardPriority.medium,
          status: const TicketStatusDto(
            id: 's1',
            projectId: 'p1',
            name: 'Done',
            color: '#10B981',
            order: 2,
            category: StatusCategory.done,
          ),
          storyPoints: 5,
          assigneeName: 'Alexandre M.',
          reporterId: 'u1',
          reporterName: 'Alexandre M.',
          createdAt: DateTime.now(),
        ),
        TicketDto(
          id: '2',
          projectId: 'p1',
          projectKey: 'DISC',
          ticketNumber: 2,
          ticketRef: 'DISC-2',
          title: 'Ticket 2',
          type: TicketType.task,
          priority: CardPriority.high,
          status: const TicketStatusDto(
            id: 's2',
            projectId: 'p1',
            name: 'In Progress',
            color: '#F59E0B',
            order: 1,
            category: StatusCategory.inProgress,
          ),
          storyPoints: 8,
          assigneeName: 'Camille D.',
          reporterId: 'u1',
          reporterName: 'Alexandre M.',
          createdAt: DateTime.now(),
        ),
      ];

      final metrics = SprintMetrics.fromTickets(
        tickets: tickets,
        endDate: DateTime.now().add(const Duration(days: 5, hours: 2)),
      );

      expect(metrics.totalTickets, 2);
      expect(metrics.closedTickets, 1);
      expect(metrics.completionPercentage, 50.0);
      expect(metrics.totalPoints, 13);
      expect(metrics.completedPoints, 5);
      expect(metrics.daysRemaining, 5);
      expect(metrics.activeMemberNames, containsAll(['Alexandre M.', 'Camille D.']));
    });
  });

  group('SprintMetricsHeader Widget Test', () {
    testWidgets('SprintMetricsHeader renders status, title, goal and metrics', (tester) async {
      final sampleSprint = SprintDto(
        id: 'sprint-1',
        projectId: 'p1',
        name: 'Sprint 4 — Campagne de Marque',
        goal: 'Finaliser la production des contenus et assets médias.',
        status: SprintStatus.active,
        startDate: DateTime.now().subtract(const Duration(days: 4)),
        endDate: DateTime.now().add(const Duration(days: 10)),
        createdAt: DateTime.now(),
        ticketCount: 12,
      );

      const sampleMetrics = SprintMetrics(
        totalTickets: 12,
        closedTickets: 8,
        completionPercentage: 66.6,
        totalPoints: 24,
        completedPoints: 16,
        daysRemaining: 10,
        activeMemberNames: ['Camille D.', 'Marc V.'],
      );

      bool closeTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: NeoTheme.lightTheme,
          home: Scaffold(
            body: SprintMetricsHeader(
              sprint: sampleSprint,
              metrics: sampleMetrics,
              onClose: () => closeTriggered = true,
            ),
          ),
        ),
      );

      expect(find.text('Sprint Actif'), findsOneWidget);
      expect(find.text('Sprint 4 — Campagne de Marque'), findsOneWidget);
      expect(find.text('Finaliser la production des contenus et assets médias.'), findsOneWidget);
      expect(find.text('8/12 terminées'), findsOneWidget);
      expect(find.text('Terminer le sprint'), findsOneWidget);

      await tester.tap(find.text('Terminer le sprint'));
      await tester.pump();
      expect(closeTriggered, isTrue);
    });
  });

  group('CreateSprintModal Widget Test', () {
    testWidgets('CreateSprintModal renders form and cadence selection', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectBacklogProvider('p1').overrideWith((ref) async => []),
          ],
          child: MaterialApp(
            theme: NeoTheme.lightTheme,
            home: const Scaffold(
              body: CreateSprintModal(projectId: 'p1'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Créer et planifier un cycle'), findsOneWidget);
      expect(find.text('Rythme & Fréquence'), findsOneWidget);
      expect(find.text('1 sem.'), findsOneWidget);
      expect(find.text('2 sem.'), findsOneWidget);
      expect(find.text('1 mois'), findsOneWidget);
      expect(find.text('Créer le sprint'), findsOneWidget);
    });
  });
}
