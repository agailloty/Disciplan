import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/features/projects/presentation/create_project_modal.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';
import 'package:disciplaner_flutter/features/sprints/presentation/sprint_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ticket_providers.dart';
import 'widgets/dense_ticket_row.dart';
import 'widgets/mobile_ticket_detail_sheet.dart';
import 'widgets/multi_select_action_bar.dart';
import 'widgets/save_view_modal.dart';
import 'widgets/split_inspector_panel.dart';

class MyTasksView extends ConsumerStatefulWidget {
  const MyTasksView({super.key});

  @override
  ConsumerState<MyTasksView> createState() => _MyTasksViewState();
}

class _MyTasksViewState extends ConsumerState<MyTasksView> {
  String _activeTab = 'all'; // 'all', 'inProgress', 'backlog', 'urgent', 'done'

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(myTasksProvider);
    final projectsAsync = ref.watch(projectsListProvider);
    final allProjects = projectsAsync.asData?.value ?? const <ProjectSummaryDto>[];
    final selectedIds = ref.watch(selectedTicketIdsProvider);
    final savedViewsAsync = ref.watch(savedViewsListProvider);
    final selectedDetailId = ref.watch(selectedTicketDetailIdProvider);
    final currentProject = ref.watch(currentProjectDetailProvider).value;
    final sprints = currentProject != null
        ? (ref.watch(projectSprintsProvider(currentProject.id)).asData?.value ?? [])
        : const [];
    final activeSprint = sprints
        .where((s) => s.status == SprintStatus.active)
        .firstOrNull;
    final backlogCount = currentProject != null
        ? (ref.watch(projectBacklogProvider(currentProject.id)).asData?.value.length)
        : null;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= NeoSpacing.mobileBreakpoint;

