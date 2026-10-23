import 'package:flutter/material.dart';
import '../../app/theme/neo_colors.dart';
import '../../app/theme/neo_spacing.dart';
import '../../app/theme/neo_typography.dart';

enum NeoButtonVariant {
  primary,
  secondary,
  ghost,
  destructive,
  kinetic,
}

class NeoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final NeoButtonVariant variant;
  final Widget? icon;
  final bool isLoading;
  final bool isDense;

  const NeoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = NeoButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    final (bgColor, fgColor, borderColor) = _colors();
    final verticalPadding = isDense ? 6.0 : 9.0;
    final horizontalPadding = isDense ? 10.0 : 14.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: NeoSpacing.roundedSm,
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: onPressed == null ? NeoColors.surfaceContainerHigh : bgColor,
            borderRadius: NeoSpacing.roundedSm,
            border: borderColor != null
                ? Border.all(color: borderColor, width: 1)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) ...[
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                  ),
                ),
                const SizedBox(width: NeoSpacing.spaceSm),
              ] else if (icon != null) ...[
                IconTheme(
                  data: IconThemeData(size: 15, color: fgColor),
                  child: icon!,
                ),
                const SizedBox(width: NeoSpacing.spaceSm),
              ],
              Text(
                label,
                style: NeoTypography.headlineSm.copyWith(
                  fontSize: isDense ? 12 : 13,
                  fontWeight: FontWeight.w600,
                  color: onPressed == null ? NeoColors.subdued : fgColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (Color, Color, Color?) _colors() {
    return switch (variant) {
      NeoButtonVariant.primary => (
          NeoColors.primary,
          NeoColors.onPrimary,
          null,
        ),
      NeoButtonVariant.secondary => (
          NeoColors.surfaceContainerLowest,
          NeoColors.primary,
          NeoColors.borderWhisper,
        ),
      NeoButtonVariant.ghost => (
          Colors.transparent,
          NeoColors.primary,
          null,
        ),
      NeoButtonVariant.destructive => (
          NeoColors.error,
          Colors.white,
          null,
        ),
      NeoButtonVariant.kinetic => (
          NeoColors.kineticAmber,
          NeoColors.primary,
          null,
        ),
    };
  }
}
