import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/sprint_models.dart';
import 'package:disciplaner_flutter/core/widgets/kbd_chip.dart';
import 'package:disciplaner_flutter/core/widgets/neo_button.dart';
import 'package:disciplaner_flutter/core/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../sprint_providers.dart';

class SprintMetricsHeader extends ConsumerWidget {
  final SprintDto sprint;
  final SprintMetrics? metrics;
  final VoidCallback? onStart;
  final VoidCallback? onClose;
  final VoidCallback? onNewTicket;

  const SprintMetricsHeader({
    super.key,
    required this.sprint,
    this.metrics,
    this.onStart,
    this.onClose,
    this.onNewTicket,
  });

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return 'Dates non définies';
    final formatter = DateFormat('d MMM', 'fr_FR');
    final s = start != null ? formatter.format(start) : '?';
    final e = end != null ? formatter.format(end) : '?';
    return '$s – $e';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = metrics ??
        SprintMetrics.fromTickets(
          tickets: const [],
          endDate: sprint.endDate,
        );

    final isActive = sprint.status == SprintStatus.active;
    final isPlanned = sprint.status == SprintStatus.planned;

    return Container(
      padding: const EdgeInsets.all(NeoSpacing.spaceLg),
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLowest,
        borderRadius: NeoSpacing.roundedXl,
        border: Border.all(color: NeoColors.borderWhisper),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Bar: Badges + Action Buttons
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Status badge, date range, remaining days
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? NeoColors.kineticAmber.withValues(alpha: 0.15)
                                : (isPlanned
                                    ? NeoColors.surfaceContainerHigh
                                    : NeoColors.emerald.withValues(alpha: 0.12)),
                            borderRadius: NeoSpacing.roundedFull,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? NeoColors.secondary
                                      : (isPlanned
                                          ? NeoColors.muted
                                          : NeoColors.emerald),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isActive
                                    ? 'Sprint Actif'
                                    : (isPlanned ? 'Planifié' : 'Clôturé'),
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isActive
                                      ? NeoColors.secondary
                                      : (isPlanned
                                          ? NeoColors.onSurfaceVariant
                                          : NeoColors.emerald),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Date range
                        Text(
                          _formatDateRange(sprint.startDate, sprint.endDate),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            color: NeoColors.muted,
                          ),
                        ),

                        // Days remaining badge (if active)
                        if (isActive && sprint.endDate != null) ...[
                          Text('•', style: NeoTypography.bodySm.copyWith(color: NeoColors.muted)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: NeoColors.error.withValues(alpha: 0.1),
                              borderRadius: NeoSpacing.roundedSm,
                            ),
                            child: Text(
                              'J-${m.daysRemaining} restants',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: NeoColors.error,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: NeoSpacing.spaceSm),

                    // Sprint Title
                    Text(
                      sprint.name,
                      style: NeoTypography.headlineLg.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),

                    // Sprint Goal
                    if (sprint.goal != null && sprint.goal!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        sprint.goal!,
                        style: NeoTypography.bodyMd.copyWith(
                          color: NeoColors.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Right: Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPlanned && onStart != null)
                    NeoButton(
                      label: 'Démarrer le cycle',
                      icon: const Icon(Icons.play_arrow_outlined, size: 16),
                      onPressed: onStart,
                    ),

                  if (isActive && onClose != null)
                    NeoButton(
                      label: 'Terminer le sprint',
                      variant: NeoButtonVariant.secondary,
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      onPressed: onClose,
                    ),

                  if (onNewTicket != null) ...[
                    const SizedBox(width: NeoSpacing.spaceSm),
                    NeoButton(
                      label: 'Nouvelle tâche',
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: onNewTicket,
                    ),
                    const SizedBox(width: 4),
                    const KbdChip(label: 'C'),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: NeoSpacing.spaceLg),

          // 2. Tapis de Métriques Douces & Jauge Burn-down
          Container(
            padding: const EdgeInsets.all(NeoSpacing.spaceMd),
            decoration: BoxDecoration(
              color: NeoColors.surfaceContainerLow,
              borderRadius: NeoSpacing.roundedLg,
              border: Border.all(color: NeoColors.borderWhisper),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    Wrap(
                      spacing: NeoSpacing.spaceMd,
                      runSpacing: NeoSpacing.spaceSm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Closed tickets
                        _buildMetricChip(
                          icon: Icons.task_alt,
                          iconColor: NeoColors.emerald,
                          label: '${m.closedTickets}/${m.totalTickets} terminées',
                          sublabel: '(${m.completionPercentage.toInt()}%)',
                        ),

                        // Remaining tickets
                        _buildMetricChip(
                          icon: Icons.pending_actions_outlined,
                          iconColor: NeoColors.secondary,
                          label: '${m.totalTickets - m.closedTickets} restantes',
                          sublabel: 'en cours / à faire',
                        ),

                        // Contributors
                        if (m.activeMemberNames.isNotEmpty) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.group_outlined,
                                size: 16,
                                color: NeoColors.muted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${m.activeMemberNames.length} contributeurs',
                                style: NeoTypography.bodySm.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildStackedAvatars(m.activeMemberNames),
                            ],
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: NeoSpacing.spaceMd),

                    // Burn-down progress bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Burn-down d\'équipe',
                              style: NeoTypography.labelSm.copyWith(
                                color: NeoColors.muted,
                              ),
                            ),
                            Text(
                              '${m.completionPercentage.toInt()}% complété',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: NeoColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: NeoSpacing.roundedFull,
                          child: LinearProgressIndicator(
                            value: m.totalTickets == 0
                                ? 0.0
                                : (m.closedTickets / m.totalTickets).clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: NeoColors.surfaceContainerHigh,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              NeoColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String sublabel,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: NeoTypography.bodySm.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 4),
        Text(
          sublabel,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            color: NeoColors.muted,
          ),
        ),
      ],
    );
  }

  Widget _buildStackedAvatars(List<String> names) {
    final displayList = names.take(4).toList();
    return SizedBox(
      height: 22,
      width: 22.0 + (displayList.length - 1) * 14.0,
      child: Stack(
        children: [
          for (int i = 0; i < displayList.length; i++)
            Positioned(
              left: i * 14.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: NeoColors.surfaceContainerLow,
                    width: 1.5,
                  ),
                ),
                child: UserAvatar(name: displayList[i], size: 20),
              ),
            ),
        ],
      ),
    );
  }
}
