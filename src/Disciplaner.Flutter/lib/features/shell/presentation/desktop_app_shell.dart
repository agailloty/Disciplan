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
import 'package:disciplaner_flutter/features/activity/presentation/activity_drawer.dart';
import 'package:disciplaner_flutter/features/projects/presentation/create_project_modal.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';
import 'package:disciplaner_flutter/features/search/presentation/command_palette_modal.dart';
import 'package:disciplaner_flutter/features/sprints/presentation/sprint_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/ticket_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/desktop_create_ticket_dialog.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';

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
    final isSidebarCollapsed = ref.watch(sidebarCollapsedProvider);
    final user = authState is AuthAuthenticated ? authState.session : null;
    final currentProject = ref.watch(currentProjectDetailProvider).value;

    return Scaffold(
      backgroundColor: NeoColors.surface,
      body: Column(
        children: [
          // 1. TOP TITLE / COMMAND BAR (44px)
          _buildTopBar(context, ref, user, currentProject),

          // 2. MAIN LAYOUT (ACTIVITY BAR + PRIMARY SIDEBAR + WORKSPACE)
          Expanded(
            child: Row(
              children: [
                // A. Activity Bar (52px sombre #181715)
                _buildActivityBar(context, ref, user),

                // B. Primary Sidebar repliable (240px fond #F4F1EA)
                if (!isSidebarCollapsed) _buildPrimarySidebar(context, ref, currentProject),

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

  Widget _buildTopBar(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    dynamic currentProject,
  ) {
    final projects = ref.watch(projectsListProvider).value ?? [];
    final uiScale = ref.watch(uiScaleProvider);

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
                onTap: () => context.go('/my-tasks'),
                borderRadius: NeoSpacing.roundedSm,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'Disciplan',
                    style: NeoTypography.headlineSm.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, size: 16, color: NeoColors.subdued),
              PopupMenuButton<String>(
                tooltip: 'Changer de projet actif',
                shape: RoundedRectangleBorder(
                  borderRadius: NeoSpacing.roundedMd,
                  side: const BorderSide(color: NeoColors.borderWhisper),
                ),
                onSelected: (val) {
                  if (val == 'NEW') {
                    CreateProjectModal.show(context);
                  } else {
                    ref.read(selectedProjectIdProvider.notifier).select(val);
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
                  const PopupMenuItem(
                    value: 'NEW',
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 16),
                        SizedBox(width: 8),
                        Text('Nouveau projet'),
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
                        currentProject?.name ?? 'Sélectionner un projet',
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
                      _breadcrumbSectionName(),
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
                                  'Rechercher une tâche, aller au Kanban, Backlog...',
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
                tooltip: 'Taille d\'affichage (${(uiScale * 100).round()}%)',
                shape: RoundedRectangleBorder(
                  borderRadius: NeoSpacing.roundedMd,
                  side: const BorderSide(color: NeoColors.borderWhisper),
                ),
                onSelected: (scale) => ref.read(uiScaleProvider.notifier).setScale(scale),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 0.9, child: Text('Compact (90%)')),
                  const PopupMenuItem(value: 1.0, child: Text('Standard (100%)')),
                  const PopupMenuItem(value: 1.1, child: Text('Confort (110%)')),
                  const PopupMenuItem(value: 1.2, child: Text('Grand écran (120%)')),
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
              IconButton(
                icon: const Icon(Icons.vertical_split_outlined, size: 17),
                tooltip: 'Basculer la barre latérale (⌘B)',
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  ref.read(sidebarCollapsedProvider.notifier).toggle();
                },
              ),
              const SizedBox(width: NeoSpacing.spaceXs),
              NeoButton(
                label: 'Nouvelle tâche',
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
    final myTasks = ref.watch(myTasksProvider).asData?.value ?? [];
    final myActiveCount = myTasks
        .where((t) => t.status.category != StatusCategory.done)
        .length;

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
                icon: Icons.dashboard_customize_outlined,
                tooltip: 'Tableau de bord & Mes Tâches',
                isActive: currentRoute.startsWith('/my-tasks'),
                badgeText: myActiveCount > 0 ? '$myActiveCount' : null,
                onTap: () => context.go('/my-tasks'),
              ),
              _buildActivityItem(
                icon: Icons.view_kanban_outlined,
                tooltip: 'Tableau Kanban des Sprints',
                isActive: currentRoute.startsWith('/kanban'),
                onTap: () => context.go('/kanban'),
              ),
              _buildActivityItem(
                icon: Icons.inbox_outlined,
                tooltip: 'Backlog & Tickets du projet',
                isActive: currentRoute.startsWith('/projects') ||
                    currentRoute.startsWith('/backlog'),
                onTap: () => context.go('/projects'),
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
              _buildActivityItem(
                icon: Icons.notifications_none_outlined,
                tooltip: 'Activité récente',
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

  Widget _buildPrimarySidebar(BuildContext context, WidgetRef ref, dynamic currentProject) {
    final projects = ref.watch(projectsListProvider).value ?? [];
    final projectId = currentProject?.id as String?;

    final backlogCount = projectId != null
        ? (ref.watch(projectBacklogProvider(projectId)).asData?.value.length)
        : null;
    final sprints = projectId != null
        ? (ref.watch(projectSprintsProvider(projectId)).asData?.value ?? [])
        : const [];
    final activeSprint = sprints
        .where((s) => s.status == SprintStatus.active)
        .firstOrNull;
    final myTasks = ref.watch(myTasksProvider).asData?.value ?? [];
    final myActiveCount = myTasks
        .where((t) => t.status.category != StatusCategory.done)
        .length;

    final sprintMetrics = activeSprint != null
        ? ref.watch(sprintMetricsProvider(activeSprint.id)).asData?.value
        : null;

    return Container(
      width: 248,
      decoration: const BoxDecoration(
        color: Color(0xFFF4F1EA),
        border: Border(
          right: BorderSide(color: NeoColors.borderWhisper, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Sidebar Header: Switcher de projet & collapse
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: NeoColors.borderWhisper, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: PopupMenuButton<String>(
                    tooltip: 'Changer de projet',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            'PLAN DU PROJET',
                            overflow: TextOverflow.ellipsis,
                            style: NeoTypography.labelSm.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: NeoColors.onSurface,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 16, color: NeoColors.muted),
                      ],
                    ),
                    itemBuilder: (context) => [
                      ...projects.map(
                        (p) => PopupMenuItem(
                          value: p.id,
                          child: Text('${p.key} • ${p.name}', style: NeoTypography.bodySm),
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'NEW',
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 16),
                            SizedBox(width: 8),
                            Text('+ Nouveau projet'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (val) {
                      if (val == 'NEW') {
                        CreateProjectModal.show(context);
                      } else {
                        ref.read(selectedProjectIdProvider.notifier).select(val);
                      }
                    },
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

          // Active Project Identity Card
          if (currentProject != null)
            Container(
              margin: const EdgeInsets.fromLTRB(8, 8, 8, 2),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: NeoColors.surfaceContainerLowest,
                borderRadius: NeoSpacing.roundedMd,
                border: Border.all(color: NeoColors.borderWhisper),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: NeoColors.kineticAmber.withValues(alpha: 0.16),
                      borderRadius: NeoSpacing.roundedSm,
                    ),
                    child: Text(
                      currentProject.key,
                      style: NeoTypography.codeSm.copyWith(
                        color: NeoColors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentProject.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NeoTypography.bodySm.copyWith(
                            fontWeight: FontWeight.w700,
                            color: NeoColors.primary,
                          ),
                        ),
                        Text(
                          activeSprint != null
                              ? 'Sprint actif : ${activeSprint.name}'
                              : 'Aucun sprint actif',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NeoTypography.labelSm.copyWith(
                            fontSize: 10.5,
                            color: activeSprint != null ? NeoColors.emerald : NeoColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Sidebar Navigation Tree items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              children: [
                _buildSidebarSectionHeader('ESPACE PERSONNEL'),
                _buildSidebarItem(
                  context,
                  title: 'Mes Tâches',
                  subtitle: 'Tickets en cours & assignés',
                  icon: Icons.dashboard_customize_outlined,
                  isSelected: currentRoute == '/my-tasks',
                  badge: myActiveCount > 0 ? '$myActiveCount' : null,
                  onTap: () => context.go('/my-tasks'),
                ),

                const SizedBox(height: NeoSpacing.spaceSm),
                _buildSidebarSectionHeader('VUES DU PROJET'),
                _buildSidebarItem(
                  context,
                  title: 'Tableau Kanban',
                  subtitle: activeSprint != null ? activeSprint.name : 'Sprints en cours',
                  icon: Icons.view_kanban,
                  isSelected: currentRoute == '/kanban',
                  badge: activeSprint != null ? '${activeSprint.ticketCount}' : null,
                  onTap: () => context.go('/kanban'),
                ),
                _buildSidebarItem(
                  context,
                  title: 'Vue Liste',
                  subtitle: 'Backlog & tickets du projet',
                  icon: Icons.format_list_bulleted,
                  isSelected: currentRoute == '/projects',
                  badge: backlogCount != null ? '$backlogCount' : null,
                  onTap: () => context.go('/projects'),
                ),
                _buildSidebarItem(
                  context,
                  title: 'Backlog général',
                  subtitle: 'Tickets hors sprint à planifier',
                  icon: Icons.inbox_outlined,
                  isSelected: currentRoute == '/backlog',
                  badge: backlogCount != null ? '$backlogCount' : null,
                  onTap: () => context.go('/backlog'),
                ),

                const SizedBox(height: NeoSpacing.spaceSm),
                _buildSidebarSectionHeader('PLANNING & CYCLES'),
                _buildSidebarItem(
                  context,
                  title: 'Sprint Actif',
                  subtitle: 'Cycles, vélocité & roadmap',
                  icon: Icons.autorenew,
                  isSelected: currentRoute == '/cycles',
                  badge: sprintMetrics != null && activeSprint?.endDate != null
                      ? 'J-${sprintMetrics.daysRemaining}'
                      : (sprints.isNotEmpty ? '${sprints.length}' : null),
                  onTap: () => context.go('/cycles'),
                ),
                _buildSidebarItem(
                  context,
                  title: 'Calendrier & Jalons',
                  subtitle: 'Échéances & flux iCal',
                  icon: Icons.calendar_today,
                  isSelected: currentRoute == '/calendar',
                  onTap: () => context.go('/calendar'),
                ),

                const SizedBox(height: NeoSpacing.spaceSm),
                _buildSidebarSectionHeader('ADMINISTRATION'),
                _buildSidebarItem(
                  context,
                  title: 'Paramètres d\'équipe',
                  icon: Icons.settings,
                  isSelected: currentRoute == '/settings',
                  onTap: () => context.go('/settings'),
                ),
              ],
            ),
          ),

          // En bas de la sidebar: Jauge d'avancement du sprint actif (ou état)
          Container(
            padding: const EdgeInsets.all(NeoSpacing.spaceSm),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: NeoColors.borderWhisper, width: 1),
              ),
            ),
            child: InkWell(
              onTap: () => context.go(activeSprint != null ? '/kanban' : '/cycles'),
              borderRadius: NeoSpacing.roundedSm,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: NeoColors.surfaceContainerLowest,
                  borderRadius: NeoSpacing.roundedSm,
                  border: Border.all(color: NeoColors.borderWhisper),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            activeSprint != null ? 'Avancement Sprint' : 'Capacité Sprint',
                            style: NeoTypography.labelSm.copyWith(
                              color: NeoColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          sprintMetrics != null
                              ? '${sprintMetrics.completionPercentage.round()}%'
                              : (activeSprint != null ? 'En cours' : 'Aucun actif'),
                          style: GoogleFonts.ibmPlexMono(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: NeoColors.primary,
                          ),
                        ),
                      ],
                    ),
                    if (sprintMetrics != null) ...[
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: NeoSpacing.roundedFull,
                        child: LinearProgressIndicator(
                          value: (sprintMetrics.completionPercentage / 100.0).clamp(0.0, 1.0),
                          minHeight: 4,
                          backgroundColor: NeoColors.surfaceContainerHigh,
                          valueColor: const AlwaysStoppedAnimation<Color>(NeoColors.emerald),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 8, bottom: 4),
      child: Text(
        title,
        style: NeoTypography.labelSm.copyWith(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7,
          color: NeoColors.subdued,
        ),
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required bool isSelected,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isSelected ? NeoColors.surfaceContainerHighest : Colors.transparent,
        borderRadius: NeoSpacing.roundedMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: NeoSpacing.roundedMd,
          hoverColor: NeoColors.surfaceContainerHigh,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? NeoColors.secondary : NeoColors.muted,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: NeoTypography.bodySm.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? NeoColors.primary : NeoColors.onSurfaceVariant,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NeoTypography.labelSm.copyWith(
                            fontSize: 10.5,
                            color: NeoColors.muted,
                          ),
                        ),
                    ],
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isSelected ? NeoColors.surfaceContainerLowest : NeoColors.surfaceContainerHigh,
                      borderRadius: NeoSpacing.roundedSm,
                    ),
                    child: Text(
                      badge,
                      style: NeoTypography.codeSm.copyWith(
                        fontSize: 10.5,
                        color: isSelected ? NeoColors.primary : NeoColors.onSurfaceVariant,
                      ),
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
    if (currentRoute.startsWith('/backlog')) return 'Backlog du Projet';
    if (currentRoute.startsWith('/projects')) return 'Backlog & Vue Liste';
    if (currentRoute.startsWith('/my-tasks')) return 'Mon Dashboard & Tâches';
    if (currentRoute.startsWith('/kanban')) return 'Tableau Kanban';
    if (currentRoute.startsWith('/cycles')) return 'Cycles & Sprints';
    if (currentRoute.startsWith('/calendar')) return 'Calendrier';
    if (currentRoute.startsWith('/settings')) return 'Paramètres';
    return 'Espace';
  }

  IconData _breadcrumbSectionIcon() {
    if (currentRoute.startsWith('/backlog') || currentRoute.startsWith('/projects')) {
      return Icons.inbox_outlined;
    }
    if (currentRoute.startsWith('/my-tasks')) return Icons.dashboard_customize_outlined;
    if (currentRoute.startsWith('/kanban')) return Icons.view_kanban_outlined;
    if (currentRoute.startsWith('/cycles')) return Icons.timelapse_outlined;
    if (currentRoute.startsWith('/calendar')) return Icons.calendar_today_outlined;
    if (currentRoute.startsWith('/settings')) return Icons.settings_outlined;
    return Icons.folder_outlined;
  }
}
