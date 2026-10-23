import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/widgets/kbd_chip.dart';
import 'package:flutter/material.dart';

class MultiSelectActionBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onClear;
  final ValueChanged<StatusCategory>? onStatusSelect;
  final VoidCallback? onMoveToSprint;
  final VoidCallback? onDelete;

  const MultiSelectActionBar({
    super.key,
    required this.selectedCount,
    required this.onClear,
    this.onStatusSelect,
    this.onMoveToSprint,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCount == 0) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: NeoSpacing.spaceLg),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: NeoColors.primary,
          borderRadius: NeoSpacing.roundedLg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selected counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: NeoSpacing.roundedSm,
              ),
              child: Text(
                '$selectedCount sélectionné${selectedCount > 1 ? 's' : ''}',
                style: NeoTypography.labelSm.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: NeoSpacing.spaceMd),

            // Divider
            Container(
              height: 18,
              width: 1,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(width: NeoSpacing.spaceSm),

            // Change Status Menu
            PopupMenuButton<StatusCategory>(
              tooltip: 'Changer le statut',
              color: NeoColors.surfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: NeoSpacing.roundedMd,
                side: const BorderSide(color: NeoColors.borderWhisper),
              ),
              onSelected: onStatusSelect,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: StatusCategory.backlog,
                  child: Text('À faire / Backlog'),
                ),
                const PopupMenuItem(
                  value: StatusCategory.inProgress,
                  child: Text('En cours'),
                ),
                const PopupMenuItem(
                  value: StatusCategory.done,
                  child: Text('Terminé'),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cached_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Statut',
                      style: NeoTypography.labelSm.copyWith(color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    const KbdChip(label: 'S'),
                  ],
                ),
              ),
            ),

            if (onMoveToSprint != null) ...[
              const SizedBox(width: NeoSpacing.spaceSm),
              TextButton.icon(
                onPressed: onMoveToSprint,
                icon: const Icon(
                  Icons.timelapse_outlined,
                  size: 16,
                  color: Colors.white,
                ),
                label: Text(
                  'Sprint',
                  style: NeoTypography.labelSm.copyWith(color: Colors.white),
                ),
              ),
            ],

            if (onDelete != null) ...[
              const SizedBox(width: NeoSpacing.spaceSm),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 17,
                  color: Colors.white70,
                ),
                tooltip: 'Supprimer',
                onPressed: onDelete,
              ),
            ],

            const SizedBox(width: NeoSpacing.spaceSm),
            // Divider
            Container(
              height: 18,
              width: 1,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(width: NeoSpacing.spaceSm),

            // Clear selection (Esc)
            InkWell(
              onTap: onClear,
              borderRadius: NeoSpacing.roundedSm,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    const KbdChip(label: 'Esc'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
