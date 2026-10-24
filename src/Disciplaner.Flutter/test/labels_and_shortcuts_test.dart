import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/core/shortcuts/app_shortcuts.dart';
import 'package:disciplaner_flutter/features/tickets/data/ticket_repository.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/label_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/ticket_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/labels_modals.dart';
import 'package:disciplaner_flutter/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _FakeTicketRepository extends TicketRepository {
  _FakeTicketRepository() : super(Dio());

  final List<(String, String)> attached = [];
  final List<(String, String)> detached = [];

  @override
  Future<void> addLabel(String ticketId, String labelId) async =>
      attached.add((ticketId, labelId));

  @override
  Future<void> removeLabel(String ticketId, String labelId) async =>
      detached.add((ticketId, labelId));
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final labelA = LabelDto(
    id: 'label-a',
    name: 'Label A',
    color: '#8B5CF6',
    createdAt: DateTime.now(),
  );
  final labelB = LabelDto(
    id: 'label-b',
    name: 'Label B',
    color: '#10B981',
    createdAt: DateTime.now(),
  );

  final ticketWithLabels = TicketDto(
    id: 'ticket-14',
    projectId: 'proj-1',
    projectKey: 'DISC',
    ticketNumber: 14,
    ticketRef: 'DISC-14',
    title: 'Ticket avec étiquettes',
    type: TicketType.task,
    priority: CardPriority.high,
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
    createdAt: DateTime.now(),
    labels: [labelA],
  );

  testWidgets('LabelPickerModal attaches and detaches labels on the ticket',
      (WidgetTester tester) async {
    final fakeRepo = _FakeTicketRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          labelsListProvider.overrideWith((ref) async => [labelA, labelB]),
          ticketRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('fr'),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () =>
                    LabelPickerModal.show(context, ticketWithLabels),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Label A'), findsOneWidget);
    expect(find.text('Label B'), findsOneWidget);

    // « Label B » n'est pas attachée : la cocher l'attache au ticket.
    await tester.tap(find.text('Label B'));
    await tester.pumpAndSettle();
    expect(fakeRepo.attached.single, ('ticket-14', 'label-b'));
    expect(fakeRepo.detached, isEmpty);

    // « Label A » est déjà attachée : la décocher la détache.
    await tester.tap(find.text('Label A'));
    await tester.pumpAndSettle();
    expect(fakeRepo.detached.single, ('ticket-14', 'label-a'));
  });

  testWidgets(
      'Plain "c" is not captured while a text field has focus and still triggers quick create otherwise',
      (WidgetTester tester) async {
    late WidgetRef capturedRef;
    final controller = TextEditingController();
    var ancestorSawKeyC = false;

    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            capturedRef = ref;
            return MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('fr'),
              home: Focus(
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.keyC) {
                    ancestorSawKeyC = true;
                  }
                  return KeyEventResult.ignored;
                },
                child: AppShortcutsWrapper(
                  child: Scaffold(
                    body: TextField(controller: controller),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    // Focus dans le champ : l'événement « c » ne doit pas être consommé
    // par le raccourci (il remonte jusqu'à l'ancêtre, donc atteint le
    // champ de saisie).
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyC);
    await tester.pump();
    expect(ancestorSawKeyC, isTrue);
    expect(capturedRef.read(quickCreateTicketOpenProvider), isFalse);

    controller.dispose();
  });

  testWidgets('Plain "c" triggers quick create when no text field is focused',
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

    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyC);
    await tester.pump();
    expect(capturedRef.read(quickCreateTicketOpenProvider), isTrue);
  });
}
