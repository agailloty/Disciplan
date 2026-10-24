import 'package:disciplaner_flutter/app/theme/neo_theme.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/dense_checkbox.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/dense_ticket_row.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/multi_select_action_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:disciplaner_flutter/l10n/app_localizations.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('DenseCheckbox Widget Test', () {
    testWidgets('DenseCheckbox renders 14x14 box and responds to tap', (tester) async {
      bool value = false;

      await tester.pumpWidget(
        MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return DenseCheckbox(
                  value: value,
                  onChanged: (newVal) => setState(() => value = newVal ?? false),
                );
              },
            ),
          ),
        ),
      );

      final boxFinder = find.byType(DenseCheckbox);
      expect(boxFinder, findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);

      await tester.tap(boxFinder);
      await tester.pump();

      expect(value, isTrue);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('DenseTicketRow Widget Test', () {
    final sampleTicket = TicketDto(
      id: 'ticket-1',
      projectId: 'proj-1',
      projectKey: 'DISC',
      ticketNumber: 14,
      ticketRef: 'DISC-14',
      title: 'Création des supports de communication',
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
      assigneeId: 'user-2',
      assigneeName: 'Camille D.',
      createdAt: DateTime.now(),
      labels: [
        LabelDto(
          id: 'label-1',
          name: 'Marketing',
          color: '#3B82F6',
          createdAt: DateTime.now(),
        ),
      ],
    );

    testWidgets('DenseTicketRow renders title, ref, priority, avatar and labels',
        (tester) async {
      bool selected = false;

      await tester.pumpWidget(
        MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
          theme: NeoTheme.lightTheme,
          home: Scaffold(
            body: DenseTicketRow(
              ticket: sampleTicket,
              isSelected: selected,
              onSelectedChanged: (val) => selected = val,
            ),
          ),
        ),
      );

      expect(find.text('DISC-14'), findsOneWidget);
      expect(find.text('Création des supports de communication'), findsOneWidget);
      expect(find.text('Marketing'), findsOneWidget);
      expect(find.text('En cours'), findsOneWidget);
      expect(find.text('CD'), findsOneWidget); // UserAvatar initials
    });
  });

  group('MultiSelectActionBar Widget Test', () {
    testWidgets('MultiSelectActionBar displays count and triggers clear and actions',
        (tester) async {
      bool cleared = false;
      StatusCategory? chosenCategory;

      await tester.pumpWidget(
        MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
          theme: NeoTheme.lightTheme,
          home: Scaffold(
            body: MultiSelectActionBar(
              selectedCount: 3,
              onClear: () => cleared = true,
              onStatusSelect: (StatusCategory cat) => chosenCategory = cat,
            ),
          ),
        ),
      );

      expect(find.text('3 sélectionné(s)'), findsOneWidget);
      expect(find.text('Statut'), findsOneWidget);
      expect(find.text('Esc'), findsOneWidget);

      await tester.tap(find.text('Esc'));
      await tester.pump();
      expect(cleared, isTrue);
      expect(chosenCategory, isNull);
    });
  });
}
