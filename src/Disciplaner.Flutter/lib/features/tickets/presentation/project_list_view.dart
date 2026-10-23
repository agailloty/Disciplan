import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/l10n/enum_l10n.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/sprint_models.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';
import 'package:disciplaner_flutter/features/sprints/presentation/sprint_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/desktop_create_ticket_dialog.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/mobile_create_ticket_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'ticket_providers.dart';
import 'widgets/dense_ticket_row.dart';
import 'widgets/mobile_ticket_detail_sheet.dart';
import 'widgets/multi_select_action_bar.dart';
import 'widgets/split_inspector_panel.dart';

class ProjectListView extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectListView({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectListView> createState() => _ProjectListViewState();
}

class _ProjectListViewState extends ConsumerState<ProjectListView> {
  /// `null` means we are viewing the Project Backlog (tickets not assigned to a sprint).
  /// When non-null, we are viewing the tickets of that specific Sprint.
  String? _selectedSprintScopeId;
  String _searchQuery = '';
  CardPriority? _priorityFilter;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _topQuickAddController = TextEditingController();

  final Map<StatusCategory, bool> _expandedSections = {
    StatusCategory.backlog: true,
    StatusCategory.inProgress: true,
    StatusCategory.done: false,
  };

  final Map<StatusCategory, TextEditingController> _quickControllers = {
    StatusCategory.inProgress: TextEditingController(),
    StatusCategory.backlog: TextEditingController(),
    StatusCategory.done: TextEditingController(),
  };

  @override
  void dispose() {
    _searchController.dispose();
    _topQuickAddController.dispose();
    for (final c in _quickControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handleQuickAdd(StatusCategory category, {TextEditingController? customController}) async {
    final controller = customController ?? _quickControllers[category]!;
    final title = controller.text.trim();
    if (title.isEmpty) return;

    try {
      final repo = ref.read(ticketRepositoryProvider);
      await repo.createTicket(
        widget.projectId,
        CreateTicketRequest(
          title: title,
          type: TicketType.task,
          priority: CardPriority.medium,
          sprintId: _selectedSprintScopeId,
        ),
      );
      controller.clear();
      _refreshCurrentScope();
      ref.invalidate(currentProjectDetailProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.ticketsCreateFailed(e.toString()))),
        );
      }
    }
  }

  void _refreshCurrentScope() {
    ref.invalidate(projectBacklogProvider(widget.projectId));
    if (_selectedSprintScopeId != null) {
      ref.invalidate(sprintTicketsProvider(_selectedSprintScopeId!));
    }
    ref.invalidate(projectSprintsProvider(widget.projectId));
  }

  Future<void> _assignTicketsToSprint(Iterable<String> ticketIds, SprintDto targetSprint) async {
    try {
      final repo = ref.read(ticketRepositoryProvider);
      for (final id in ticketIds) {
        await repo.moveToSprint(id, targetSprint.id);
      }
      ref.read(selectedTicketIdsProvider.notifier).clear();
      _refreshCurrentScope();
      ref.invalidate(sprintTicketsProvider(targetSprint.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.ticketsPlannedInSprint(ticketIds.length, targetSprint.name)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.ticketsAssignToSprintFailed(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ticketsAsync = _selectedSprintScopeId == null
        ? ref.watch(projectBacklogProvider(widget.projectId))
        : ref.watch(sprintTicketsProvider(_selectedSprintScopeId!));

    final currentProject = ref.watch(currentProjectDetailProvider).value;
    final sprints = ref.watch(projectSprintsProvider(widget.projectId)).asData?.value ?? const <SprintDto>[];
    final openSprints = sprints.where((s) => s.status != SprintStatus.closed).toList();
    final selectedIds = ref.watch(selectedTicketIdsProvider);
    final selectedDetailId = ref.watch(selectedTicketDetailIdProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= NeoSpacing.mobileBreakpoint;

    final mainContent = Stack(
      children: [
        ticketsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: NeoColors.primary),
          ),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 40, color: NeoColors.error),
                const SizedBox(height: NeoSpacing.spaceSm),
                Text(l10n.ticketsLoadError(err.toString()), style: NeoTypography.bodyMd),
                const SizedBox(height: NeoSpacing.spaceMd),
                ElevatedButton(
                  onPressed: _refreshCurrentScope,
                  child: Text(l10n.attachmentRetry),
                ),
              ],
            ),
          ),
          data: (allTickets) {
            final topLevelTickets = allTickets
                .where((t) => t.parentTicketId == null)
                .toList();
            final filteredTickets = topLevelTickets.where((t) {
              if (_priorityFilter != null && t.priority != _priorityFilter) {
                return false;
              }
              if (_searchQuery.isNotEmpty) {
                final q = _searchQuery.toLowerCase();
                return t.title.toLowerCase().contains(q) ||
                    t.ticketRef.toLowerCase().contains(q) ||
                    (t.assigneeName?.toLowerCase().contains(q) ?? false);
              }
              return true;
            }).toList();

            final backlog = filteredTickets
                .where((t) => t.status.category == StatusCategory.backlog)
                .toList();
            final inProgress = filteredTickets
                .where((t) => t.status.category == StatusCategory.inProgress)
                .toList();
            final done = filteredTickets
                .where((t) => t.status.category == StatusCategory.done)
                .toList();

            return RefreshIndicator(
              color: NeoColors.primary,
              onRefresh: () async => _refreshCurrentScope(),
              child: ListView(
                padding: NeoSpacing.responsivePagePadding(screenWidth),
                children: [
                  // 1. Page Header & Orientation
                  _buildPageHeader(
                    context,
                    currentProjectName: currentProject?.name,
                    currentProjectKey: currentProject?.key,
                    totalTicketsCount: topLevelTickets.length,
                    isDesktop: isDesktop,
                  ),
                  const SizedBox(height: NeoSpacing.spaceMd),

                  // 2. Scope Switcher: Backlog vs Sprints
                  _buildScopeSelectorBar(sprints, topLevelTickets.length),
                  const SizedBox(height: NeoSpacing.spaceMd),

                  // 3. Search, Filter & Sprint Assignment Bar
                  _buildSearchAndFilterBar(
                    openSprints: openSprints,
                    selectedIds: selectedIds,
                  ),
                  const SizedBox(height: NeoSpacing.spaceMd),

                  // 4. Tickets Content or Empty State
                  if (topLevelTickets.isEmpty)
                    _buildEmptyState()
                  else if (filteredTickets.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(NeoSpacing.spaceXl),
                      decoration: BoxDecoration(
                        color: NeoColors.surfaceContainerLow,
                        borderRadius: NeoSpacing.roundedLg,
                        border: Border.all(color: NeoColors.borderWhisper),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.filter_alt_off_outlined, size: 36, color: NeoColors.muted),
                          const SizedBox(height: NeoSpacing.spaceSm),
                          Text(
                            l10n.ticketsNoTicketMatchSearch,
                            style: NeoTypography.titleMd,
                          ),
                          const SizedBox(height: NeoSpacing.spaceXs),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                                _priorityFilter = null;
                              });
                            },
                            child: Text(l10n.ticketsResetFilters),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    // Order sections logically: For Backlog, show 'À faire' first then 'En cours'
                    _buildSection(
                      title: l10n.ticketsTodo,
                      subtitle: _selectedSprintScopeId == null
                          ? l10n.ticketsBacklogSectionSubtitle
                          : l10n.ticketsSprintTodoSubtitle,
                      icon: Icons.radio_button_unchecked,
                      iconColor: NeoColors.statusBlue,
                      category: StatusCategory.backlog,
                      tickets: backlog,
                      selectedIds: selectedIds,
                      isDesktop: isDesktop,
                      openSprints: openSprints,
                    ),
                    const SizedBox(height: NeoSpacing.spaceMd),
                    _buildSection(
                      title: l10n.statuscategoryInProgress,
                      subtitle: l10n.ticketsInProgressSubtitle,
                      icon: Icons.timelapse_outlined,
                      iconColor: NeoColors.statusAmber,
                      category: StatusCategory.inProgress,
                      tickets: inProgress,
                      selectedIds: selectedIds,
                      isDesktop: isDesktop,
                      openSprints: openSprints,
                    ),
                    const SizedBox(height: NeoSpacing.spaceMd),
                    _buildSection(
                      title: l10n.statuscategoryDone,
                      subtitle: l10n.ticketsDoneSubtitle,
                      icon: Icons.check_circle_outline,
                      iconColor: NeoColors.emerald,
                      category: StatusCategory.done,
                      tickets: done,
                      selectedIds: selectedIds,
                      isDesktop: isDesktop,
                      openSprints: openSprints,
                    ),
                  ],
                  const SizedBox(height: 80), // Space for floating bar
                ],
              ),
            );
          },
        ),

        // Floating batch actions bar
        MultiSelectActionBar(
          selectedCount: selectedIds.length,
          onClear: () =>
              ref.read(selectedTicketIdsProvider.notifier).clear(),
          onStatusSelect: (category) async {
            final project = ref.read(currentProjectDetailProvider).value;
            final targetStatus = project?.statuses.firstWhere(
              (s) => s.category == category,
              orElse: () => project.statuses.first,
            );
            if (targetStatus != null) {
              final repo = ref.read(ticketRepositoryProvider);
              for (final id in selectedIds) {
                await repo.changeStatus(id, targetStatus.id);
              }
              ref.read(selectedTicketIdsProvider.notifier).clear();
              _refreshCurrentScope();
            }
          },
          onDelete: () async {
            final repo = ref.read(ticketRepositoryProvider);
            for (final id in selectedIds) {
              await repo.deleteTicket(id);
            }
            ref.read(selectedTicketIdsProvider.notifier).clear();
            _refreshCurrentScope();
          },
        ),
      ],
    );

    return Scaffold(
      backgroundColor: NeoColors.surfaceContainerLowest,
      body: Row(
        children: [
          Expanded(child: mainContent),
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

  Widget _buildPageHeader(
    BuildContext context, {
    required String? currentProjectName,
    required String? currentProjectKey,
    required int totalTicketsCount,
    required bool isDesktop,
  }) {
    final l10n = context.l10n;
    final isBacklogScope = _selectedSprintScopeId == null;
    return Wrap(
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: NeoColors.statusBlue.withValues(alpha: 0.14),
                    borderRadius: NeoSpacing.roundedSm,
                  ),
                  child: Text(
                    isBacklogScope ? l10n.ticketsBacklogProjectBadge : l10n.ticketsSprintListBadge,
                    style: NeoTypography.codeSm.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: NeoColors.statusBlue,
                    ),
                  ),
                ),
                if (currentProjectName != null) ...[
                  const SizedBox(width: NeoSpacing.spaceSm),
                  Text('•', style: NeoTypography.bodySm.copyWith(color: NeoColors.muted)),
                  const SizedBox(width: NeoSpacing.spaceSm),
                  InkWell(
                    onTap: () => context.go('/projects'),
                    borderRadius: NeoSpacing.roundedSm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: NeoColors.surfaceContainerLow,
                        borderRadius: NeoSpacing.roundedSm,
                        border: Border.all(color: NeoColors.borderWhisper),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.folder_copy_outlined,
                            size: 12,
                            color: NeoColors.secondary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${currentProjectKey ?? ''} — $currentProjectName',
                            style: NeoTypography.labelSm.copyWith(
                              color: NeoColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.swap_horiz_rounded,
                            size: 13,
                            color: NeoColors.muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: NeoSpacing.spaceXs),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isBacklogScope ? l10n.ticketsBacklogListView : l10n.ticketsSprintTicketsTitle,
                  style: NeoTypography.headlineLg,
                ),
                const SizedBox(width: NeoSpacing.spaceSm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: NeoColors.surfaceContainerHigh,
                    borderRadius: NeoSpacing.roundedFull,
                  ),
                  child: Text(
                    '$totalTicketsCount',
                    style: NeoTypography.codeSm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: NeoColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              isBacklogScope
                  ? l10n.ticketsBacklogHeaderDesc
                  : l10n.ticketsSprintHeaderDesc,
              style: NeoTypography.bodyMd.copyWith(color: NeoColors.muted),
            ),
          ],
        ),

        // Quick Navigation & Creation Actions
        Wrap(
          spacing: NeoSpacing.spaceSm,
          runSpacing: NeoSpacing.spaceXs,
          children: [
            OutlinedButton.icon(
              onPressed: () => context.go('/projects'),
              icon: const Icon(Icons.folder_copy_outlined, size: 16),
              label: Text(l10n.savedviewAllProjects),
              style: OutlinedButton.styleFrom(
                foregroundColor: NeoColors.onSurface,
                side: const BorderSide(color: NeoColors.borderWhisper),
                shape: RoundedRectangleBorder(borderRadius: NeoSpacing.roundedMd),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/kanban'),
              icon: const Icon(Icons.view_kanban_outlined, size: 16),
              label: Text(l10n.ticketsKanbanBoard),
              style: OutlinedButton.styleFrom(
                foregroundColor: NeoColors.onSurface,
                side: const BorderSide(color: NeoColors.borderWhisper),
                shape: RoundedRectangleBorder(borderRadius: NeoSpacing.roundedMd),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/cycles'),
              icon: const Icon(Icons.autorenew_rounded, size: 16),
              label: Text(l10n.ticketsManageSprints),
              style: OutlinedButton.styleFrom(
                foregroundColor: NeoColors.onSurface,
                side: const BorderSide(color: NeoColors.borderWhisper),
                shape: RoundedRectangleBorder(borderRadius: NeoSpacing.roundedMd),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (isDesktop) {
                  DesktopCreateTicketDialog.show(context, initialProjectId: widget.projectId);
                } else {
                  MobileCreateTicketSheet.show(context, initialProjectId: widget.projectId);
                }
              },
              icon: const Icon(Icons.add, size: 16),
              label: Text(l10n.ticketsCreateTicket),
              style: ElevatedButton.styleFrom(
                backgroundColor: NeoColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: NeoSpacing.roundedMd),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScopeSelectorBar(List<SprintDto> sprints, int currentCount) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildScopeChip(
            label: l10n.ticketsBacklogScopeChip,
            icon: Icons.inbox_outlined,
            isSelected: _selectedSprintScopeId == null,
            badgeText: _selectedSprintScopeId == null ? '$currentCount' : null,
            onTap: () => setState(() => _selectedSprintScopeId = null),
          ),
          if (sprints.isNotEmpty) ...[
            const SizedBox(width: NeoSpacing.spaceSm),
            Container(width: 1, height: 20, color: NeoColors.borderWhisper),
            const SizedBox(width: NeoSpacing.spaceSm),
            ...sprints.map((sprint) {
              final isSelected = _selectedSprintScopeId == sprint.id;
              final isActive = sprint.status == SprintStatus.active;
              return Padding(
                padding: const EdgeInsets.only(right: NeoSpacing.spaceXs),
                child: _buildScopeChip(
                  label: isActive ? '${sprint.name} (${l10n.sprintStatusActive})' : sprint.name,
                  icon: isActive ? Icons.bolt_rounded : Icons.timelapse_outlined,
                  iconColor: isActive ? NeoColors.emerald : null,
                  isSelected: isSelected,
                  badgeText: '${sprint.ticketCount}',
                  onTap: () => setState(() => _selectedSprintScopeId = sprint.id),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildScopeChip({
    required String label,
    required IconData icon,
    Color? iconColor,
    required bool isSelected,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: NeoSpacing.roundedMd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? NeoColors.primary : NeoColors.surfaceContainerLow,
          borderRadius: NeoSpacing.roundedMd,
          border: Border.all(
            color: isSelected ? NeoColors.primary : NeoColors.borderWhisper,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? const Color(0xFFFFD21E)
                  : (iconColor ?? NeoColors.muted),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: NeoTypography.labelSm.copyWith(
                color: isSelected ? Colors.white : NeoColors.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (badgeText != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.18)
                      : NeoColors.surfaceContainerHigh,
                  borderRadius: NeoSpacing.roundedSm,
                ),
                child: Text(
                  badgeText,
                  style: NeoTypography.codeSm.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : NeoColors.muted,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterBar({
    required List<SprintDto> openSprints,
    required Set<String> selectedIds,
  }) {
    final l10n = context.l10n;
    return Wrap(
      spacing: NeoSpacing.spaceSm,
      runSpacing: NeoSpacing.spaceSm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Search Input
        SizedBox(
          width: 320,
          height: 36,
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            style: NeoTypography.bodySm,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: l10n.ticketsFilterTicketsHint,
              hintStyle: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
              prefixIcon: const Icon(Icons.search, size: 16, color: NeoColors.muted),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 14),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: NeoColors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: NeoSpacing.roundedMd,
                borderSide: const BorderSide(color: NeoColors.borderWhisper),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: NeoSpacing.roundedMd,
                borderSide: const BorderSide(color: NeoColors.borderWhisper),
              ),
            ),
          ),
        ),

        // Priority filter
        PopupMenuButton<String>(
          tooltip: l10n.ticketsFilterByPriority,
          onSelected: (priorityKey) {
            setState(() {
              if (priorityKey == '__ALL__') {
                _priorityFilter = null;
              } else {
                _priorityFilter = CardPriority.values.firstWhere(
                  (p) => p.name == priorityKey,
                );
              }
            });
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: '__ALL__',
              child: Text(l10n.savedviewAllPriorities),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: CardPriority.critical.name,
              child: Text(CardPriority.critical.localizedLabel(l10n)),
            ),
            PopupMenuItem(
              value: CardPriority.high.name,
              child: Text(CardPriority.high.localizedLabel(l10n)),
            ),
            PopupMenuItem(
              value: CardPriority.medium.name,
              child: Text(CardPriority.medium.localizedLabel(l10n)),
            ),
            PopupMenuItem(
              value: CardPriority.low.name,
              child: Text(CardPriority.low.localizedLabel(l10n)),
            ),
          ],
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _priorityFilter != null
                  ? NeoColors.kineticAmber.withValues(alpha: 0.16)
                  : NeoColors.surfaceContainerLow,
              borderRadius: NeoSpacing.roundedMd,
              border: Border.all(
                color: _priorityFilter != null
                    ? NeoColors.kineticAmber
                    : NeoColors.borderWhisper,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flag_outlined, size: 15, color: NeoColors.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  _priorityFilter == null
                      ? l10n.ticketsPriorityAll
                      : l10n.ticketsPrioritySelected(
                          _priorityFilter!.localizedLabel(l10n).toUpperCase(),
                        ),
                  style: NeoTypography.labelSm.copyWith(
                    color: NeoColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 16, color: NeoColors.muted),
              ],
            ),
          ),
        ),

        // Batch move to Sprint button when tickets are selected
        if (selectedIds.isNotEmpty && openSprints.isNotEmpty)
          PopupMenuButton<SprintDto>(
            tooltip: l10n.ticketsAssignSelectionToSprint,
            onSelected: (sprint) => _assignTicketsToSprint(selectedIds, sprint),
            itemBuilder: (context) => openSprints
                .map(
                  (s) => PopupMenuItem(
                    value: s,
                    child: Row(
                      children: [
                        Icon(
                          s.status == SprintStatus.active
                              ? Icons.bolt_rounded
                              : Icons.timelapse_outlined,
                          size: 16,
                          color: s.status == SprintStatus.active
                              ? NeoColors.emerald
                              : NeoColors.muted,
                        ),
                        const SizedBox(width: 8),
                        Text(s.name),
                      ],
                    ),
                  ),
                )
                .toList(),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: NeoColors.kineticAmber,
                borderRadius: NeoSpacing.roundedMd,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.drive_file_move_outlined, size: 16, color: NeoColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    l10n.ticketsPlanInSprint(selectedIds.length),
                    style: NeoTypography.labelSm.copyWith(
                      color: NeoColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 16, color: NeoColors.primary),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(NeoSpacing.space2Xl),
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLow,
        borderRadius: NeoSpacing.roundedLg,
        border: Border.all(color: NeoColors.borderWhisper),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.format_list_bulleted,
              size: 48,
              color: NeoColors.muted,
            ),
            const SizedBox(height: NeoSpacing.spaceMd),
            Text(
              _selectedSprintScopeId == null
                  ? l10n.ticketsNoTicketBacklog
                  : l10n.ticketsNoTicketSprint,
              style: NeoTypography.headlineMd,
            ),
            const SizedBox(height: NeoSpacing.spaceSm),
            Text(
              l10n.ticketsAddFirstQuickTask,
              style: NeoTypography.bodyMd.copyWith(color: NeoColors.muted),
            ),
            const SizedBox(height: NeoSpacing.spaceLg),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: TextField(
                controller: _quickControllers[StatusCategory.backlog],
                decoration: InputDecoration(
                  hintText: l10n.ticketsQuickAddHint,
                  prefixIcon: const Icon(Icons.add, size: 18),
                ),
                onSubmitted: (_) => _handleQuickAdd(StatusCategory.backlog),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required StatusCategory category,
    required List<TicketDto> tickets,
    required Set<String> selectedIds,
    required bool isDesktop,
    required List<SprintDto> openSprints,
  }) {
    final l10n = context.l10n;
    final isExpanded = _expandedSections[category] ?? true;

    return Container(
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLowest,
        borderRadius: NeoSpacing.roundedLg,
        border: Border.all(color: NeoColors.borderWhisper),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Header
          InkWell(
            onTap: () {
              setState(() {
                _expandedSections[category] = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: NeoSpacing.spaceMd,
                vertical: NeoSpacing.spaceSm + 2,
              ),
              decoration: BoxDecoration(
                color: NeoColors.surfaceContainerLow,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(NeoSpacing.radiusLg),
                  bottom: Radius.circular(isExpanded ? 0 : NeoSpacing.radiusLg),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    size: 18,
                    color: NeoColors.muted,
                  ),
                  const SizedBox(width: NeoSpacing.spaceXs),
                  Icon(icon, size: 16, color: iconColor),
                  const SizedBox(width: NeoSpacing.spaceSm),
                  Text(
                    title,
                    style: NeoTypography.labelMd.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: NeoSpacing.spaceSm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: NeoColors.surfaceContainerHigh,
                      borderRadius: NeoSpacing.roundedSm,
                    ),
                    child: Text(
                      '${tickets.length}',
                      style: NeoTypography.codeSm.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: NeoColors.muted,
                      ),
                    ),
                  ),
                  if (isDesktop) ...[
                    const SizedBox(width: NeoSpacing.spaceSm),
                    Expanded(
                      child: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NeoTypography.bodySm.copyWith(
                          color: NeoColors.muted,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Section Content
          if (isExpanded) ...[
            if (tickets.isEmpty)
              Padding(
                padding: const EdgeInsets.all(NeoSpacing.spaceMd),
                child: Text(
                  l10n.ticketsNoTaskInSection,
                  style: NeoTypography.bodySm.copyWith(
                    color: NeoColors.muted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ...tickets.map(
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
                    _refreshCurrentScope();
                  },
                ),
              ),

            // Inline Quick Add Field
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: NeoSpacing.spaceMd,
                vertical: 6,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: NeoColors.borderWhisper, width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add,
                    size: 16,
                    color: NeoColors.muted,
                  ),
                  const SizedBox(width: NeoSpacing.spaceSm),
                  Expanded(
                    child: TextField(
                      controller: _quickControllers[category],
                      style: NeoTypography.bodySm,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        hintText: l10n.ticketsQuickAddInSection(title),
                        hintStyle: NeoTypography.bodySm.copyWith(
                          color: NeoColors.muted,
                          fontStyle: FontStyle.italic,
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _handleQuickAdd(category),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: NeoColors.surfaceContainerLow,
                      borderRadius: NeoSpacing.roundedSm,
                      border: Border.all(color: NeoColors.borderWhisper),
                    ),
                    child: Text(
                      l10n.ticketsEnterKey,
                      style: NeoTypography.codeSm.copyWith(
                        fontSize: 9,
                        color: NeoColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
