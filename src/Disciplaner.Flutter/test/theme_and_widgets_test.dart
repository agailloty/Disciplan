import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_theme.dart';
import 'package:disciplaner_flutter/core/widgets/kbd_chip.dart';
import 'package:disciplaner_flutter/core/widgets/neo_button.dart';
import 'package:disciplaner_flutter/core/widgets/neo_card.dart';
import 'package:disciplaner_flutter/core/widgets/neo_text_field.dart';
import 'package:disciplaner_flutter/core/widgets/priority_icon.dart';
import 'package:disciplaner_flutter/core/widgets/status_badge.dart';
import 'package:disciplaner_flutter/core/widgets/user_avatar.dart';
import 'package:disciplaner_flutter/features/shell/presentation/shell_placeholders.dart';
import 'package:disciplaner_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:disciplaner_flutter/l10n/app_localizations.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('NeoTheme instantiates with correct tokens', () {
    final theme = NeoTheme.lightTheme;
    expect(theme.scaffoldBackgroundColor, NeoColors.surface);
    expect(theme.colorScheme.primary, NeoColors.primary);
    expect(theme.dividerColor, NeoColors.borderWhisper);
  });

  testWidgets('Renders atomic components: KbdChip, StatusBadge, PriorityIcon, UserAvatar, NeoButton',
      (WidgetTester tester) async {
    bool clicked = false;

    await tester.pumpWidget(
      MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
        theme: NeoTheme.lightTheme,
        home: Scaffold(
          body: Column(
            children: [
              const KbdChip(label: '⌘K'),
              const StatusBadge(label: 'In Progress', category: TicketStatusCategory.inProgress),
              const PriorityIcon(priority: TicketPriority.urgent),
              const TicketTypeIcon(type: TicketType.bug),
              const UserAvatar(name: 'Marie Curie', isOnline: true),
              const NeoCard(child: Text('Card Content')),
              const NeoTextField(hintText: 'Rechercher un ticket...'),
              NeoButton(
                label: 'Enregistrer',
                onPressed: () => clicked = true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('⌘K'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.byType(PriorityIcon), findsOneWidget);
    expect(find.byType(TicketTypeIcon), findsOneWidget);
    expect(find.text('MC'), findsOneWidget);
    expect(find.text('Card Content'), findsOneWidget);
    expect(find.text('Enregistrer'), findsOneWidget);

    await tester.tap(find.text('Enregistrer'));
    expect(clicked, isTrue);
  });

  testWidgets('Renders ShellPlaceholderView directly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
        home: Scaffold(
          body: ShellPlaceholderView(
            title: 'Explorateur de Projets',
            subtitle: 'Navigation dans les projets.',
            icon: Icons.folder,
          ),
        ),
      ),
    );
    expect(find.text('Explorateur de Projets'), findsOneWidget);
    expect(find.text('Navigation dans les projets.'), findsOneWidget);
  });

  testWidgets('Renders DisciplanApp login on initial unauthenticated run', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DisciplanApp()));
    await tester.pumpAndSettle();

    expect(find.text('Connexion à Disciplan'), findsOneWidget);
  });
}
