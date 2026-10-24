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
/// Point d'entrée de l'application : barre de marque, présentation de
/// l'offre, appel à l'action vers l'authentification (ou vers
/// l'application si une session valide existe déjà) et aperçu des
/// fonctionnalités clés.
class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  final GlobalKey _featuresKey = GlobalKey();

  void _scrollToFeatures() {
    final featuresContext = _featuresKey.currentContext;
    if (featuresContext == null) return;
    Scrollable.ensureVisible(
      featuresContext,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = ref.watch(authNotifierProvider);
    final isAuthenticated = authState is AuthAuthenticated;
    // Première installation : le CTA mène à la création du compte admin.
    final needsSetup = authState is AuthNeedsInitialSetup;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= NeoSpacing.mobileBreakpoint;
    final ctaTarget = isAuthenticated
        ? '/dashboard'
        : (needsSetup ? '/setup' : '/login');

    return Scaffold(
      backgroundColor: NeoColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LandingTopBar(isDesktop: isDesktop),
            Expanded(
              child: SingleChildScrollView(
                padding: NeoSpacing.responsivePagePadding(screenWidth),
                child: Column(
                  children: [
                    // 1. Hero : présentation et appel à l'action
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        children: [
                          const SizedBox(height: NeoSpacing.space2Xl),
                          _LandingBadge(label: l10n.landingBadge),
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
                            style: NeoTypography.bodyLg
                                .copyWith(color: NeoColors.muted),
                          ),
                          const SizedBox(height: NeoSpacing.spaceXl),
                          Wrap(
                            spacing: NeoSpacing.spaceSm,
                            runSpacing: NeoSpacing.spaceSm,
                            alignment: WrapAlignment.center,
                            children: [
                              NeoButton(
                                label: isAuthenticated
                                    ? l10n.landingOpenApp
                                    : l10n.landingCtaLogin,
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: () => context.go(ctaTarget),
                              ),
                              NeoButton(
                                label: l10n.landingCtaDiscover,
                                variant: NeoButtonVariant.secondary,
                                onPressed: _scrollToFeatures,
                              ),
                            ],
                          ),
                          const SizedBox(height: NeoSpacing.spaceXs),
                          Text(
                            isAuthenticated
                                ? l10n.landingOpenAppSubtitle
                                : l10n.landingCtaSubtitle,
                            textAlign: TextAlign.center,
                            style: NeoTypography.bodySm
                                .copyWith(color: NeoColors.subdued),
                          ),
                          const SizedBox(height: NeoSpacing.space2Xl),
                        ],
                      ),
                    ),

                    // 2. Fonctionnalités clés
                    ConstrainedBox(
                      key: _featuresKey,
                      constraints: const BoxConstraints(maxWidth: 1080),
                      child: Column(
                        children: [
                          Text(
                            l10n.landingFeaturesTitle,
                            textAlign: TextAlign.center,
                            style: NeoTypography.headlineLg,
                          ),
                          const SizedBox(height: NeoSpacing.spaceLg),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final cols = constraints.maxWidth >= 1080
                                  ? 3
                                  : (constraints.maxWidth >= 640 ? 2 : 1);
                              final gap = NeoSpacing.spaceMd;
                              final width =
                                  (constraints.maxWidth - gap * (cols - 1)) /
                                      cols;
                              final cards = [
                                _LandingFeatureCard(
                                  icon: Icons.folder_outlined,
                                  accent: NeoColors.kineticAmber,
                                  title: l10n.landingFeatureProjectsTitle,
                                  description:
                                      l10n.landingFeatureProjectsDescription,
                                ),
                                _LandingFeatureCard(
                                  icon: Icons.view_kanban_outlined,
                                  accent: NeoColors.emerald,
                                  title: l10n.landingFeatureKanbanTitle,
                                  description:
                                      l10n.landingFeatureKanbanDescription,
                                ),
                                _LandingFeatureCard(
                                  icon: Icons.event_outlined,
                                  accent: NeoColors.statusBlue,
                                  title: l10n.landingFeatureCalendarTitle,
                                  description:
                                      l10n.landingFeatureCalendarDescription,
                                ),
                                _LandingFeatureCard(
                                  icon: Icons.dns_outlined,
                                  accent: NeoColors.secondary,
                                  title: l10n.landingFeatureHomelabTitle,
                                  description:
                                      l10n.landingFeatureHomelabDescription,
                                ),
                              ];
                              return Wrap(
                                spacing: gap,
                                runSpacing: gap,
                                children: [
                                  for (final card in cards)
                                    SizedBox(width: width, child: card),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: NeoSpacing.space2Xl),
                        ],
                      ),
                    ),

                    // 3. Pied de page
                    Text(
                      l10n.landingFooter,
                      textAlign: TextAlign.center,
                      style: NeoTypography.bodySm
                          .copyWith(color: NeoColors.subdued),
                    ),
                    const SizedBox(height: NeoSpacing.spaceXl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Logo et nom de l'application, fixes en haut de la page.
class _LandingTopBar extends StatelessWidget {
  final bool isDesktop;

  const _LandingTopBar({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: NeoSpacing.gutterDesktop,
        vertical: NeoSpacing.spaceSm,
      ),
      decoration: const BoxDecoration(
        color: NeoColors.surface,
        border: Border(bottom: BorderSide(color: NeoColors.borderWhisper)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: NeoColors.primary,
                  borderRadius: NeoSpacing.roundedSm,
                ),
                alignment: Alignment.center,
                child: Text(
                  'D',
                  style: GoogleFonts.jetBrainsMono(
                    color: NeoColors.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: NeoSpacing.spaceSm),
              Text(
                'Disciplan',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: NeoColors.onSurface,
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(width: NeoSpacing.spaceSm),
                Text(
                  '·',
                  style: NeoTypography.bodySm
                      .copyWith(color: NeoColors.subdued),
                ),
                const SizedBox(width: NeoSpacing.spaceSm),
                Text(
                  context.l10n.landingHeroTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NeoTypography.bodySm
                      .copyWith(color: NeoColors.subdued),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Pastille d'accroche affichée au-dessus du titre principal.
class _LandingBadge extends StatelessWidget {
  final String label;

  const _LandingBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLowest,
        borderRadius: NeoSpacing.roundedFull,
        border: Border.all(color: NeoColors.borderWhisper),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: NeoColors.emerald,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: NeoTypography.labelSm.copyWith(
              fontWeight: FontWeight.w600,
              color: NeoColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingFeatureCard extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final String description;

  const _LandingFeatureCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NeoSpacing.spaceMd),
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLowest,
        borderRadius: NeoSpacing.roundedMd,
        border: Border.all(color: NeoColors.borderWhisper),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: NeoSpacing.roundedSm,
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(height: NeoSpacing.spaceSm),
          Text(
            title,
            style: NeoTypography.labelMd.copyWith(
              fontWeight: FontWeight.w700,
              color: NeoColors.onSurface,
            ),
          ),
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
