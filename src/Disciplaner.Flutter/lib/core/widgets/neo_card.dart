import 'package:flutter/material.dart';
import '../../app/theme/neo_colors.dart';
import '../../app/theme/neo_spacing.dart';

class NeoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool hasOverlayShadow;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Border? customBorder;

  const NeoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(NeoSpacing.spaceMd),
    this.onTap,
    this.hasOverlayShadow = false,
    this.borderRadius,
    this.backgroundColor,
    this.customBorder,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? NeoSpacing.roundedLg;

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? NeoColors.surfaceContainerLowest,
        borderRadius: effectiveRadius,
        border: customBorder ?? Border.all(color: NeoColors.borderWhisper, width: 1),
        boxShadow: hasOverlayShadow ? NeoColors.overlayShadow : null,
      ),
      child: child,
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: effectiveRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: effectiveRadius,
        hoverColor: NeoColors.surfaceContainerLow,
        child: content,
      ),
    );
  }
}
