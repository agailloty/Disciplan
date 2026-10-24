import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'homelab_server_card.dart';

/// Page isolée de configuration de l'URL du serveur API.
///
/// Sur le web, le bloc de saisie de l'URL n'apparaît pas sur les pages
/// publiques (l'application est servie par le conteneur Docker, même
/// origine que l'API). Cette route, non liée depuis l'interface, permet
/// de pointer un autre serveur pour les tests.
class SetupServerScreen extends StatelessWidget {
  const SetupServerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: NeoColors.surface,
      appBar: AppBar(
        backgroundColor: NeoColors.surfaceContainerLow,
        foregroundColor: NeoColors.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(NeoSpacing.spaceLg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.setupServerTitle,
                  style: NeoTypography.headlineLg,
                ),
                const SizedBox(height: NeoSpacing.spaceXs),
                Text(
                  l10n.setupServerSubtitle,
                  style: NeoTypography.bodyMd.copyWith(color: NeoColors.muted),
                ),
                const SizedBox(height: NeoSpacing.spaceLg),
                const HomelabServerCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
