import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/core/widgets/priority_icon.dart';
import 'package:disciplaner_flutter/core/widgets/status_badge.dart';
import 'package:disciplaner_flutter/core/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dense_checkbox.dart';

class DenseTicketRow extends StatefulWidget {
  final TicketDto ticket;
  final bool isSelected;
  final ValueChanged<bool>? onSelectedChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onQuickStatusChange;
  final VoidCallback? onDelete;

  const DenseTicketRow({
    super.key,
    required this.ticket,
    this.isSelected = false,
    this.onSelectedChanged,
    this.onTap,
    this.onQuickStatusChange,
    this.onDelete,
  });

  @override
  State<DenseTicketRow> createState() => _DenseTicketRowState();
}

class _DenseTicketRowState extends State<DenseTicketRow> {
  bool _isHovered = false;

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

  TicketStatusCategory _mapStatusCategory(StatusCategory c) {
    switch (c) {
      case StatusCategory.backlog:
        return TicketStatusCategory.todo;
      case StatusCategory.inProgress:
        return TicketStatusCategory.inProgress;
      case StatusCategory.done:
        return TicketStatusCategory.done;
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
    final ticket = widget.ticket;
    final isDone = ticket.status.category == StatusCategory.done;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: NeoSpacing.spaceMd),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? NeoColors.kineticAmber.withValues(alpha: 0.08)
                : (_isHovered
                    ? NeoColors.surfaceContainerLow
                    : Colors.transparent),
            border: Border(
              bottom: BorderSide(
                color: NeoColors.borderWhisper.withValues(alpha: 0.5),
                width: 1,
              ),
              left: widget.isSelected
                  ? const BorderSide(color: NeoColors.primary, width: 2)
                  : BorderSide.none,
            ),
          ),
          child: Row(
            children: [
              // 1. Checkbox
              DenseCheckbox(
                value: widget.isSelected,
                onChanged: widget.onSelectedChanged != null
                    ? (val) => widget.onSelectedChanged!(val ?? false)
                    : null,
              ),
              const SizedBox(width: NeoSpacing.spaceSm),

              // 2. Priority Icon
              PriorityIcon(priority: _mapPriority(ticket.priority), size: 16),
              const SizedBox(width: NeoSpacing.spaceSm),

              // 3. Ticket Ref (Monospace)
              Text(
                ticket.ticketRef,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDone ? NeoColors.muted : NeoColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: NeoSpacing.spaceSm),

              // 4. Ticket Title
              Expanded(
                child: Text(
                  ticket.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NeoTypography.bodyMd.copyWith(
                    color: isDone ? NeoColors.muted : NeoColors.onSurface,
                    decoration:
                        isDone ? TextDecoration.lineThrough : TextDecoration.none,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: NeoSpacing.spaceSm),

              // 5. Labels (Up to 2 pills)
              if (ticket.labels.isNotEmpty) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ticket.labels.take(2).map((label) {
                    final color = Color(
                      int.tryParse(label.color.replaceAll('#', '0xFF')) ??
                          0xFFE5A800,
                    );
                    return Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: NeoSpacing.roundedSm,
                        border: Border.all(
                          color: color.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        label.name,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(width: NeoSpacing.spaceXs),
              ],

              // 6. Story Points Chip (if any)
              if (ticket.storyPoints != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: NeoColors.surfaceContainerHigh,
                    borderRadius: NeoSpacing.roundedSm,
                  ),
                  child: Text(
                    '${ticket.storyPoints} pts',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: NeoColors.muted,
                    ),
                  ),
                ),
                const SizedBox(width: NeoSpacing.spaceSm),
              ],

              // 7. Due Date (if any)
              if (ticket.dueDate != null) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: NeoColors.muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDueDate(ticket.dueDate),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: NeoColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: NeoSpacing.spaceSm),
              ],

              // 8. Assignee Avatar
              UserAvatar(
                name: ticket.assigneeName ?? 'Non assigné',
                size: 22,
              ),
              const SizedBox(width: NeoSpacing.spaceSm),

              // 9. Status Badge
              StatusBadge(
                label: ticket.status.name,
                category: _mapStatusCategory(ticket.status.category),
              ),

              // 10. Hover Quick Actions (Desktop)
              if (_isHovered) ...[
                const SizedBox(width: NeoSpacing.spaceXs),
                if (widget.onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16),
                    color: NeoColors.muted,
                    hoverColor: NeoColors.error.withValues(alpha: 0.1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                    tooltip: 'Supprimer',
                    onPressed: widget.onDelete,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
