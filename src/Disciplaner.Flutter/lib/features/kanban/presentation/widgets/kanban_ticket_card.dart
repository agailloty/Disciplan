import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/core/widgets/priority_icon.dart';
import 'package:disciplaner_flutter/core/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KanbanTicketCard extends StatelessWidget {
  final TicketDto ticket;
  final List<TicketStatusDto> availableStatuses;
  final ValueChanged<String>? onMoveToStatus;
  final VoidCallback? onTap;

  const KanbanTicketCard({
    super.key,
    required this.ticket,
    this.availableStatuses = const [],
    this.onMoveToStatus,
    this.onTap,
  });

  TicketPriority _mapPriority(CardPriority p) {
    switch (p) {
      case CardPriority.low:
        return TicketPriority.low;
      case CardPriority.medium:
        return TicketPriority.medium;
      case CardPriority.high:
        return TicketPriority.high;
      case CardPriority.critical:
        return TicketPriority.urgent;
    }
  }

  String _formatDueDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return "Aujourd'hui";
    if (diff == 1) return 'Demain';
    if (diff == -1) return 'Hier';
    return DateFormat('d MMM', 'fr_FR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: NeoSpacing.roundedLg,
        child: Container(
          padding: const EdgeInsets.all(NeoSpacing.spaceMd),
          decoration: BoxDecoration(
            color: NeoColors.surfaceContainerLowest,
            borderRadius: NeoSpacing.roundedLg,
            border: Border.all(color: NeoColors.borderWhisper),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top line: Priority, Key, Domain Tag, Menu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      PriorityIcon(priority: _mapPriority(ticket.priority), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        ticket.ticketRef,
                        style: NeoTypography.codeSm.copyWith(
                          color: NeoColors.muted,
                        ),
                      ),
                    ],
                  ),

                  // Move Status Menu
                  if (availableStatuses.length > 1 && onMoveToStatus != null)
                    PopupMenuButton<String>(
                      tooltip: 'Déplacer vers...',
                      icon: const Icon(Icons.more_horiz, size: 16, color: NeoColors.muted),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: NeoSpacing.roundedMd,
                        side: const BorderSide(color: NeoColors.borderWhisper),
                      ),
                      onSelected: onMoveToStatus,
                      itemBuilder: (context) => availableStatuses
                          .where((s) => s.id != ticket.status.id)
                          .map((s) => PopupMenuItem(
                                value: s.id,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Color(int.tryParse(s.color.replaceAll('#', '0xFF')) ?? 0xFFE5A800),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(s.name, style: NeoTypography.bodySm),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                ],
              ),
              const SizedBox(height: NeoSpacing.spaceSm),

              // Title
              Text(
                ticket.title,
                style: NeoTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Description excerpt if present
              if (ticket.description != null && ticket.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  ticket.description!,
                  style: NeoTypography.bodySm.copyWith(
                    color: NeoColors.muted,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: NeoSpacing.spaceSm),

              // Bottom line: Due date, story points, Assignee Avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Due Date
                  if (ticket.dueDate != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: NeoColors.muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDueDate(ticket.dueDate),
                          style: NeoTypography.labelSm.copyWith(
                            fontSize: 11,
                            color: NeoColors.muted,
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox.shrink(),

                  Row(
                    children: [
                      // Assignee
                      UserAvatar(
                        name: ticket.assigneeName ?? '?',
                        size: 22,
                      ),
                    ],
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
