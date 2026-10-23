import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:disciplaner_flutter/core/widgets/neo_button.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_state.dart';

/// Page d'accueil publique de Disciplan.
///
/// Point d'entrée de l'application : présentation brève de l'offre et appel
/// à l'action vers l'authentification (ou vers l'application si une session
/// valide existe déjà).
class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final authState = ref.watch(authNotifierProvider);
    final isAuthenticated = authState is AuthAuthenticated;

    return Scaffold(
      backgroundColor: NeoColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(NeoSpacing.spaceLg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: NeoColors.primary,
                      borderRadius: NeoSpacing.roundedMd,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'D',
                      style: GoogleFonts.jetBrainsMono(
                        color: NeoColors.onPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: NeoSpacing.spaceLg),
                  Text(
                    l10n.landingHeroTitle,
                    textAlign: TextAlign.center,
                    style: NeoTypography.headlineXl,
                  ),
                  const SizedBox(height: NeoSpacing.spaceSm),
                  Text(
                    l10n.landingHeroSubtitle,
                    textAlign: TextAlign.center,
                    style: NeoTypography.bodyLg.copyWith(color: NeoColors.muted),
                  ),
                  const SizedBox(height: NeoSpacing.spaceXl),

                  // Appel à l'action : s'authentifier
                  NeoButton(
                    label: isAuthenticated
                        ? l10n.landingOpenApp
                        : l10n.landingCtaLogin,
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () =>
                        context.go(isAuthenticated ? '/dashboard' : '/login'),
                  ),
                  const SizedBox(height: NeoSpacing.spaceXs),
                  Text(
                    isAuthenticated
                        ? l10n.landingOpenAppSubtitle
                        : l10n.landingCtaSubtitle,
                    style: NeoTypography.bodySm.copyWith(color: NeoColors.subdued),
                  ),
                  const SizedBox(height: NeoSpacing.spaceXl),

                  // Aperçu des fonctionnalités
                  Wrap(
                    spacing: NeoSpacing.spaceMd,
                    runSpacing: NeoSpacing.spaceMd,
                    alignment: WrapAlignment.center,
                    children: [
                      _LandingFeatureCard(
                        icon: Icons.folder_outlined,
                        title: l10n.landingFeatureProjectsTitle,
                        description: l10n.landingFeatureProjectsDescription,
                      ),
                      _LandingFeatureCard(
                        icon: Icons.view_kanban_outlined,
                        title: l10n.landingFeatureKanbanTitle,
                        description: l10n.landingFeatureKanbanDescription,
                      ),
                      _LandingFeatureCard(
                        icon: Icons.event_outlined,
                        title: l10n.landingFeatureCalendarTitle,
                        description: l10n.landingFeatureCalendarDescription,
                      ),
                    ],
                  ),
                  const SizedBox(height: NeoSpacing.spaceXl),
                  Text(
                    l10n.landingFooter,
                    style: NeoTypography.bodySm.copyWith(color: NeoColors.subdued),
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

class _LandingFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _LandingFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(NeoSpacing.spaceMd),
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLowest,
        borderRadius: NeoSpacing.roundedMd,
        border: Border.all(color: NeoColors.borderWhisper),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: NeoColors.primary),
          const SizedBox(height: NeoSpacing.spaceSm),
          Text(title, style: NeoTypography.headlineSm),
          const SizedBox(height: NeoSpacing.spaceXs),
          Text(
            description,
            style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
          ),
        ],
      ),
    );
  }
}
