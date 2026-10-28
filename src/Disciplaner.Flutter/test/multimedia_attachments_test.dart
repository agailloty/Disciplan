import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:disciplaner_flutter/app/theme/neo_theme.dart';
import 'package:disciplaner_flutter/core/models/collaboration_models.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/core/utils/media_utils.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';
import 'package:disciplaner_flutter/features/tickets/data/ticket_repository.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/ticket_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/attachment_panel.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/desktop_create_ticket_dialog.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/file_preview_dialog.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/split_inspector_panel.dart';
import 'package:disciplaner_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _FakeTicketRepository extends TicketRepository {
  _FakeTicketRepository() : super(Dio());

  final List<PickedMediaFile> uploadedTicketFiles = [];
  final List<PickedMediaFile> uploadedCommentFiles = [];
  final List<String> deletedAttachmentIds = [];

  @override
  Future<AttachmentDto> uploadTicketAttachment(
    String ticketId,
    PickedMediaFile file,
  ) async {
    uploadedTicketFiles.add(file);
    return AttachmentDto(
      id: 'att-uploaded-${uploadedTicketFiles.length}',
      fileName: file.name,
      contentType: file.contentType,
      sizeBytes: file.sizeBytes,
      uploadedById: 'user-1',
      uploadedByName: 'Alexandre M.',
      uploadedAt: DateTime(2026, 1, 15, 10, 30),
      ticketId: ticketId,
    );
  }

  @override
  Future<CommentDto> addComment(String ticketId, String content) async {
    return CommentDto(
      id: 'comment-new-1',
      cardId: ticketId,
      authorId: 'user-1',
      authorName: 'Alexandre M.',
      content: content,
      createdAt: DateTime(2026, 1, 15, 10, 35),
    );
  }

  @override
  Future<AttachmentDto> uploadCommentAttachment(
    String commentId,
    PickedMediaFile file,
  ) async {
    uploadedCommentFiles.add(file);
    return AttachmentDto(
      id: 'att-comment-${uploadedCommentFiles.length}',
      fileName: file.name,
      contentType: file.contentType,
      sizeBytes: file.sizeBytes,
      uploadedById: 'user-1',
      uploadedByName: 'Alexandre M.',
      uploadedAt: DateTime(2026, 1, 15, 10, 35),
      commentId: commentId,
    );
  }

  @override
  Future<void> deleteAttachment(String attachmentId) async {
    deletedAttachmentIds.add(attachmentId);
  }

  @override
  Future<TicketDto> createTicket(
    String projectId,
    CreateTicketRequest request,
  ) async {
    return TicketDto(
      id: 'created-ticket-99',
      projectId: projectId,
      projectKey: 'DISC',
      ticketNumber: 99,
      ticketRef: 'DISC-99',
      title: request.title,
      description: request.description,
      type: request.type,
      priority: request.priority,
      status: const TicketStatusDto(
        id: 'status-1',
        projectId: 'proj-1',
        name: 'Backlog',
        color: '#64748B',
        order: 0,
        category: StatusCategory.backlog,
      ),
      reporterId: 'user-1',
      reporterName: 'Alexandre M.',
      createdAt: DateTime(2026, 1, 15),
    );
  }

  @override
  Future<List<TicketDto>> getMine() async => const [];
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  tearDown(() {
    MediaUtils.debugPickerOverride = null;
  });

  group('MediaUtils & AttachmentDto Unit Tests', () {
    test('resolveMimeType maps extensions to backend-allowed MIME types', () {
      expect(MediaUtils.resolveMimeType('photo.JPG'), 'image/jpeg');
      expect(MediaUtils.resolveMimeType('capture.png'), 'image/png');
      expect(MediaUtils.resolveMimeType('anim.gif'), 'image/gif');
      expect(MediaUtils.resolveMimeType('visuel.webp'), 'image/webp');
      expect(MediaUtils.resolveMimeType('brief.pdf'), 'application/pdf');
      expect(
        MediaUtils.resolveMimeType('cahier.docx'),
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      );
      expect(
        MediaUtils.resolveMimeType('budget.xlsx'),
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
      expect(MediaUtils.resolveMimeType('notes.txt'), 'text/plain');
      expect(MediaUtils.resolveMimeType('export.csv'), 'text/csv');
      expect(MediaUtils.resolveMimeType('livrables.zip'), 'application/zip');
    });

    test('formatFileSize formats bytes into o, Ko, and Mo', () {
      expect(MediaUtils.formatFileSize(512), '512 o');
      expect(MediaUtils.formatFileSize(2048), '2.0 Ko');
      expect(MediaUtils.formatFileSize(5 * 1024 * 1024), '5.0 Mo');
    });

    test('AttachmentDto.fromJson parses backend payload keys accurately', () {
      final dto = AttachmentDto.fromJson({
        'id': 'att-42',
        'originalFileName': 'plaquette_2026.pdf',
        'contentType': 'application/pdf',
        'fileSizeBytes': 1048576,
        'uploadedById': 'u-7',
        'uploadedByDisplayName': 'Camille R.',
        'uploadedAt': '2026-02-01T14:20:00Z',
        'ticketId': 't-10',
      });

      expect(dto.id, 'att-42');
      expect(dto.fileName, 'plaquette_2026.pdf');
      expect(dto.originalFileName, 'plaquette_2026.pdf');
      expect(dto.sizeBytes, 1048576);
      expect(dto.fileSizeBytes, 1048576);
      expect(dto.uploadedByName, 'Camille R.');
      expect(dto.uploadedByDisplayName, 'Camille R.');
      expect(dto.ticketId, 't-10');
    });

    test('pickAttachmentFiles rejects files exceeding 50 MB', () async {
      MediaUtils.debugPickerOverride = ({
        required allowMultiple,
        required allowedExtensions,
      }) async {
        return [
          PickedMediaFile(
            name: 'huge.zip',
            bytes: Uint8List(4),
            sizeBytes: MediaUtils.maxAttachmentSizeBytes + 1,
            contentType: 'application/zip',
          ),
        ];
      };

      expect(
        () => MediaUtils.pickAttachmentFiles(),
        throwsA(isA<MediaValidationException>()),
      );
    });
  });

  group('Multimedia Widgets Integration Tests', () {
    testWidgets(
      'TicketAttachmentsSection uploads, previews text file, and deletes attachment',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(900, 700));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final fakeRepo = _FakeTicketRepository();
        final sampleAtt = AttachmentDto(
          id: 'att-txt-1',
          fileName: 'compte_rendu.txt',
          contentType: 'text/plain',
          sizeBytes: 42,
          uploadedById: 'user-1',
          uploadedByName: 'Alexandre M.',
          uploadedAt: DateTime(2026, 1, 15, 9, 0),
          ticketId: 'ticket-14',
        );

        MediaUtils.debugPickerOverride = ({
          required allowMultiple,
          required allowedExtensions,
        }) async {
          return [
            PickedMediaFile(
              name: 'maquette.png',
              bytes: Uint8List.fromList([137, 80, 78, 71]),
              sizeBytes: 4,
              contentType: 'image/png',
            ),
          ];
        };

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              ticketRepositoryProvider.overrideWithValue(fakeRepo),
              ticketAttachmentsProvider('ticket-14')
                  .overrideWith((ref) async => [sampleAtt]),
              attachmentDownloadProvider('att-txt-1').overrideWith(
                (ref) async => (
                  Uint8List.fromList(
                    utf8.encode('Contenu du compte-rendu de réunion'),
                  ),
                  'text/plain',
                ),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('fr'),
              theme: NeoTheme.lightTheme,
              home: const Scaffold(
                body: Padding(
                  padding: EdgeInsets.all(16),
                  child: TicketAttachmentsSection(ticketId: 'ticket-14'),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Pièces jointes'), findsOneWidget);
        expect(find.text('compte_rendu.txt'), findsOneWidget);

        // Trigger upload via "Ajouter" button
        await tester.tap(find.text('Ajouter'));
        await tester.pumpAndSettle();
        expect(fakeRepo.uploadedTicketFiles.length, 1);
        expect(fakeRepo.uploadedTicketFiles.first.name, 'maquette.png');

        // Open preview modal by tapping the preview icon
        await tester.tap(find.byIcon(Icons.visibility_outlined));
        await tester.pumpAndSettle();

        expect(find.byType(FilePreviewDialog), findsOneWidget);
        expect(
          find.text('Contenu du compte-rendu de réunion'),
          findsOneWidget,
        );

        // Close preview modal
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        // Delete attachment
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();
        expect(fakeRepo.deletedAttachmentIds, contains('att-txt-1'));
      },
    );

    testWidgets(
      'SplitInspectorPanel attaches pending file to comment and uploads it',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final fakeRepo = _FakeTicketRepository();
        final sampleTicket = TicketDto(
          id: 'ticket-14',
          projectId: 'proj-1',
          projectKey: 'DISC',
          ticketNumber: 14,
          ticketRef: 'DISC-14',
          title: 'Validation visuels',
          type: TicketType.task,
          priority: CardPriority.medium,
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
          createdAt: DateTime(2026, 1, 10),
        );

        MediaUtils.debugPickerOverride = ({
          required allowMultiple,
          required allowedExtensions,
        }) async {
          return [
            PickedMediaFile(
              name: 'export_final.pdf',
              bytes: Uint8List.fromList([37, 80, 68, 70]),
              sizeBytes: 2048,
              contentType: 'application/pdf',
            ),
          ];
        };

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              ticketRepositoryProvider.overrideWithValue(fakeRepo),
              ticketDetailProvider('ticket-14')
                  .overrideWith((ref) async => sampleTicket),
              ticketCommentsProvider('ticket-14')
                  .overrideWith((ref) async => const []),
              ticketAttachmentsProvider('ticket-14')
                  .overrideWith((ref) async => const []),
              ticketHistoryProvider('ticket-14')
                  .overrideWith((ref) async => const []),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('fr'),
              theme: NeoTheme.lightTheme,
              home: const Scaffold(
                body: SplitInspectorPanel(
                  ticketId: 'ticket-14',
                  standalone: true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap the attach file button in comment composer
        final attachBtn = find.byTooltip('Joindre des fichiers');
        expect(attachBtn, findsOneWidget);
        await tester.tap(attachBtn);
        await tester.pumpAndSettle();

        // Pending file chip should appear
        expect(find.text('export_final.pdf'), findsOneWidget);

        // Send comment with attachment
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();

        expect(fakeRepo.uploadedCommentFiles.length, 1);
        expect(fakeRepo.uploadedCommentFiles.first.name, 'export_final.pdf');
      },
    );

    testWidgets(
      'DesktopCreateTicketDialog queues files and uploads them after creating ticket',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final fakeRepo = _FakeTicketRepository();
        MediaUtils.debugPickerOverride = ({
          required allowMultiple,
          required allowedExtensions,
        }) async {
          return [
            PickedMediaFile(
              name: 'brief_client.pdf',
              bytes: Uint8List.fromList([1, 2, 3, 4]),
              sizeBytes: 4096,
              contentType: 'application/pdf',
            ),
          ];
        };

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              ticketRepositoryProvider.overrideWithValue(fakeRepo),
              projectsListProvider.overrideWith(
                (ref) async => [
                  ProjectSummaryDto(
                    id: 'proj-1',
                    name: 'Projet Disciplan',
                    key: 'DISC',
                    description: 'Description',
                    ticketCount: 10,
                    sprintCount: 2,
                    createdAt: DateTime(2026, 1, 1),
                    requestingUserRole: MemberRole.admin,
                    isOwner: true,
                  ),
                ],
              ),
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

        await tester.enterText(
          find.widgetWithText(TextField, 'Titre de la tâche...'),
          'Nouveau ticket avec pièce jointe',
        );
        await tester.tap(find.text('Joindre'));
        await tester.pumpAndSettle();

        expect(find.text('brief_client.pdf'), findsOneWidget);

        await tester.tap(find.text('Créer la tâche'));
        await tester.pumpAndSettle();

        expect(fakeRepo.uploadedTicketFiles.length, 1);
        expect(fakeRepo.uploadedTicketFiles.first.name, 'brief_client.pdf');
      },
    );
  });
}

