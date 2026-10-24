import 'package:disciplaner_flutter/app/theme/neo_theme.dart';
import 'package:disciplaner_flutter/core/models/collaboration_models.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/ticket_detail_screen.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/ticket_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/desktop_create_ticket_dialog.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/mobile_create_ticket_sheet.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/mobile_ticket_detail_sheet.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/split_inspector_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:disciplaner_flutter/l10n/app_localizations.dart';

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
    description: 'Adaptation des visuels clés pour le déploiement national.',
    type: TicketType.task,
    priority: CardPriority.high,
    storyPoints: 5,
    dueDate: DateTime(2025, 5, 24),
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
    createdAt: DateTime(2025, 5, 10),
    labels: [
      LabelDto(
        id: 'label-1',
        name: 'Design',
        color: '#8B5CF6',
        createdAt: DateTime.now(),
      ),
    ],
  );

  final sampleComments = [
    CommentDto(
      id: 'c-1',
      cardId: 'ticket-14',
      authorId: 'user-2',
      authorName: 'Clara D.',
      content: 'Gabarits Clear Channel validés avec la régie.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  final sampleAttachments = [
    AttachmentDto(
      id: 'att-1',
      fileName: 'maquette_urbaine_v1.fig',
      contentType: 'application/octet-stream',
      sizeBytes: 142 * 1024 * 1024,
      uploadedById: 'user-1',
      uploadedByName: 'Alexandre M.',
      uploadedAt: DateTime.now(),
    ),
  ];

  final sampleHistory = [
    TicketHistoryEntryDto(
      id: 'h-1',
      kind: 'Statut',
      oldValue: 'À faire',
      newValue: 'En cours',
      actorId: 'user-1',
      actorName: 'Alexandre M.',
      occurredAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  group('DesktopCreateTicketDialog Widget Test', () {
    testWidgets('DesktopCreateTicketDialog renders and handles title input', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectsListProvider.overrideWith((ref) async => [
                  ProjectSummaryDto(
                    id: 'proj-1',
                    name: 'Projet Disciplan',
                    key: 'DISC',
                    description: 'Description',
                    ticketCount: 10,
                    sprintCount: 2,
                    createdAt: DateTime.now(),
                    requestingUserRole: MemberRole.admin,
                    isOwner: true,
                  ),
                ]),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
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

      // Saisie du titre
      final titleField = find.widgetWithText(TextField, 'Titre de la tâche...');
      expect(titleField, findsOneWidget);
      await tester.enterText(titleField, 'Mon nouveau ticket');
      await tester.pump();

      expect(find.text('Mon nouveau ticket'), findsOneWidget);
    });
  });

  group('MobileCreateTicketSheet Widget Test', () {
    testWidgets('MobileCreateTicketSheet renders quick metadata and shortcuts', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 850));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectsListProvider.overrideWith((ref) async => [
                  ProjectSummaryDto(
                    id: 'proj-1',
                    name: 'Projet Disciplan',
                    key: 'DISC',
                    description: 'Description',
                    ticketCount: 10,
                    sprintCount: 2,
                    createdAt: DateTime.now(),
                    requestingUserRole: MemberRole.admin,
                    isOwner: true,
                  ),
                ]),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
            theme: NeoTheme.lightTheme,
            home: const Scaffold(
              body: MobileCreateTicketSheet(initialProjectId: 'proj-1'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Créer'), findsOneWidget);
      expect(find.text('MÉTADONNÉES RAPIDES'), findsOneWidget);
      expect(find.text('Assigné à'), findsOneWidget);
      expect(find.text('Projet'), findsOneWidget);

      await tester.drag(find.byType(ListView).first, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Créer une autre tâche ensuite'), findsOneWidget);
    });
  });

  group('SplitInspectorPanel Widget Test', () {
    testWidgets('SplitInspectorPanel renders ticket detail, subtasks, attachments and comments', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ticketDetailProvider('ticket-14').overrideWith((ref) async => sampleTicket),
            ticketCommentsProvider('ticket-14').overrideWith((ref) async => sampleComments),
            ticketAttachmentsProvider('ticket-14').overrideWith((ref) async => sampleAttachments),
            ticketHistoryProvider('ticket-14').overrideWith((ref) async => sampleHistory),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
            theme: NeoTheme.lightTheme,
            home: const Scaffold(
              body: SplitInspectorPanel(ticketId: 'ticket-14'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('DISC-14'), findsOneWidget);
      expect(find.text('Déclinaison affichage urbain 4x3 & abribus'), findsOneWidget);
      expect(find.text('Adaptation des visuels clés pour le déploiement national.'), findsOneWidget);
      expect(find.text('Sous-tâches & Livrables'), findsOneWidget);
      expect(find.text('Pièces jointes'), findsOneWidget);
      expect(find.text('maquette_urbaine_v1.fig'), findsOneWidget);

      await tester.drag(find.byType(ListView).first, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Commentaires'), findsOneWidget);
      expect(find.text('Historique'), findsOneWidget);
      expect(find.text('Clara D.'), findsOneWidget);
      expect(find.text('Gabarits Clear Channel validés avec la régie.'), findsOneWidget);
    });
  });

  group('TicketDetailScreen Desktop Page Test', () {
    testWidgets('TicketDetailScreen renders a two-column standalone desktop layout', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      await tester.binding.setSurfaceSize(const Size(1400, 900));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ticketByRefProvider('DISC-14').overrideWith((ref) async => sampleTicket),
            ticketDetailProvider('ticket-14').overrideWith((ref) async => sampleTicket),
            ticketCommentsProvider('ticket-14').overrideWith((ref) async => sampleComments),
            ticketAttachmentsProvider('ticket-14').overrideWith((ref) async => sampleAttachments),
            ticketHistoryProvider('ticket-14').overrideWith((ref) async => sampleHistory),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
            theme: NeoTheme.lightTheme,
            home: const TicketDetailScreen(ticketRef: 'DISC-14'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Page desktop : titre, propriétés (colonne latérale) et activité
      // (colonne principale) sont visibles simultanément, sans défilement.
      expect(find.text('Déclinaison affichage urbain 4x3 & abribus'), findsOneWidget);
      expect(find.text('Priorité'), findsWidgets);
      expect(find.text('Commentaires'), findsOneWidget);
    });
  });

  group('MobileTicketDetailSheet Widget Test', () {
    testWidgets('MobileTicketDetailSheet renders mobile header, properties grid, checklist and composer', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1400));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ticketDetailProvider('ticket-14').overrideWith((ref) async => sampleTicket),
            ticketCommentsProvider('ticket-14').overrideWith((ref) async => sampleComments),
            ticketAttachmentsProvider('ticket-14').overrideWith((ref) async => sampleAttachments),
            ticketHistoryProvider('ticket-14').overrideWith((ref) async => sampleHistory),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
            theme: NeoTheme.lightTheme,
            home: const Scaffold(
              body: MobileTicketDetailSheet(ticketId: 'ticket-14'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Détail Ticket'), findsOneWidget);
      expect(find.text('DISC-14'), findsOneWidget);
      expect(find.text('Déclinaison affichage urbain 4x3 & abribus'), findsOneWidget);
      expect(find.text('ASSIGNÉ'), findsOneWidget);
      expect(find.text('ÉCHÉANCE'), findsOneWidget);

      await tester.drag(find.byType(ListView).first, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Sous-tâches'), findsOneWidget);

      await tester.drag(find.byType(ListView).first, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Pièces jointes'), findsOneWidget);

      await tester.drag(find.byType(ListView).first, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Échanges récents'), findsOneWidget);
      expect(find.text('Clara D.'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Ajouter une note...'), findsOneWidget);
    });
  });
}
