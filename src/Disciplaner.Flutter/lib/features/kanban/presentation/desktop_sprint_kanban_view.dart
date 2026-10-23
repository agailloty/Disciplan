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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/ticket_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/split_inspector_panel.dart';
import 'kanban_providers.dart';
import 'widgets/kanban_ticket_card.dart';

class DesktopSprintKanbanView extends ConsumerStatefulWidget {
  final SprintDto sprint;

  const DesktopSprintKanbanView({
    super.key,
    required this.sprint,
  });

  @override
  ConsumerState<DesktopSprintKanbanView> createState() =>
      _DesktopSprintKanbanViewState();
}

class _DesktopSprintKanbanViewState
    extends ConsumerState<DesktopSprintKanbanView> {
  final _searchController = TextEditingController();

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

    final kanbanBody = ListView(
        padding: const EdgeInsets.all(NeoSpacing.spaceLg),
        children: [
          // 1. Sprint Metrics Header
          SprintMetricsHeader(
            sprint: widget.sprint,
            metrics: metricsAsync.value,
          ),
          const SizedBox(height: NeoSpacing.spaceLg),

          // 2. Inline Contextual Filter Bar
          Row(
            children: [
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
              const SizedBox(width: NeoSpacing.spaceSm),

              kanbanAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (error, stack) => const SizedBox.shrink(),
                data: (kState) {
                  return Row(
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
          const SizedBox(height: NeoSpacing.spaceLg),

          // 3. Kanban Columns Board
          kanbanAsync.when(
            loading: () => const SizedBox(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(color: NeoColors.primary),
              ),
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

              return SizedBox(
                height: 640,
                child: ListView.separated(
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
                    );
                  },
                ),
              );
            },
          ),
        ],
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
          width: 300,
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
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: NeoColors.surfaceContainerHighest,
                        borderRadius: NeoSpacing.roundedSm,
                      ),
                      child: Text(
                        '${tickets.length}',
                        style: GoogleFonts.jetBrainsMono(
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

                          return LongPressDraggable<TicketDto>(
                            data: ticket,
                            feedback: Material(
                              color: Colors.transparent,
                              child: SizedBox(
                                width: 280,
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
