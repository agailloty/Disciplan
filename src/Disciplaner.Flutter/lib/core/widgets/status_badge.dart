import 'package:flutter/material.dart';
import '../../app/theme/neo_colors.dart';
import '../../app/theme/neo_spacing.dart';
import '../../app/theme/neo_typography.dart';

enum TicketStatusCategory {
  todo,
  inProgress,
  done;

  static TicketStatusCategory fromString(String? value) {
    if (value == null) return TicketStatusCategory.todo;
    final lower = value.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
    if (lower.contains('done') || lower.contains('termin') || lower.contains('clos')) {
      return TicketStatusCategory.done;
    }
    if (lower.contains('progress') || lower.contains('cours') || lower.contains('active')) {
      return TicketStatusCategory.inProgress;
    }
    return TicketStatusCategory.todo;
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final TicketStatusCategory category;
  final Color? customBackgroundColor;
  final Color? customTextColor;

  const StatusBadge({
    super.key,
    required this.label,
    this.category = TicketStatusCategory.todo,
    this.customBackgroundColor,
    this.customTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor) = _resolveColors();

    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: customBackgroundColor ?? bgColor,
        borderRadius: NeoSpacing.roundedFull,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: NeoTypography.labelSm.copyWith(
          color: customTextColor ?? textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, Color) _resolveColors() {
    return switch (category) {
      TicketStatusCategory.done => (NeoColors.statusDoneBg, NeoColors.statusDoneText),
      TicketStatusCategory.inProgress => (NeoColors.statusInProgressBg, NeoColors.statusInProgressText),
      TicketStatusCategory.todo => (NeoColors.statusTodoBg, NeoColors.statusTodoText),
    };
  }
}
