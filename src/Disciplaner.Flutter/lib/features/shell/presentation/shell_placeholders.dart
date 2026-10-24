import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:disciplaner_flutter/core/widgets/neo_button.dart';
import 'package:disciplaner_flutter/core/widgets/neo_card.dart';
import 'workspace_tabs.dart';

/// VS Code style "welcome" view shown when the workspace has no open tab.
class WorkspaceWelcomeView extends ConsumerWidget {
  const WorkspaceWelcomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(NeoSpacing.space2Xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: NeoColors.sidebarDark,
                  borderRadius: NeoSpacing.roundedMd,
                  border: Border.all(color: NeoColors.sidebarDarkBorder),
                ),
                alignment: Alignment.center,
                child: Text(
                  'D',
                  style: GoogleFonts.ibmPlexMono(
                    color: const Color(0xFFFFD21E),
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: NeoSpacing.spaceLg),
              Text(
                l10n.workspaceWelcomeTitle,
                style: NeoTypography.headlineLg,
              ),
              const SizedBox(height: NeoSpacing.spaceXs),
              Text(
                l10n.workspaceWelcomeHint,
                style: NeoTypography.bodyMd.copyWith(color: NeoColors.muted),
              ),
              const SizedBox(height: NeoSpacing.spaceLg),
              Wrap(
                spacing: NeoSpacing.spaceSm,
                runSpacing: NeoSpacing.spaceSm,
                children: [
                  NeoButton(
                    label: l10n.workspaceOpenDashboard,
                    icon: const Icon(Icons.home_outlined, size: 15),
                    onPressed: () => openDashboardTab(context, ref),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShellPlaceholderView extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const ShellPlaceholderView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(NeoSpacing.spaceLg),
          child: NeoCard(
            hasOverlayShadow: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 28, color: NeoColors.kineticAmber),
                    const SizedBox(width: NeoSpacing.spaceSm),
                    Expanded(
                      child: Text(
                        title,
                        style: NeoTypography.headlineMd,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: NeoSpacing.spaceXs),
                Text(
                  subtitle,
                  style: NeoTypography.bodyMd.copyWith(color: NeoColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
