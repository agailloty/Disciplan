import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/theme/neo_colors.dart';
import 'app/theme/neo_spacing.dart';
import 'app/theme/neo_theme.dart';
import 'app/theme/neo_typography.dart';
import 'core/widgets/kbd_chip.dart';
import 'core/widgets/neo_button.dart';
import 'core/widgets/neo_card.dart';
import 'core/widgets/priority_icon.dart';
import 'core/widgets/status_badge.dart';
import 'core/widgets/user_avatar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: DisciplanApp()));
}

class DisciplanApp extends StatelessWidget {
  const DisciplanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disciplan',
      debugShowCheckedModeBanner: false,
      theme: NeoTheme.lightTheme,
      home: const DisciplanShowcaseScreen(),
    );
  }
}

class DisciplanShowcaseScreen extends StatelessWidget {
  const DisciplanShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.surface,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Disciplan Neo-Linear'),
            const SizedBox(width: NeoSpacing.spaceSm),
            const KbdChip(label: '⌘K'),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(NeoSpacing.spaceLg),
            child: NeoCard(
              hasOverlayShadow: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Disciplan Design System', style: NeoTypography.headlineMd),
                  const SizedBox(height: NeoSpacing.spaceXs),
                  Text(
                    'Socle Flutter multiplateforme initialisé avec succès.',
                    style: NeoTypography.bodyMd.copyWith(color: NeoColors.muted),
                  ),
                  const SizedBox(height: NeoSpacing.spaceMd),
                  const Wrap(
                    spacing: NeoSpacing.spaceSm,
                    runSpacing: NeoSpacing.spaceSm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      StatusBadge(label: 'To Do', category: TicketStatusCategory.todo),
                      StatusBadge(label: 'In Progress', category: TicketStatusCategory.inProgress),
                      StatusBadge(label: 'Done', category: TicketStatusCategory.done),
                      PriorityIcon(priority: TicketPriority.urgent),
                      PriorityIcon(priority: TicketPriority.high),
                      UserAvatar(name: 'Alexandre Gailloty', isOnline: true),
                    ],
                  ),
                  const SizedBox(height: NeoSpacing.spaceLg),
                  Row(
                    children: [
                      NeoButton(
                        label: 'Commencer',
                        onPressed: () {},
                      ),
                      const SizedBox(width: NeoSpacing.spaceSm),
                      NeoButton(
                        label: 'En savoir plus',
                        variant: NeoButtonVariant.secondary,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
