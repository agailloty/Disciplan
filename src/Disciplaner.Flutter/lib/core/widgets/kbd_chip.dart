import 'package:flutter/material.dart';
import '../../app/theme/neo_colors.dart';
import '../../app/theme/neo_spacing.dart';
import '../../app/theme/neo_typography.dart';

/// Touche de raccourci clavier tactile au style Neo-Linear
class KbdChip extends StatelessWidget {
  final String label;

  const KbdChip({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLowest,
        borderRadius: NeoSpacing.roundedSm,
        border: Border.all(color: NeoColors.borderInput, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFC4BFB4),
            offset: Offset(0, 1),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        label,
        style: NeoTypography.labelSm.copyWith(
          color: NeoColors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
