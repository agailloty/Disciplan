import 'package:flutter/material.dart';
import '../../app/theme/neo_colors.dart';

enum TicketPriority {
  low,
  medium,
  high,
  urgent;

  static TicketPriority fromString(String? value) {
    if (value == null) return TicketPriority.medium;
    final lower = value.toLowerCase();
    if (lower.contains('urgent') || lower == 'critical') return TicketPriority.urgent;
    if (lower.contains('high') || lower == 'haute') return TicketPriority.high;
    if (lower.contains('low') || lower == 'basse') return TicketPriority.low;
    return TicketPriority.medium;
  }
}

enum TicketType {
  story,
  bug,
  task,
  epic,
  subtask;

  static TicketType fromString(String? value) {
    if (value == null) return TicketType.task;
    final lower = value.toLowerCase();
    if (lower.contains('bug') || lower.contains('anomalie')) return TicketType.bug;
    if (lower.contains('story') || lower.contains('user')) return TicketType.story;
    if (lower.contains('epic')) return TicketType.epic;
    if (lower.contains('sub') || lower.contains('sous')) return TicketType.subtask;
    return TicketType.task;
  }
}

/// Indicateur visuel d'une priorité de ticket
class PriorityIcon extends StatelessWidget {
  final TicketPriority priority;
  final double size;

  const PriorityIcon({
    super.key,
    required this.priority,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (priority) {
      TicketPriority.low => (Icons.south, NeoColors.priorityLow),
      TicketPriority.medium => (Icons.density_medium, NeoColors.priorityMedium),
      TicketPriority.high => (Icons.north, NeoColors.priorityHigh),
      TicketPriority.urgent => (Icons.priority_high, NeoColors.priorityUrgent),
    };

    return Icon(
      icon,
      size: size,
      color: color,
    );
  }
}

/// Indicateur visuel du type de ticket
class TicketTypeIcon extends StatelessWidget {
  final TicketType type;
  final double size;

  const TicketTypeIcon({
    super.key,
    required this.type,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      TicketType.bug => (Icons.bug_report, const Color(0xFFEF4444)),
      TicketType.story => (Icons.bookmark, const Color(0xFF10B981)),
      TicketType.epic => (Icons.bolt, const Color(0xFF8B5CF6)),
      TicketType.subtask => (Icons.subdirectory_arrow_right, const Color(0xFF6B7280)),
      TicketType.task => (Icons.check_box_outlined, const Color(0xFF3B82F6)),
    };

    return Icon(
      icon,
      size: size,
      color: color,
    );
  }
}