    final mainStack = Stack(
        children: [
          tasksAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: NeoColors.primary),
            ),
            error: (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 40, color: NeoColors.error),
                  const SizedBox(height: NeoSpacing.spaceSm),
                  Text('Erreur de chargement: $err', style: NeoTypography.bodyMd),
                  const SizedBox(height: NeoSpacing.spaceMd),
                  ElevatedButton(
                    onPressed: () => ref.read(myTasksProvider.notifier).refresh(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
            data: (allTasks) {
              final inProgressTasks = allTasks
                  .where((t) => t.status.category == StatusCategory.inProgress)
                  .toList();
              final inProgressCount = inProgressTasks.length;
              final backlogTaskCount = allTasks
                  .where((t) => t.status.category == StatusCategory.backlog)
                  .length;
              final urgentCount = allTasks
                  .where((t) =>
                      t.priority == CardPriority.critical ||
                      t.priority == CardPriority.high)
                  .length;
              final doneCount = allTasks
                  .where((t) => t.status.category == StatusCategory.done)
                  .length;

              // Apply active tab filter
              final filteredTasks = allTasks.where((t) {
                switch (_activeTab) {
                  case 'inProgress':
                    return t.status.category == StatusCategory.inProgress;
                  case 'backlog':
                    return t.status.category == StatusCategory.backlog;
                  case 'urgent':
                    return t.priority == CardPriority.critical ||
                        t.priority == CardPriority.high;
                  case 'done':
                    return t.status.category == StatusCategory.done;
                  case 'all':
                  default:
                    return true;
                }
              }).toList();

              return RefreshIndicator(
                color: NeoColors.primary,
                onRefresh: () => ref.read(myTasksProvider.notifier).refresh(),
                child: ListView(
                  padding: NeoSpacing.responsivePagePadding(screenWidth),
                  children: [
                    // 1. Header with Breadcrumb & Title
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: NeoSpacing.spaceMd,
                      runSpacing: NeoSpacing.spaceSm,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: NeoColors.kineticAmber.withValues(alpha: 0.16),
                                    borderRadius: NeoSpacing.roundedSm,
                                  ),
                                  child: Text(
                                    'TABLEAU DE BORD PERSONNEL',
                                    style: NeoTypography.codeSm.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: NeoColors.secondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: NeoSpacing.spaceSm),
                                Text('•', style: NeoTypography.bodySm.copyWith(color: NeoColors.muted)),
                                const SizedBox(width: NeoSpacing.spaceSm),
                                Text(
                                  activeSprint != null
                                      ? activeSprint.name
                                      : (currentProject?.name ?? 'Cycle actif'),
                                  style: NeoTypography.labelSm.copyWith(
                                    color: NeoColors.muted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: NeoSpacing.spaceXs),
                            Text('Mes Tâches', style: NeoTypography.headlineLg),
                            const SizedBox(height: 2),
                            Text(
                              '$inProgressCount tâche(s) en cours requièrent votre attention.',
                              style: NeoTypography.bodyMd.copyWith(color: NeoColors.muted),
                            ),
                          ],
                        ),

                        // Action buttons: Quick Create + Save View
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                SaveViewModal.show(
                                  context,
                                  initialCategory: _activeTab == 'inProgress'
                                      ? StatusCategory.inProgress
                                      : (_activeTab == 'backlog'
                                          ? StatusCategory.backlog
                                          : null),
                                  initialPriority: _activeTab == 'urgent'
                                      ? CardPriority.critical
                                      : null,
                                );
                              },
                              icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                              label: const Text('Sauvegarder la vue'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: NeoColors.onSurface,
                                side: const BorderSide(color: NeoColors.borderWhisper),
                                shape: RoundedRectangleBorder(
                                  borderRadius: NeoSpacing.roundedMd,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: NeoSpacing.spaceLg),

                    // 1.2 Quick Workspace Navigation Hub (Kanban, Backlog, Cycles)
                    _buildQuickNavigationHub(
                      context,
                      currentProjectName: currentProject?.name,
                      currentProjectKey: currentProject?.key,
                      activeSprintName: activeSprint?.name,
                      backlogCount: backlogCount,
                      isDesktop: isDesktop,
                    ),
                    const SizedBox(height: NeoSpacing.spaceMd),

                    // 1.5 Explicit Multi-Project Overview Section
                    _buildAllProjectsDashboardSection(
                      context,
                      projects: allProjects,
                      activeProjectId: currentProject?.id,
                      isDesktop: isDesktop,
                    ),
                    const SizedBox(height: NeoSpacing.spaceMd),

                    // 2. Interactive Metric Counters Cards (Click to filter)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                title: 'En cours',
                                count: inProgressCount,
                                color: NeoColors.statusAmber,
                                icon: Icons.timelapse,
                                isSelected: _activeTab == 'inProgress',
                                onTap: () => setState(() =>
                                    _activeTab = _activeTab == 'inProgress' ? 'all' : 'inProgress'),
                              ),
                            ),
                            const SizedBox(width: NeoSpacing.spaceSm),
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Urgentes',
                                count: urgentCount,
                                color: NeoColors.error,
                                icon: Icons.crisis_alert,
                                isSelected: _activeTab == 'urgent',
                                onTap: () => setState(
                                    () => _activeTab = _activeTab == 'urgent' ? 'all' : 'urgent'),
                              ),
                            ),
                            const SizedBox(width: NeoSpacing.spaceSm),
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Terminées',
                                count: doneCount,
                                color: NeoColors.emerald,
                                icon: Icons.check_circle_outline,
                                isSelected: _activeTab == 'done',
                                onTap: () => setState(
                                    () => _activeTab = _activeTab == 'done' ? 'all' : 'done'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: NeoSpacing.spaceLg),

