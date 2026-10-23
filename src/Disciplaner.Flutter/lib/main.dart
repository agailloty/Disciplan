import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/theme/neo_colors.dart';
import 'app/theme/neo_spacing.dart';
import 'app/theme/neo_theme.dart';
import 'app/theme/neo_typography.dart';
import 'core/storage/server_config_storage.dart';
import 'core/widgets/kbd_chip.dart';
import 'core/widgets/neo_button.dart';
import 'core/widgets/neo_card.dart';
import 'core/widgets/priority_icon.dart';
import 'core/widgets/status_badge.dart';
import 'core/widgets/user_avatar.dart';
import 'features/auth/presentation/auth_providers.dart';
import 'features/auth/presentation/auth_state.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final serverStorage = await ServerConfigStorage.create();

  runApp(
    ProviderScope(
      overrides: [
        serverConfigStorageProvider.overrideWithValue(serverStorage),
      ],
      child: const DisciplanApp(),
    ),
  );
}

class DisciplanApp extends ConsumerStatefulWidget {
  const DisciplanApp({super.key});

  @override
  ConsumerState<DisciplanApp> createState() => _DisciplanAppState();
}

class _DisciplanAppState extends ConsumerState<DisciplanApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).checkStatusAndSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return MaterialApp(
      title: 'Disciplan',
      debugShowCheckedModeBanner: false,
      theme: NeoTheme.lightTheme,
      home: switch (authState) {
        AuthNeedsInitialSetup() => const SetupScreen(),
        AuthUnauthenticated() || AuthUnconfiguredServer() => const LoginScreen(),
        AuthAuthenticated(:final session) => DisciplanShowcaseScreen(
            userName: session.displayName,
            userEmail: session.email,
          ),
        _ => const Scaffold(
            backgroundColor: NeoColors.surface,
            body: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      },
    );
  }
}

class DisciplanShowcaseScreen extends ConsumerWidget {
  final String userName;
  final String userEmail;

  const DisciplanShowcaseScreen({
    super.key,
    this.userName = 'Alexandre Gailloty',
    this.userEmail = 'alexandre@disciplan.local',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                UserAvatar(name: userName, isOnline: true),
                const SizedBox(width: NeoSpacing.spaceSm),
                IconButton(
                  icon: const Icon(Icons.logout, size: 18),
                  tooltip: 'Déconnexion',
                  onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
                ),
              ],
            ),
          ),
        ],
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
                  Text('Disciplan Connecté', style: NeoTypography.headlineMd),
                  const SizedBox(height: NeoSpacing.spaceXs),
                  Text(
                    'Connecté en tant que $userName ($userEmail).',
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
                    ],
                  ),
                  const SizedBox(height: NeoSpacing.spaceLg),
                  Row(
                    children: [
                      NeoButton(
                        label: 'Se déconnecter',
                        variant: NeoButtonVariant.secondary,
                        onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
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
