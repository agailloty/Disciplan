import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/core/models/sprint_models.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_state.dart';
import 'package:disciplaner_flutter/features/sprints/presentation/sprint_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/mobile_ticket_detail_sheet.dart';
import 'kanban_providers.dart';
import 'widgets/kanban_ticket_card.dart';

class MobileSprintKanbanView extends ConsumerStatefulWidget {
  final SprintDto sprint;

  const MobileSprintKanbanView({
    super.key,
    required this.sprint,
  });

  @override
  ConsumerState<MobileSprintKanbanView> createState() =>
      _MobileSprintKanbanViewState();
}

class _MobileSprintKanbanViewState extends ConsumerState<MobileSprintKanbanView> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final kanbanAsync = ref.watch(kanbanStateProvider(widget.sprint.id));
    final metricsAsync = ref.watch(sprintMetricsProvider(widget.sprint.id));
    final authState = ref.watch(authNotifierProvider);

    final currentUserId =
        authState is AuthAuthenticated ? authState.session.email : null;
    final metrics = metricsAsync.value;

    return Scaffold(
      backgroundColor: NeoColors.surfaceContainerLowest,
      body: kanbanAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: NeoColors.primary),
        ),
        error: (err, _) => Center(
          child: Text('Erreur: $err'),
        ),
        data: (kState) {
          if (kState.statuses.isEmpty) {
            return const Center(child: Text('Aucun statut disponible.'));
          }

          if (_selectedTabIndex >= kState.statuses.length) {
            _selectedTabIndex = 0;
          }
          final activeStatus = kState.statuses[_selectedTabIndex];
          final tickets = kState.getFilteredTicketsForStatus(
            activeStatus.id,
            currentUserId,
          );

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: NeoSpacing.spaceMd,
              vertical: NeoSpacing.spaceMd,
            ),
            children: [
              // 1. Compact Mobile Sprint Header Card
              Container(
                padding: const EdgeInsets.all(NeoSpacing.spaceMd),
                decoration: BoxDecoration(
                  color: NeoColors.surfaceContainerLow,
                  borderRadius: NeoSpacing.roundedLg,
                  border: Border.all(color: NeoColors.borderWhisper),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.sprint.name,
                          style: NeoTypography.headlineSm.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (metrics != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: NeoColors.error.withValues(alpha: 0.1),
                              borderRadius: NeoSpacing.roundedSm,
                            ),
                            child: Text(
                              'J-${metrics.daysRemaining}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: NeoColors.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Burn-down progress bar
                    if (metrics != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${metrics.closedTickets}/${metrics.totalTickets} terminées',
                            style: NeoTypography.labelSm.copyWith(
                              color: NeoColors.muted,
                            ),
                          ),
                          Text(
                            '${metrics.completionPercentage.toInt()}%',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: NeoColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: NeoSpacing.roundedFull,
                        child: LinearProgressIndicator(
                          value: (metrics.completionPercentage / 100.0).clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: NeoColors.surfaceContainerHigh,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            NeoColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: NeoSpacing.spaceMd),

              // 2. Sliding Status Tabs (Horizontal Pills)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0; i < kState.statuses.length; i++) ...[
                      _buildStatusTabPill(
                        status: kState.statuses[i],
                        isSelected: _selectedTabIndex == i,
                        count: (kState.ticketsByStatus[kState.statuses[i].id] ?? []).length,
                        onTap: () => setState(() => _selectedTabIndex = i),
                      ),
                      const SizedBox(width: NeoSpacing.spaceSm),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: NeoSpacing.spaceMd),

              // 3. Active Column Cards Stream
              if (tickets.isEmpty)
                Container(
                  padding: const EdgeInsets.all(NeoSpacing.spaceXl),
                  alignment: Alignment.center,
                  child: Text(
                    'Aucune tâche dans "${activeStatus.name}"',
                    style: NeoTypography.bodyMd.copyWith(
                      color: NeoColors.muted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else
                ...tickets.map(
                  (ticket) => Padding(
                    padding: const EdgeInsets.only(bottom: NeoSpacing.spaceSm),
                    child: KanbanTicketCard(
                      ticket: ticket,
                      availableStatuses: kState.statuses,
                      onTap: () => MobileTicketDetailSheet.show(context, ticket.id),
                      onMoveToStatus: (targetId) {
                        ref
                            .read(kanbanStateProvider(widget.sprint.id).notifier)
                            .moveTicket(ticket.id, targetId);
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusTabPill({
    required TicketStatusDto status,
    required bool isSelected,
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: NeoSpacing.roundedFull,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? NeoColors.primary : NeoColors.surfaceContainerLow,
          borderRadius: NeoSpacing.roundedFull,
          border: Border.all(
            color: isSelected ? NeoColors.primary : NeoColors.borderWhisper,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              status.name,
              style: NeoTypography.bodySm.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : NeoColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? NeoColors.secondaryContainer
                    : NeoColors.surfaceContainerHigh,
                borderRadius: NeoSpacing.roundedFull,
              ),
              child: Text(
                '$count',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? NeoColors.primary : NeoColors.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
