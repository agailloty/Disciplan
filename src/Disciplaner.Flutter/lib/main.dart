import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/router.dart';
import 'app/theme/neo_theme.dart';
import 'core/l10n/locale_providers.dart';
import 'core/storage/server_config_storage.dart';
import 'features/auth/presentation/auth_providers.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await initializeDateFormatting('en_US', null);
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
      ref.read(localeProvider.notifier).load();
      ref.read(authNotifierProvider.notifier).checkStatusAndSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: NeoTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      routerConfig: router,
    );
  }
}
