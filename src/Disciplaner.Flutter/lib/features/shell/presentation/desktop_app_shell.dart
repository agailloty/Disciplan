import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:disciplaner_flutter/core/shortcuts/app_shortcuts.dart';
import 'package:disciplaner_flutter/core/widgets/kbd_chip.dart';
import 'package:disciplaner_flutter/core/widgets/neo_button.dart';
import 'package:disciplaner_flutter/core/widgets/user_avatar.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_state.dart';
import 'package:disciplaner_flutter/features/activity/presentation/activity_drawer.dart';
import 'package:disciplaner_flutter/features/projects/presentation/create_project_modal.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';
import 'package:disciplaner_flutter/features/search/presentation/command_palette_modal.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/desktop_create_ticket_dialog.dart';
import 'package:disciplaner_flutter/features/shell/presentation/workspace_tab_bar.dart';
import 'package:disciplaner_flutter/features/shell/presentation/workspace_tabs.dart';

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
    ref.listen<bool>(quickCreateTicketOpenProvider, (prev, current) {
      if (current) {
        ref.read(quickCreateTicketOpenProvider.notifier).set(false);
        DesktopCreateTicketDialog.show(context);
      }
    });

    ref.listen<bool>(commandPaletteOpenProvider, (prev, current) {
      if (current) {
        ref.read(commandPaletteOpenProvider.notifier).set(false);
        CommandPaletteModal.show(context);
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final user = authState is AuthAuthenticated ? authState.session : null;
    final currentProject = ref.watch(currentProjectDetailProvider).value;
    final openTabs = ref.watch(workspaceTabsProvider);
    _syncTabsWithRoute(ref, openTabs);

    return Scaffold(
      backgroundColor: NeoColors.surface,
      body: Column(
        children: [
          // 1. TOP TITLE / COMMAND BAR (44px)
          _buildTopBar(context, ref, user, currentProject),

          // 2. MAIN LAYOUT (ACTIVITY BAR + WORKSPACE)
          Expanded(
            child: Row(
              children: [
                // A. Activity Bar (52px sombre #181715)
                _buildActivityBar(context, ref, user),

                // B. Zone centrale de travail (Workspace + onglets VS Code)
                Expanded(
                  child: Container(
                    color: NeoColors.surface,
                    child: Column(
                      children: [
                        if (openTabs.isNotEmpty)
                          WorkspaceTabBar(currentRoute: currentRoute),
                        Expanded(child: child),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Keeps the open tabs in sync with the current route: navigating to the
  /// dashboard or a project workspace opens (or focuses) its tab, exactly
  /// like opening a file in VS Code.
  void _syncTabsWithRoute(WidgetRef ref, List<WorkspaceTab> tabs) {
    if (currentRoute == '/dashboard') {
      if (!tabs.any((t) => t.type == WorkspaceTabType.dashboard)) {
        Future.microtask(
          () => ref.read(workspaceTabsProvider.notifier).openDashboard(),
        );
      }
      return;
    }

    final routeProjectId = projectIdFromRoute(currentRoute);
    if (routeProjectId != null) {
      final projects = ref.read(projectsListProvider).value ?? const [];
      final project = projects
          .where((p) => p.id == routeProjectId)
          .firstOrNull;
      Future.microtask(
        () => ref.read(workspaceTabsProvider.notifier).openProject(
              projectId: routeProjectId,
              title: project?.name ?? routeProjectId,
              projectKey: project?.key,
            ),
      );
    }
  }

  Widget _buildTopBar(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    dynamic currentProject,
  ) {
    final projects = ref.watch(projectsListProvider).value ?? [];
    final uiScale = ref.watch(uiScaleProvider);
    final l10n = context.l10n;

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: NeoColors.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: NeoColors.borderWhisper, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Breadcrumb contextuel avec sélecteur de projet direct
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
              InkWell(
                onTap: () => openDashboardTab(context, ref),
                borderRadius: NeoSpacing.roundedSm,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    l10n.appTitle,
                    style: NeoTypography.headlineSm.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, size: 16, color: NeoColors.subdued),
              PopupMenuButton<String>(
                tooltip: l10n.shellSwitchProject,
                shape: RoundedRectangleBorder(
                  borderRadius: NeoSpacing.roundedMd,
                  side: const BorderSide(color: NeoColors.borderWhisper),
                ),
                onSelected: (val) {
                  if (val == 'NEW') {
                    CreateProjectModal.show(context);
                  } else {
                    openProjectTab(context, ref, projectId: val);
                  }
                },
                itemBuilder: (context) => [
                  ...projects.map(
                    (p) => PopupMenuItem(
                      value: p.id,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: NeoColors.surfaceContainerHigh,
                              borderRadius: NeoSpacing.roundedSm,
                            ),
                            child: Text(p.key, style: NeoTypography.codeSm),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(p.name, style: NeoTypography.bodySm)),
                        ],
                      ),
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'NEW',
                    child: Row(
                      children: [
                        const Icon(Icons.add, size: 16),
                        const SizedBox(width: 8),
                        Text(l10n.projectCreateTitle),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: NeoColors.surfaceContainerLowest,
                    borderRadius: NeoSpacing.roundedSm,
                    border: Border.all(color: NeoColors.borderWhisper),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (currentProject != null) ...[
                        Text(
                          currentProject.key,
                          style: NeoTypography.codeSm.copyWith(
                            color: NeoColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        currentProject?.name ?? l10n.shellSelectProject,
                        style: NeoTypography.bodySm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: NeoColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.unfold_more, size: 14, color: NeoColors.muted),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, size: 16, color: NeoColors.subdued),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: NeoColors.kineticAmber.withValues(alpha: 0.14),
                  borderRadius: NeoSpacing.roundedSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_breadcrumbSectionIcon(), size: 13, color: NeoColors.secondary),
                    const SizedBox(width: 5),
                    Text(
                      _breadcrumbSectionName(l10n),
                      style: NeoTypography.labelSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: NeoColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Center Quick Search / Command Palette Trigger
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: InkWell(
                  onTap: () {
                    ref.read(commandPaletteOpenProvider.notifier).toggle();
                  },
                  borderRadius: NeoSpacing.roundedMd,
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: NeoColors.surfaceContainerLowest,
                      borderRadius: NeoSpacing.roundedMd,
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
                                  l10n.shellSearchPlaceholder,
                                  overflow: TextOverflow.ellipsis,
                                  style: NeoTypography.bodySm.copyWith(
                                    color: NeoColors.subdued,
                                    fontSize: 12.5,
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

          // Quick actions droites + Contrôle de zoom d'interface (UI Scale)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PopupMenuButton<double>(
                tooltip: l10n.shellDisplaySize((uiScale * 100).round()),
                shape: RoundedRectangleBorder(
                  borderRadius: NeoSpacing.roundedMd,
                  side: const BorderSide(color: NeoColors.borderWhisper),
                ),
                onSelected: (scale) {
                  if (scale == -1.0) {
                    _showCustomScaleDialog(context, ref, uiScale);
                  } else {
                    ref.read(uiScaleProvider.notifier).setScale(scale);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 0.9, child: Text(l10n.shellScaleCompact)),
                  PopupMenuItem(value: 1.0, child: Text(l10n.shellScaleStandard)),
                  PopupMenuItem(value: 1.1, child: Text(l10n.shellScaleComfort)),
                  PopupMenuItem(value: 1.2, child: Text(l10n.shellScaleLarge)),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: -1.0,
                    child: Row(
                      children: [
                        const Icon(Icons.tune, size: 15, color: NeoColors.secondary),
                        const SizedBox(width: 8),
                        Text(
                          l10n.shellScaleCustom((uiScale * 100).round()),
                          style: NeoTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: NeoColors.surfaceContainerLowest,
                    borderRadius: NeoSpacing.roundedSm,
                    border: Border.all(color: NeoColors.borderWhisper),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.text_fields, size: 14, color: NeoColors.muted),
                      const SizedBox(width: 4),
                      Text(
                        '${(uiScale * 100).round()}%',
                        style: NeoTypography.codeSm.copyWith(fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Le bouton de création rapide n'est visible que sur
              // l'écran d'accueil.
              if (currentRoute == '/dashboard')
                NeoButton(
                  label: l10n.shellNewTask,
                  isDense: true,
                  icon: const Icon(Icons.add, size: 14),
                  onPressed: () {
                    DesktopCreateTicketDialog.show(context);
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
                tooltip: l10n.navLogout,
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
    final l10n = context.l10n;

    return Container(
      width: 54,
      color: NeoColors.sidebarDark,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top icons
          Column(
            children: [
              const SizedBox(height: 10),
              // Brand Logo Box
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2A26),
                  borderRadius: NeoSpacing.roundedMd,
                  border: Border.all(color: const Color(0xFF3E3C36), width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  'D',
                  style: GoogleFonts.ibmPlexMono(
                    color: const Color(0xFFFFD21E),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildActivityItem(
                icon: Icons.home_outlined,
                tooltip: l10n.shellTooltipDashboard,
                isActive: currentRoute == '/dashboard',
                onTap: () => openDashboardTab(context, ref),
              ),
              _buildActivityItem(
                icon: Icons.view_kanban_outlined,
                tooltip: l10n.shellTooltipKanban,
                isActive: currentRoute.startsWith('/kanban'),
                onTap: () => context.go('/kanban'),
              ),
              _buildActivityItem(
                icon: Icons.inbox_outlined,
                tooltip: l10n.shellTooltipBacklog,
                isActive: currentRoute.startsWith('/backlog') ||
                    currentRoute.startsWith('/projects/'),
                onTap: () => context.go('/backlog'),
              ),
              _buildActivityItem(
                icon: Icons.timelapse_outlined,
                tooltip: l10n.shellTooltipCycles,
                isActive: currentRoute.startsWith('/cycles'),
                onTap: () => context.go('/cycles'),
              ),
              _buildActivityItem(
                icon: Icons.calendar_today_outlined,
                tooltip: l10n.shellTooltipCalendar,
                isActive: currentRoute.startsWith('/calendar'),
                onTap: () => context.go('/calendar'),
              ),
              _buildActivityItem(
                icon: Icons.search,
                tooltip: l10n.shellTooltipSearch,
                isActive: false,
                onTap: () {
                  ref.read(commandPaletteOpenProvider.notifier).toggle();
                },
              ),
              _buildActivityItem(
                icon: Icons.notifications_none_outlined,
                tooltip: l10n.homeActivity,
                isActive: false,
                onTap: () {
                  ActivityDrawer.show(context);
                },
              ),
            ],
          ),

          // Bottom icons
          Column(
            children: [
              _buildActivityItem(
                icon: Icons.settings_outlined,
                tooltip: l10n.shellTooltipSettings,
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
      waitDuration: const Duration(milliseconds: 250),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 54,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isActive)
                Positioned(
                  left: 0,
                  top: 9,
                  bottom: 9,
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
                  right: 7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD21E),
                      borderRadius: NeoSpacing.roundedFull,
                    ),
                    child: Text(
                      badgeText,
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 9.5,
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

  void _showCustomScaleDialog(
    BuildContext context,
    WidgetRef ref,
    double initialScale,
  ) {
    final l10n = context.l10n;
    final controller = TextEditingController(
      text: '${(initialScale * 100).round()}',
    );
    double tempScale = initialScale;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: NeoColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: NeoSpacing.roundedLg,
            side: const BorderSide(color: NeoColors.borderWhisper),
          ),
          title: Text(
            l10n.shellScaleCustomTitle,
            style: NeoTypography.headlineSm,
          ),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.shellScaleCustomHint,
                  style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                ),
                const SizedBox(height: NeoSpacing.spaceMd),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: tempScale.clamp(0.50, 2.00),
                        min: 0.50,
                        max: 2.00,
                        divisions: 30,
                        activeColor: NeoColors.primary,
                        label: '${(tempScale * 100).round()}%',
                        onChanged: (val) {
                          setDialogState(() {
                            tempScale = val;
                            controller.text = '${(val * 100).round()}';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          suffixText: '%',
                          border: OutlineInputBorder(
                            borderRadius: NeoSpacing.roundedSm,
                          ),
                        ),
                        onChanged: (val) {
                          final parsed = double.tryParse(
                            val.replaceAll('%', '').trim(),
                          );
                          if (parsed != null) {
                            setDialogState(() {
                              tempScale = (parsed / 100.0).clamp(0.50, 2.00);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(uiScaleProvider.notifier).reset();
                Navigator.of(ctx).pop();
              },
              child: Text(l10n.shellScaleReset),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: NeoColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final parsed = double.tryParse(
                  controller.text.replaceAll('%', '').trim(),
                );
                final finalScale = parsed != null
                    ? (parsed / 100.0).clamp(0.50, 2.00)
                    : tempScale;
                ref.read(uiScaleProvider.notifier).setScale(finalScale);
                Navigator.of(ctx).pop();
              },
              child: Text(l10n.shellApply),
            ),
          ],
        ),
      ),
    );
  }

  String _breadcrumbSectionName(AppLocalizations l10n) {
    if (currentRoute == '/dashboard') return l10n.dashboardTitle;
    if (currentRoute.startsWith('/backlog')) return l10n.shellCrumbBacklog;
    if (currentRoute.startsWith('/projects')) return l10n.shellCrumbBacklogList;
    if (currentRoute.startsWith('/kanban')) return l10n.shellSidebarKanban;
    if (currentRoute.startsWith('/cycles')) return l10n.shellCrumbCycles;
    if (currentRoute.startsWith('/calendar')) return l10n.navCalendar;
    if (currentRoute.startsWith('/settings')) return l10n.navSettings;
    return l10n.shellCrumbWorkspace;
  }

  IconData _breadcrumbSectionIcon() {
    if (currentRoute == '/dashboard') return Icons.home_outlined;
    if (currentRoute.startsWith('/backlog') || currentRoute.startsWith('/projects')) {
      return Icons.inbox_outlined;
    }
    if (currentRoute.startsWith('/kanban')) return Icons.view_kanban_outlined;
    if (currentRoute.startsWith('/cycles')) return Icons.timelapse_outlined;
    if (currentRoute.startsWith('/calendar')) return Icons.calendar_today_outlined;
    if (currentRoute.startsWith('/settings')) return Icons.settings_outlined;
    return Icons.folder_outlined;
  }
}
