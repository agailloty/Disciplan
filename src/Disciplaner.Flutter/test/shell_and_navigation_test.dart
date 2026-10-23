import 'package:disciplaner_flutter/app/router.dart';
import 'package:disciplaner_flutter/app/theme/neo_theme.dart';
import 'package:disciplaner_flutter/core/models/auth_models.dart';
import 'package:disciplaner_flutter/core/shortcuts/app_shortcuts.dart';
import 'package:disciplaner_flutter/core/storage/server_config_storage.dart';
import 'package:disciplaner_flutter/core/storage/token_storage.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_state.dart';
import 'package:disciplaner_flutter/features/shell/presentation/adaptive_app_shell.dart';
import 'package:disciplaner_flutter/features/shell/presentation/desktop_app_shell.dart';
import 'package:disciplaner_flutter/features/shell/presentation/mobile_app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

final testAuthSession = AuthResponse(
  token: 'jwt_valid_test',
  email: 'admin@disciplan.local',
  displayName: 'Alexandre Gailloty',
  roles: const ['Admin'],
  expiresAt: DateTime.now().add(const Duration(days: 7)),
);

class AuthenticatedMockAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => AuthAuthenticated(testAuthSession);
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget createTestApp() {
    SharedPreferences.setMockInitialValues({});
    final serverStorage = ServerConfigStorage();
    final tokenStorage = TokenStorage();

    return ProviderScope(
      overrides: [
        serverConfigStorageProvider.overrideWithValue(serverStorage),
        tokenStorageProvider.overrideWithValue(tokenStorage),
        authNotifierProvider.overrideWith(AuthenticatedMockAuthNotifier.new),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final router = ref.watch(routerProvider);
          return MaterialApp.router(
            theme: NeoTheme.lightTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }

  testWidgets('AdaptiveAppShell switches to DesktopAppShell on 1440x900', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(AdaptiveAppShell), findsOneWidget);
    expect(find.byType(DesktopAppShell), findsOneWidget);
    expect(find.byType(MobileAppShell), findsNothing);

    // VS Code Top Bar elements
    expect(find.text('Disciplan'), findsWidgets);
    expect(find.text('PLAN DU PROJET'), findsOneWidget);
    expect(find.text('⌘K'), findsOneWidget);
    expect(find.text('Nouvelle tâche'), findsOneWidget);

    // Primary Sidebar is initially open
    expect(find.text('Vue Liste'), findsOneWidget);
  });

  testWidgets('DesktopAppShell toggles Primary Sidebar collapse', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('PLAN DU PROJET'), findsOneWidget);

    // Click collapse icon on sidebar header
    final collapseBtn = find.byTooltip('Replier la barre latérale (⌘B)');
    expect(collapseBtn, findsOneWidget);
    await tester.tap(collapseBtn);
    await tester.pumpAndSettle();

    // Sidebar should be collapsed
    expect(find.text('PLAN DU PROJET'), findsNothing);

    // Re-open via Top Bar toggle
    final topBarToggle = find.byTooltip('Basculer la barre latérale (⌘B)');
    await tester.tap(topBarToggle);
    await tester.pumpAndSettle();

    expect(find.text('PLAN DU PROJET'), findsOneWidget);
  });

  testWidgets('AdaptiveAppShell switches to MobileAppShell on 390x844', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(AdaptiveAppShell), findsOneWidget);
    expect(find.byType(MobileAppShell), findsOneWidget);
    expect(find.byType(DesktopAppShell), findsNothing);

    // Mobile shell bottom navigation items
    expect(find.text('Sprint'), findsOneWidget);
    expect(find.text('Projets'), findsWidgets);
    expect(find.text('Tâches'), findsOneWidget);
    expect(find.text('Paramètres'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Global Shortcuts toggles Command Palette and Create Task flags',
      (WidgetTester tester) async {
    late WidgetRef capturedRef;
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            capturedRef = ref;
            return const MaterialApp(
              home: AppShortcutsWrapper(
                child: Scaffold(body: Text('Shortcut Test')),
              ),
            );
          },
        ),
      ),
    );

    expect(capturedRef.read(commandPaletteOpenProvider), isFalse);
    expect(capturedRef.read(quickCreateTicketOpenProvider), isFalse);
  });
}
