import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/core/models/sprint_models.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_state.dart';
import 'package:disciplaner_flutter/features/sprints/presentation/sprint_providers.dart';
import 'package:disciplaner_flutter/features/sprints/presentation/widgets/sprint_metrics_header.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/ticket_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/split_inspector_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'kanban_providers.dart';
import 'widgets/kanban_ticket_card.dart';

class DesktopSprintKanbanView extends ConsumerStatefulWidget {
  final SprintDto sprint;
  final List<SprintDto> availableSprints;
  final ValueChanged<SprintDto>? onSelectSprint;

  const DesktopSprintKanbanView({
    super.key,
    required this.sprint,
    this.availableSprints = const [],
    this.onSelectSprint,
  });

  @override
  ConsumerState<DesktopSprintKanbanView> createState() =>
      _DesktopSprintKanbanViewState();
}

class _DesktopSprintKanbanViewState
    extends ConsumerState<DesktopSprintKanbanView> {
  final _searchController = TextEditingController();
  bool _showMetrics = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kanbanAsync = ref.watch(kanbanStateProvider(widget.sprint.id));
    final metricsAsync = ref.watch(sprintMetricsProvider(widget.sprint.id));
    final authState = ref.watch(authNotifierProvider);

    final currentUserId =
        authState is AuthAuthenticated ? authState.session.email : null;
    final selectedDetailId = ref.watch(selectedTicketDetailIdProvider);
    final screenSize = MediaQuery.of(context).size;
    // Automatically collapse metrics header on very short viewports unless toggled
    final effectiveShowMetrics = _showMetrics && screenSize.height >= 540;

    final kanbanBody = Padding(
      padding: NeoSpacing.responsivePagePadding(screenSize.width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Collapsible Sprint Metrics Header
          if (effectiveShowMetrics) ...[
            SprintMetricsHeader(
              sprint: widget.sprint,
              metrics: metricsAsync.value,
            ),
            const SizedBox(height: NeoSpacing.spaceMd),
          ],

          // 2. Inline Contextual Filter & Sprint Switcher Bar
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: NeoSpacing.spaceSm,
            runSpacing: NeoSpacing.spaceXs,
            children: [
              // Left side: Search & Quick Filters
              Wrap(
                spacing: NeoSpacing.spaceSm,
                runSpacing: NeoSpacing.spaceXs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Sprint Switcher if multiple sprints exist
                  if (widget.availableSprints.length > 1 &&
                      widget.onSelectSprint != null)
                    PopupMenuButton<SprintDto>(
                      tooltip: 'Changer de sprint affiché',
                      onSelected: widget.onSelectSprint,
                      itemBuilder: (context) => widget.availableSprints
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
                                  Expanded(
                                    child: Text(
                                      s.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (s.status == SprintStatus.active)
                                    Container(
                                      margin: const EdgeInsets.only(left: 6),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: NeoColors.emerald.withValues(alpha: 0.14),
                                        borderRadius: NeoSpacing.roundedSm,
                                      ),
                                      child: Text(
                                        'ACTIF',
                                        style: NeoTypography.codeSm.copyWith(
                                          fontSize: 9,
                                          color: NeoColors.emerald,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: NeoColors.surfaceContainerLow,
                          borderRadius: NeoSpacing.roundedMd,
                          border: Border.all(color: NeoColors.borderWhisper),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.sprint.status == SprintStatus.active
                                  ? Icons.bolt_rounded
                                  : Icons.timelapse_outlined,
                              size: 15,
                              color: widget.sprint.status == SprintStatus.active
                                  ? NeoColors.emerald
                                  : NeoColors.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.sprint.name,
                              style: NeoTypography.labelSm.copyWith(
                                fontWeight: FontWeight.w700,
                                color: NeoColors.onSurface,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, size: 16, color: NeoColors.muted),
                          ],
                        ),
                      ),
                    ),

                  // Search input
                  SizedBox(
                    width: 240,
                    height: 36,
                    child: TextField(
                      controller: _searchController,
                      style: NeoTypography.bodySm,
                      decoration: InputDecoration(
                        hintText: 'Filtrer les cartes...',
                        hintStyle: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                        prefixIcon: const Icon(Icons.search, size: 16, color: NeoColors.muted),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
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
                      onChanged: (q) => ref
                          .read(kanbanStateProvider(widget.sprint.id).notifier)
                          .setSearchQuery(q),
                    ),
                  ),

                  kanbanAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (error, stack) => const SizedBox.shrink(),
                    data: (kState) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Only Mine Filter Pill
                          FilterChip(
                            label: Text(
                              'Mes tâches',
                              style: NeoTypography.labelSm.copyWith(
                                color: kState.onlyAssignedToMe
                                    ? Colors.white
                                    : NeoColors.onSurfaceVariant,
                              ),
                            ),
                            selected: kState.onlyAssignedToMe,
                            selectedColor: NeoColors.primary,
                            backgroundColor: NeoColors.surfaceContainerLow,
                            side: const BorderSide(color: NeoColors.borderWhisper),
                            shape: RoundedRectangleBorder(
                              borderRadius: NeoSpacing.roundedFull,
                            ),
                            onSelected: (_) => ref
                                .read(kanbanStateProvider(widget.sprint.id).notifier)
                                .toggleOnlyAssignedToMe(),
                          ),
                          const SizedBox(width: NeoSpacing.spaceSm),

                          // Urgent / High Priority Filter Pill
                          FilterChip(
                            label: Text(
                              'Priorité Haute',
                              style: NeoTypography.labelSm.copyWith(
                                color: kState.selectedPriority == CardPriority.high
                                    ? Colors.white
                                    : NeoColors.onSurfaceVariant,
                              ),
                            ),
                            selected: kState.selectedPriority == CardPriority.high,
                            selectedColor: NeoColors.primary,
                            backgroundColor: NeoColors.surfaceContainerLow,
                            side: const BorderSide(color: NeoColors.borderWhisper),
                            shape: RoundedRectangleBorder(
                              borderRadius: NeoSpacing.roundedFull,
                            ),
                            onSelected: (selected) {
                              ref
                                  .read(kanbanStateProvider(widget.sprint.id).notifier)
                                  .setPriorityFilter(selected ? CardPriority.high : null);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),

              // Right side: Toggle Metrics Header & Backlog shortcut
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () => setState(() => _showMetrics = !_showMetrics),
                    icon: Icon(
                      _showMetrics ? Icons.expand_less : Icons.analytics_outlined,
                      size: 16,
                    ),
                    label: Text(_showMetrics ? 'Masquer en-tête' : 'Afficher métriques'),
                    style: TextButton.styleFrom(
                      foregroundColor: NeoColors.muted,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  if (GoRouter.maybeOf(context) != null) ...[
                    const SizedBox(width: NeoSpacing.spaceXs),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/backlog'),
                      icon: const Icon(Icons.inbox_outlined, size: 15),
                      label: const Text('Backlog'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: NeoColors.onSurface,
                        visualDensity: VisualDensity.compact,
                        side: const BorderSide(color: NeoColors.borderWhisper),
                        shape: RoundedRectangleBorder(borderRadius: NeoSpacing.roundedMd),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: NeoSpacing.spaceMd),

          // 3. Responsive Kanban Columns Board (fills remaining vertical space)
          Expanded(
            child: kanbanAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: NeoColors.primary),
              ),
              error: (err, _) => Center(
                child: Text('Erreur de chargement du tableau: $err'),
              ),
              data: (kState) {
                if (kState.statuses.isEmpty) {
                  return const Center(
                    child: Text('Aucun statut défini pour ce projet.'),
                  );
                }

                return LayoutBuilder(
                  builder: (context, boardConstraints) {
                    // Calculate adaptive column width: if columns fit across the screen, distribute evenly up to 360px
                    final count = kState.statuses.length;
                    final totalGaps = (count - 1) * NeoSpacing.spaceMd;
                    final computedWidth =
                        (boardConstraints.maxWidth - totalGaps) / count;
                    final columnWidth = computedWidth.clamp(280.0, 360.0);

                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: kState.statuses.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: NeoSpacing.spaceMd),
                      itemBuilder: (context, index) {
                        final status = kState.statuses[index];
                        final tickets = kState.getFilteredTicketsForStatus(
                          status.id,
                          currentUserId,
                        );

                        return _buildKanbanColumn(
                          context: context,
                          status: status,
                          tickets: tickets,
                          allStatuses: kState.statuses,
                          columnWidth: columnWidth,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: NeoColors.surfaceContainerLowest,
      body: Row(
        children: [
          Expanded(child: kanbanBody),
          if (selectedDetailId != null)
            SplitInspectorPanel(
              ticketId: selectedDetailId,
              onClose: () =>
                  ref.read(selectedTicketDetailIdProvider.notifier).clear(),
            ),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn({
    required BuildContext context,
    required TicketStatusDto status,
    required List<TicketDto> tickets,
    required List<TicketStatusDto> allStatuses,
    required double columnWidth,
  }) {
    final statusColor = Color(
      int.tryParse(status.color.replaceAll('#', '0xFF')) ?? 0xFFE5A800,
    );

    return DragTarget<TicketDto>(
      onWillAcceptWithDetails: (details) => details.data.status.id != status.id,
      onAcceptWithDetails: (details) {
        ref
            .read(kanbanStateProvider(widget.sprint.id).notifier)
            .moveTicket(details.data.id, status.id);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return Container(
          width: columnWidth,
          decoration: BoxDecoration(
            color: isHovered
                ? NeoColors.kineticAmber.withValues(alpha: 0.08)
                : NeoColors.surfaceContainerLow,
            borderRadius: NeoSpacing.roundedXl,
            border: Border.all(
              color: isHovered ? NeoColors.kineticAmber : NeoColors.borderWhisper,
              width: isHovered ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Column Header
              Padding(
                padding: const EdgeInsets.all(NeoSpacing.spaceMd),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: NeoSpacing.spaceSm),
                    Expanded(
                      child: Text(
                        status.name,
                        style: NeoTypography.headlineSm.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                      decoration: BoxDecoration(
                        color: NeoColors.surfaceContainerHighest,
                        borderRadius: NeoSpacing.roundedSm,
                      ),
                      child: Text(
                        '${tickets.length}',
                        style: NeoTypography.codeSm.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: NeoColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Cards List
              Expanded(
                child: tickets.isEmpty
                    ? Center(
                        child: Text(
                          'Glisser une tâche ici',
                          style: NeoTypography.bodySm.copyWith(
                            color: NeoColors.muted,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(NeoSpacing.spaceSm),
                        itemCount: tickets.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: NeoSpacing.spaceSm),
                        itemBuilder: (context, i) {
                          final ticket = tickets[i];

                          return Draggable<TicketDto>(
                            data: ticket,
                            feedback: Material(
                              color: Colors.transparent,
                              child: SizedBox(
                                width: columnWidth - 16,
                                child: Opacity(
                                  opacity: 0.95,
                                  child: KanbanTicketCard(
                                    ticket: ticket,
                                    availableStatuses: allStatuses,
                                  ),
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.35,
                              child: KanbanTicketCard(
                                ticket: ticket,
                                availableStatuses: allStatuses,
                              ),
                            ),
                            child: KanbanTicketCard(
                              ticket: ticket,
                              availableStatuses: allStatuses,
                              onTap: () {
                                ref
                                    .read(selectedTicketDetailIdProvider.notifier)
                                    .select(ticket.id);
                              },
                              onMoveToStatus: (targetId) {
                                ref
                                    .read(kanbanStateProvider(widget.sprint.id).notifier)
                                    .moveTicket(ticket.id, targetId);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
