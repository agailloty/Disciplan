import 'dart:async';

import 'package:disciplaner_flutter/app/router.dart';
import 'package:disciplaner_flutter/app/theme/neo_theme.dart';
import 'package:disciplaner_flutter/core/models/auth_models.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/core/storage/server_config_storage.dart';
import 'package:disciplaner_flutter/core/storage/token_storage.dart';
import 'package:disciplaner_flutter/features/auth/data/auth_repository.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import 'package:disciplaner_flutter/features/auth/presentation/landing_screen.dart';
import 'package:disciplaner_flutter/features/auth/presentation/login_screen.dart';
import 'package:disciplaner_flutter/features/dashboard/presentation/dashboard_screen.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/ticket_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:disciplaner_flutter/l10n/app_localizations.dart';

class FakeMyTasksNotifier extends MyTasksNotifier {
  final List<TicketDto> tickets;
  FakeMyTasksNotifier(this.tickets);

  @override
  Future<List<TicketDto>> build() async => tickets;
}

/// Repository d'authentification piloté par test : le login ne se termine
/// que lorsque le test complète [loginCompleter].
class FakeAuthRepository implements IAuthRepository {
  final Completer<AuthResponse> loginCompleter = Completer<AuthResponse>();
  bool loginCalled = false;
  Object? loginError;

  @override
  Future<SetupStatusResponse> getSetupStatus() async =>
      SetupStatusResponse(setupRequired: false);

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    loginCalled = true;
    if (loginError != null) throw loginError!;
    return loginCompleter.future;
  }

  @override
  Future<AuthResponse> executeSetup(SetupRequest request) async =>
      throw UnimplementedError();

  @override
  Future<AuthResponse> register(RegisterRequest request) async =>
      throw UnimplementedError();

  @override
  Future<AuthResponse> refresh() async => throw UnimplementedError();

  @override
  Future<InvitationInfoResponse> getInvitation(String token) async =>
      throw UnimplementedError();

  @override
  Future<AuthResponse> registerInvited(InvitationRegisterRequest request) async =>
      throw UnimplementedError();
}

final testSession = AuthResponse(
  token: 'jwt-login-flow-token',
  email: 'admin@disciplan.test',
  displayName: 'Alexandre M.',
  roles: const ['Admin'],
  expiresAt: DateTime.now().add(const Duration(days: 7)),
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late FakeAuthRepository fakeAuthRepo;
  late WidgetRef capturedRef;

  Future<void> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final serverStorage = ServerConfigStorage();
    final tokenStorage = TokenStorage();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          serverConfigStorageProvider.overrideWithValue(serverStorage),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          authNotifierProvider.overrideWith(
            () => AuthNotifier(
              authRepo: fakeAuthRepo,
              tokenStorage: TokenStorage(),
              serverStorage: ServerConfigStorage(),
            ),
          ),
          projectsListProvider.overrideWith((ref) async => []),
          myTasksProvider.overrideWith(() => FakeMyTasksNotifier([])),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            capturedRef = ref;
            return MaterialApp.router(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('fr'),
              theme: NeoTheme.lightTheme,
              routerConfig: ref.watch(routerProvider),
            );
          },
        ),
      ),
    );
  }

  Future<void> goToLogin(WidgetTester tester) async {
    await pumpApp(tester);
    await capturedRef.read(authNotifierProvider.notifier).checkStatusAndSession();
    await tester.pumpAndSettle();
    expect(find.byType(LandingScreen), findsOneWidget);

    capturedRef.read(routerProvider).go('/login');
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'admin@disciplan.test');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
  }

  testWidgets(
      'la connexion ne renvoie pas sur la page de présentation pendant le chargement',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    fakeAuthRepo = FakeAuthRepository();
    await goToLogin(tester);

    await tester.tap(find.text('Se connecter'));
    await tester.pump();

    // La requête est en vol : l'écran de connexion reste affiché, la page de
    // présentation ne doit pas réapparaître (régression : le routeur ne doit
    // pas être recréé).
    expect(fakeAuthRepo.loginCalled, isTrue);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(LandingScreen), findsNothing);

    fakeAuthRepo.loginCompleter.complete(testSession);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(LandingScreen), findsNothing);
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets(
      'un échec de connexion affiche l\'erreur sur l\'écran de connexion',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    fakeAuthRepo = FakeAuthRepository()..loginError = Exception('identifiants invalides');
    await goToLogin(tester);

    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(LandingScreen), findsNothing);
    expect(find.byType(DashboardScreen), findsNothing);
  });
}
