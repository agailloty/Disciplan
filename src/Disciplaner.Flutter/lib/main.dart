import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'app/theme/neo_theme.dart';
import 'core/storage/server_config_storage.dart';
import 'features/auth/presentation/auth_providers.dart';

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
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Disciplan',
      debugShowCheckedModeBanner: false,
      theme: NeoTheme.lightTheme,
      routerConfig: router,
    );
  }
}