                    // 3. Filter tabs & Saved Views Rail
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterPill('Toutes (${allTasks.length})', 'all'),
                                const SizedBox(width: NeoSpacing.spaceXs),
                                _buildFilterPill('En cours ($inProgressCount)', 'inProgress'),
                                const SizedBox(width: NeoSpacing.spaceXs),
                                _buildFilterPill('À faire ($backlogTaskCount)', 'backlog'),
                                const SizedBox(width: NeoSpacing.spaceXs),
                                _buildFilterPill('Urgentes ($urgentCount)', 'urgent'),
                                const SizedBox(width: NeoSpacing.spaceXs),
                                _buildFilterPill('Terminées ($doneCount)', 'done'),
                              ],
                            ),
                          ),
                        ),

                        // Saved views chips if any
                        savedViewsAsync.when(
                          data: (views) {
                            if (views.isEmpty) return const SizedBox.shrink();
                            return PopupMenuButton<String>(
                              tooltip: 'Vues enregistrées',
                              icon: const Icon(Icons.bookmarks_outlined, size: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: NeoSpacing.roundedMd,
                                side: const BorderSide(color: NeoColors.borderWhisper),
                              ),
                              onSelected: (viewId) {
                                ref.read(selectedSavedViewIdProvider.notifier).setViewId(viewId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Vue sauvegardée activée.')),
                                );
                              },
                              itemBuilder: (context) => views.map((v) {
                                return PopupMenuItem(
                                  value: v.id,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.bookmark_outline, size: 16),
                                      const SizedBox(width: 8),
                                      Text(v.name),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (error, stack) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    const SizedBox(height: NeoSpacing.spaceMd),

                    // 3.5 Highlighted "Tickets en cours" Focus Section (when on 'all' tab and has in-progress tasks)
                    if (_activeTab == 'all' && inProgressTasks.isNotEmpty) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: NeoColors.statusAmber.withValues(alpha: 0.05),
                          borderRadius: NeoSpacing.roundedLg,
                          border: Border.all(
                            color: NeoColors.statusAmber.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                NeoSpacing.spaceMd,
                                NeoSpacing.spaceSm,
                                NeoSpacing.spaceMd,
                                NeoSpacing.spaceXs,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.play_circle_fill,
                                        size: 16,
                                        color: NeoColors.statusAmber,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'FOCUS — VOS TICKETS EN COURS ($inProgressCount)',
                                        style: NeoTypography.labelSm.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: NeoColors.secondary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () => setState(() => _activeTab = 'inProgress'),
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                    child: Text(
                                      'Isoler En cours →',
                                      style: NeoTypography.labelSm.copyWith(
                                        color: NeoColors.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...inProgressTasks.map(
                              (ticket) => DenseTicketRow(
                                ticket: ticket,
                                isSelected: selectedIds.contains(ticket.id),
                                onTap: () {
                                  if (isDesktop) {
                                    ref
                                        .read(selectedTicketDetailIdProvider.notifier)
                                        .select(ticket.id);
                                  } else {
                                    MobileTicketDetailSheet.show(context, ticket.id);
                                  }
                                },
                                onSelectedChanged: (val) {
                                  ref
                                      .read(selectedTicketIdsProvider.notifier)
                                      .toggle(ticket.id);
                                },
                                onDelete: () async {
                                  await ref
                                      .read(ticketRepositoryProvider)
                                      .deleteTicket(ticket.id);
                                  ref.read(myTasksProvider.notifier).refresh();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: NeoSpacing.spaceMd),
                    ],

                    // 4. Task List Container (remaining tasks when 'all', or filtered tasks on specific tab)
                    Builder(
                      builder: (context) {
                        final displayedList = _activeTab == 'all'
                            ? filteredTasks
                                .where((t) => t.status.category != StatusCategory.inProgress)
                                .toList()
                            : filteredTasks;

                        if (_activeTab == 'all' &&
                            displayedList.isEmpty &&
                            inProgressTasks.isNotEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: NeoColors.surfaceContainerLowest,
                            borderRadius: NeoSpacing.roundedLg,
                            border: Border.all(color: NeoColors.borderWhisper),
                          ),
                          child: displayedList.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(NeoSpacing.spaceXl),
                                  child: Center(
                                    child: Text(
                                      'Aucune tâche ne correspond à ce filtre.',
                                      style: NeoTypography.bodyMd.copyWith(
                                        color: NeoColors.muted,
                                      ),
                                    ),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_activeTab == 'all' && inProgressTasks.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          NeoSpacing.spaceMd,
                                          NeoSpacing.spaceSm,
                                          NeoSpacing.spaceMd,
                                          NeoSpacing.spaceXs,
                                        ),
                                        child: Text(
                                          'AUTRES TÂCHES ASSIGNÉES (${displayedList.length})',
                                          style: NeoTypography.labelSm.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: NeoColors.muted,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ...displayedList.map((ticket) {
                                      return DenseTicketRow(
                                        ticket: ticket,
                                        isSelected: selectedIds.contains(ticket.id),
                                        onTap: () {
                                          if (isDesktop) {
                                            ref
                                                .read(selectedTicketDetailIdProvider.notifier)
                                                .select(ticket.id);
                                          } else {
                                            MobileTicketDetailSheet.show(context, ticket.id);
                                          }
                                        },
                                        onSelectedChanged: (val) {
                                          ref
                                              .read(selectedTicketIdsProvider.notifier)
                                              .toggle(ticket.id);
                                        },
                                        onDelete: () async {
                                          await ref
                                              .read(ticketRepositoryProvider)
                                              .deleteTicket(ticket.id);
                                          ref.read(myTasksProvider.notifier).refresh();
                                        },
                                      );
                                    }),
                                  ],
                                ),
                        );
                      },
                    ),
                    const SizedBox(height: 80), // Padding for batch actions bar
                  ],
                ),
              );
            },
          ),

          // 5. Floating MultiSelect Action Bar
          MultiSelectActionBar(
            selectedCount: selectedIds.length,
            onClear: () =>
                ref.read(selectedTicketIdsProvider.notifier).clear(),
            onStatusSelect: (category) async {
              final tasks = ref.read(myTasksProvider).value ?? [];
              final selected = tasks.where((t) => selectedIds.contains(t.id));
              for (final t in selected) {
                await ref
                    .read(ticketRepositoryProvider)
                    .changeStatus(t.id, t.status.id);
              }
              ref.read(selectedTicketIdsProvider.notifier).clear();
              ref.read(myTasksProvider.notifier).refresh();
            },
            onDelete: () async {
              await ref
                  .read(myTasksProvider.notifier)
                  .batchDelete(selectedIds);
            },
          ),
        ],
      );

    return Scaffold(
      backgroundColor: NeoColors.surfaceContainerLowest,
      body: Row(
        children: [
          Expanded(child: mainStack),
          if (selectedDetailId != null && isDesktop)
            SplitInspectorPanel(
              ticketId: selectedDetailId,
              onClose: () =>
                  ref.read(selectedTicketDetailIdProvider.notifier).clear(),
            ),
        ],
      ),
    );
  }

  Widget _buildAllProjectsDashboardSection(
    BuildContext context, {
    required List<ProjectSummaryDto> projects,
    required String? activeProjectId,
    required bool isDesktop,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: NeoSpacing.spaceMd,
        vertical: NeoSpacing.spaceSm + 2,
      ),
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLowest,
        borderRadius: NeoSpacing.roundedLg,
        border: Border.all(color: NeoColors.borderWhisper),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: NeoSpacing.spaceSm,
            runSpacing: NeoSpacing.spaceXs,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: NeoColors.kineticAmber.withValues(alpha: 0.16),
                      borderRadius: NeoSpacing.roundedSm,
                    ),
                    child: const Icon(
                      Icons.folder_copy_outlined,
                      size: 15,
                      color: NeoColors.secondary,
                    ),
                  ),
                  const SizedBox(width: NeoSpacing.spaceSm),
                  Text(
                    'MES PROJETS — ESPACES ENCAPSULÉS',
                    style: NeoTypography.labelSm.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: NeoColors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: NeoColors.surfaceContainerHigh,
                      borderRadius: NeoSpacing.roundedFull,
                    ),
                    child: Text(
                      '${projects.length}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: NeoColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () => context.go('/projects'),
                    icon: const Icon(Icons.grid_view_rounded, size: 15),
                    label: const Text('Portefeuille complet'),
                    style: TextButton.styleFrom(
                      foregroundColor: NeoColors.secondary,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 4),
                  OutlinedButton.icon(
                    onPressed: () => CreateProjectModal.show(context),
                    icon: const Icon(Icons.add, size: 15),
                    label: const Text('Nouveau projet'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: NeoColors.onSurface,
                      visualDensity: VisualDensity.compact,
                      side: const BorderSide(color: NeoColors.borderWhisper),
                      shape: RoundedRectangleBorder(
                        borderRadius: NeoSpacing.roundedSm,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (projects.isNotEmpty) ...[
            const SizedBox(height: NeoSpacing.spaceSm),
            LayoutBuilder(
              builder: (context, constraints) {
                if (!isDesktop) {
                  return Column(
                    children: [
                      for (var i = 0; i < projects.length; i++) ...[
                        if (i > 0) const SizedBox(height: NeoSpacing.spaceSm),
                        _buildProjectDashboardTile(
                          context,
                          project: projects[i],
                          isActive: projects[i].id == activeProjectId,
                        ),
                      ],
                    ],
                  );
                }

                final cols = constraints.maxWidth >= 960
                    ? 3
                    : (constraints.maxWidth >= 620 ? 2 : 1);
                final gap = NeoSpacing.spaceSm;
                final width = (constraints.maxWidth - gap * (cols - 1)) / cols;

                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: projects.map((project) {
                    return SizedBox(
                      width: width,
                      child: _buildProjectDashboardTile(
                        context,
                        project: project,
                        isActive: project.id == activeProjectId,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProjectDashboardTile(
    BuildContext context, {
    required ProjectSummaryDto project,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () {
        ref.read(selectedProjectIdProvider.notifier).select(project.id);
      },
      borderRadius: NeoSpacing.roundedMd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(NeoSpacing.spaceMd),
        decoration: BoxDecoration(
          color: isActive
              ? NeoColors.kineticAmber.withValues(alpha: 0.06)
              : NeoColors.surfaceContainerLow,
          borderRadius: NeoSpacing.roundedMd,
          border: Border.all(
            color: isActive ? NeoColors.primary : NeoColors.borderWhisper,
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isActive
                        ? NeoColors.kineticAmber.withValues(alpha: 0.22)
                        : NeoColors.surfaceContainerLowest,
                    borderRadius: NeoSpacing.roundedSm,
                    border: Border.all(
                      color: isActive
                          ? NeoColors.kineticAmber
                          : NeoColors.borderWhisper,
                    ),
                  ),
                  child: Text(
                    project.key,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: NeoColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    project.name,
                    style: NeoTypography.labelMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: NeoColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: NeoColors.emerald.withValues(alpha: 0.14),
                      borderRadius: NeoSpacing.roundedFull,
                    ),
                    child: Text(
                      'ACTIF',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: NeoColors.emerald,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${project.ticketCount} tickets • ${project.sprintCount} sprints • ${project.isOwner ? "Propriétaire" : "Membre"}',
              style: NeoTypography.labelSm.copyWith(
                color: NeoColors.muted,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: NeoSpacing.spaceSm),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildProjectJumpPill(
                  icon: Icons.inbox_outlined,
                  label: 'Backlog',
                  onTap: () {
                    ref.read(selectedProjectIdProvider.notifier).select(project.id);
                    context.go('/backlog');
                  },
                ),
                _buildProjectJumpPill(
                  icon: Icons.view_kanban_outlined,
                  label: 'Kanban',
                  onTap: () {
                    ref.read(selectedProjectIdProvider.notifier).select(project.id);
                    context.go('/kanban');
                  },
                ),
                _buildProjectJumpPill(
                  icon: Icons.autorenew_rounded,
                  label: 'Cycles',
                  onTap: () {
                    ref.read(selectedProjectIdProvider.notifier).select(project.id);
                    context.go('/cycles');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectJumpPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: NeoSpacing.roundedSm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: NeoColors.surfaceContainerLowest,
          borderRadius: NeoSpacing.roundedSm,
          border: Border.all(color: NeoColors.borderWhisper),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: NeoColors.secondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: NeoTypography.labelSm.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: NeoColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickNavigationHub(
    BuildContext context, {
    required String? currentProjectName,
    required String? currentProjectKey,
    required String? activeSprintName,
    required int? backlogCount,
    required bool isDesktop,
  }) {
    final prefix = currentProjectKey != null ? '[$currentProjectKey] ' : '';
    final cards = [
      _buildNavShortcutCard(
        icon: Icons.view_kanban_rounded,
        title: '${prefix}Tableau Kanban',
        subtitle: activeSprintName != null
            ? 'Sprint actif : $activeSprintName'
            : 'Voir les colonnes du sprint',
        accentColor: NeoColors.kineticAmber,
        onTap: () => context.go('/kanban'),
      ),
      _buildNavShortcutCard(
        icon: Icons.inventory_2_outlined,
        title: '${prefix}Backlog du Projet',
        subtitle: backlogCount != null
            ? '$backlogCount ticket(s) hors sprint à planifier'
            : 'Lister et prioriser le backlog',
        accentColor: NeoColors.statusBlue,
        onTap: () => context.go('/backlog'),
      ),
      _buildNavShortcutCard(
        icon: Icons.autorenew_rounded,
        title: '${prefix}Cycles & Sprints',
        subtitle: currentProjectName != null
            ? 'Cycles de $currentProjectName'
            : 'Planifier, démarrer ou clôturer un sprint',
        accentColor: NeoColors.emerald,
        onTap: () => context.go('/cycles'),
      ),
    ];

    if (!isDesktop) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: NeoSpacing.spaceXs),
            cards[i],
          ],
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: cards[0]),
        const SizedBox(width: NeoSpacing.spaceSm),
        Expanded(child: cards[1]),
        const SizedBox(width: NeoSpacing.spaceSm),
        Expanded(child: cards[2]),
      ],
    );
  }

  Widget _buildNavShortcutCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: NeoSpacing.roundedMd,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: NeoSpacing.spaceMd,
          vertical: NeoSpacing.spaceSm + 2,
        ),
        decoration: BoxDecoration(
          color: NeoColors.surfaceContainerLow,
          borderRadius: NeoSpacing.roundedMd,
          border: Border.all(color: NeoColors.borderWhisper),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.14),
                borderRadius: NeoSpacing.roundedSm,
              ),
              child: Icon(icon, size: 18, color: NeoColors.onSurface),
            ),
            const SizedBox(width: NeoSpacing.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: NeoTypography.labelMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: NeoColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: NeoTypography.labelSm.copyWith(
                      color: NeoColors.muted,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: NeoColors.muted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: NeoSpacing.roundedMd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: NeoSpacing.spaceMd,
          vertical: NeoSpacing.spaceSm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.10)
              : NeoColors.surfaceContainerLow,
          borderRadius: NeoSpacing.roundedMd,
          border: Border.all(
            color: isSelected ? color : NeoColors.borderWhisper,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: NeoSpacing.roundedSm,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: NeoSpacing.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: NeoTypography.labelSm.copyWith(
                      color: isSelected ? NeoColors.onSurface : NeoColors.muted,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$count',
                    style: NeoTypography.titleMd.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: NeoColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, String tabKey) {
    final isActive = _activeTab == tabKey;
    return InkWell(
      onTap: () => setState(() => _activeTab = tabKey),
      borderRadius: NeoSpacing.roundedMd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? NeoColors.primary
              : NeoColors.surfaceContainerLow,
          borderRadius: NeoSpacing.roundedMd,
          border: Border.all(
            color: isActive ? NeoColors.primary : NeoColors.borderWhisper,
          ),
        ),
        child: Text(
          label,
          style: NeoTypography.labelSm.copyWith(
            color: isActive ? Colors.white : NeoColors.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
