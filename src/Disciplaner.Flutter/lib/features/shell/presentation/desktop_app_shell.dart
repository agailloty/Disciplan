import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/shortcuts/app_shortcuts.dart';
import 'package:disciplaner_flutter/core/widgets/kbd_chip.dart';
import 'package:disciplaner_flutter/core/widgets/neo_button.dart';
import 'package:disciplaner_flutter/core/widgets/user_avatar.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_state.dart';

class DesktopAppShell extends ConsumerWidget {
  final Widget child;
  final String currentRoute;

  const DesktopAppShell({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isSidebarCollapsed = ref.watch(sidebarCollapsedProvider);
    final user = authState is AuthAuthenticated ? authState.session : null;

    return Scaffold(
      backgroundColor: NeoColors.surface,
      body: Column(
        children: [
          // 1. TOP TITLE / COMMAND BAR (44px)
          _buildTopBar(context, ref, user),

          // 2. MAIN LAYOUT (ACTIVITY BAR + PRIMARY SIDEBAR + WORKSPACE)
          Expanded(
            child: Row(
              children: [
                // A. Activity Bar (52px sombre #181715)
                _buildActivityBar(context, ref, user),

                // B. Primary Sidebar repliable (240px fond #F4F1EA)
                if (!isSidebarCollapsed) _buildPrimarySidebar(context, ref),

                // C. Zone centrale de travail (Workspace)
                Expanded(
                  child: Container(
                    color: NeoColors.surface,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, WidgetRef ref, dynamic user) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: NeoColors.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: NeoColors.borderWhisper, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Breadcrumb façon VS Code
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE5A912),
                ),
              ),
              const SizedBox(width: NeoSpacing.spaceSm),
              Text(
                'Disciplan',
                style: NeoTypography.headlineSm.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Icon(Icons.chevron_right, size: 16, color: NeoColors.subdued),
              Text(
                _breadcrumbSectionName(),
                style: NeoTypography.bodyMd.copyWith(
                  fontSize: 13,
                  color: NeoColors.onSurfaceVariant,
                ),
              ),
              const Icon(Icons.chevron_right, size: 16, color: NeoColors.subdued),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: NeoColors.surfaceContainerHigh,
                  borderRadius: NeoSpacing.roundedSm,
                ),
                child: Text(
                  'Cycle 1',
                  style: NeoTypography.labelSm.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          // Center Quick Search / Command Palette Trigger
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: InkWell(
                  onTap: () {
                    ref.read(commandPaletteOpenProvider.notifier).toggle();
                  },
                  borderRadius: NeoSpacing.roundedSm,
                  child: Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: NeoColors.surfaceContainerLowest,
                      borderRadius: NeoSpacing.roundedSm,
                      border: Border.all(color: NeoColors.borderWhisper, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.search, size: 15, color: NeoColors.subdued),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Rechercher une tâche, commande ou fichier...',
                                  overflow: TextOverflow.ellipsis,
                                  style: NeoTypography.bodySm.copyWith(
                                    color: NeoColors.subdued,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const KbdChip(label: '⌘K'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Quick actions droites
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.filter_alt_outlined, size: 17),
                tooltip: 'Filtrer la vue',
                visualDensity: VisualDensity.compact,
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.vertical_split_outlined, size: 17),
                tooltip: 'Basculer la barre latérale (⌘B)',
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  ref.read(sidebarCollapsedProvider.notifier).toggle();
                },
              ),
              const SizedBox(width: NeoSpacing.spaceSm),
              NeoButton(
                label: 'Nouvelle tâche',
                isDense: true,
                icon: const Icon(Icons.add, size: 14),
                onPressed: () {
                  ref.read(quickCreateTicketOpenProvider.notifier).toggle();
                },
              ),
              const SizedBox(width: NeoSpacing.spaceSm),
              UserAvatar(
                name: user?.displayName ?? 'Admin',
                isOnline: true,
                size: 26,
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.logout, size: 16),
                tooltip: 'Déconnexion',
                visualDensity: VisualDensity.compact,
                onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBar(BuildContext context, WidgetRef ref, dynamic user) {
    return Container(
      width: 52,
      color: NeoColors.sidebarDark,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top icons
          Column(
            children: [
              const SizedBox(height: 8),
              // Brand Logo Box
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2A26),
                  borderRadius: NeoSpacing.roundedSm,
                  border: Border.all(color: const Color(0xFF3E3C36), width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  'D',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFFFFD21E),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildActivityItem(
                icon: Icons.folder_copy_outlined,
                tooltip: 'Explorateur de projets',
                isActive: currentRoute.startsWith('/projects'),
                onTap: () => context.go('/projects'),
              ),
              _buildActivityItem(
                icon: Icons.checklist_outlined,
                tooltip: 'Mes Tâches',
                isActive: currentRoute.startsWith('/my-tasks'),
                badgeText: '4',
                onTap: () => context.go('/my-tasks'),
              ),
              _buildActivityItem(
                icon: Icons.view_kanban_outlined,
                tooltip: 'Tableau Kanban',
                isActive: currentRoute.startsWith('/kanban'),
                onTap: () => context.go('/kanban'),
              ),
              _buildActivityItem(
                icon: Icons.timelapse_outlined,
                tooltip: 'Cycles & Feuille de route',
                isActive: currentRoute.startsWith('/cycles'),
                onTap: () => context.go('/cycles'),
              ),
              _buildActivityItem(
                icon: Icons.calendar_today_outlined,
                tooltip: 'Calendrier d\'équipe',
                isActive: currentRoute.startsWith('/calendar'),
                onTap: () => context.go('/calendar'),
              ),
              _buildActivityItem(
                icon: Icons.search,
                tooltip: 'Recherche globale (⌘K)',
                isActive: false,
                onTap: () {
                  ref.read(commandPaletteOpenProvider.notifier).toggle();
                },
              ),
            ],
          ),

          // Bottom icons
          Column(
            children: [
              _buildActivityItem(
                icon: Icons.settings_outlined,
                tooltip: 'Paramètres (⌘,)',
                isActive: currentRoute.startsWith('/settings'),
                onTap: () => context.go('/settings'),
              ),
              const SizedBox(height: 8),
              UserAvatar(
                name: user?.displayName ?? 'Admin',
                isOnline: true,
                size: 26,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String tooltip,
    required bool isActive,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 300),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isActive)
                Positioned(
                  left: 0,
                  top: 10,
                  bottom: 10,
                  child: Container(
                    width: 3,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD21E),
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(2)),
                    ),
                  ),
                ),
              Icon(
                icon,
                size: 20,
                color: isActive ? Colors.white : const Color(0xFFABA8A0),
              ),
              if (badgeText != null)
                Positioned(
                  top: 6,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD21E),
                      borderRadius: NeoSpacing.roundedFull,
                    ),
                    child: Text(
                      badgeText,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: NeoColors.sidebarDark,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimarySidebar(BuildContext context, WidgetRef ref) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: Color(0xFFF4F1EA),
        border: Border(
          right: BorderSide(color: NeoColors.borderWhisper, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Sidebar Header
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: NeoColors.borderWhisper, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PLAN DU PROJET',
                  style: NeoTypography.labelSm.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: NeoColors.onSurfaceVariant,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.dock, size: 15, color: NeoColors.muted),
                  tooltip: 'Replier la barre latérale (⌘B)',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    ref.read(sidebarCollapsedProvider.notifier).set(true);
                  },
                ),
              ],
            ),
          ),

          // Sidebar Navigation Tree items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              children: [
                _buildSidebarItem(
                  context,
                  title: 'Vue Liste',
                  icon: Icons.format_list_bulleted,
                  isSelected: currentRoute == '/projects',
                  badge: '12',
                  onTap: () => context.go('/projects'),
                ),
                _buildSidebarItem(
                  context,
                  title: 'Tableau Kanban',
                  icon: Icons.view_kanban,
                  isSelected: currentRoute == '/kanban',
                  badge: '8',
                  onTap: () => context.go('/kanban'),
                ),
                _buildSidebarItem(
                  context,
                  title: 'Sprints & Cycles',
                  icon: Icons.timelapse,
                  isSelected: currentRoute == '/cycles',
                  onTap: () => context.go('/cycles'),
                ),
                _buildSidebarItem(
                  context,
                  title: 'Mes Tâches',
                  icon: Icons.checklist,
                  isSelected: currentRoute == '/my-tasks',
                  badge: '4',
                  onTap: () => context.go('/my-tasks'),
                ),
                _buildSidebarItem(
                  context,
                  title: 'Calendrier',
                  icon: Icons.calendar_today,
                  isSelected: currentRoute == '/calendar',
                  onTap: () => context.go('/calendar'),
                ),
                _buildSidebarItem(
                  context,
                  title: 'Paramètres',
                  icon: Icons.settings,
                  isSelected: currentRoute == '/settings',
                  onTap: () => context.go('/settings'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isSelected ? NeoColors.surfaceContainerHighest : Colors.transparent,
        borderRadius: NeoSpacing.roundedSm,
        child: InkWell(
          onTap: onTap,
          borderRadius: NeoSpacing.roundedSm,
          hoverColor: NeoColors.surfaceContainerHigh,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: isSelected ? NeoColors.kineticAmber : NeoColors.muted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: NeoTypography.bodySm.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? NeoColors.primary : NeoColors.onSurfaceVariant,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected ? NeoColors.surfaceContainerLowest : NeoColors.surfaceContainerHigh,
                      borderRadius: NeoSpacing.roundedSm,
                    ),
                    child: Text(
                      badge,
                      style: NeoTypography.labelSm.copyWith(fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _breadcrumbSectionName() {
    if (currentRoute.startsWith('/projects')) return 'Projets';
    if (currentRoute.startsWith('/my-tasks')) return 'Mes Tâches';
    if (currentRoute.startsWith('/kanban')) return 'Tableau Kanban';
    if (currentRoute.startsWith('/cycles')) return 'Cycles & Sprints';
    if (currentRoute.startsWith('/calendar')) return 'Calendrier';
    if (currentRoute.startsWith('/settings')) return 'Paramètres';
    return 'Espace';
  }
}
