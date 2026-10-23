import 'package:flutter/material.dart';
import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/widgets/neo_card.dart';

class ShellPlaceholderView extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const ShellPlaceholderView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(NeoSpacing.spaceLg),
          child: NeoCard(
            hasOverlayShadow: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 28, color: NeoColors.kineticAmber),
                    const SizedBox(width: NeoSpacing.spaceSm),
                    Expanded(
                      child: Text(
                        title,
                        style: NeoTypography.headlineMd,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: NeoSpacing.spaceXs),
                Text(
                  subtitle,
                  style: NeoTypography.bodyMd.copyWith(color: NeoColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
