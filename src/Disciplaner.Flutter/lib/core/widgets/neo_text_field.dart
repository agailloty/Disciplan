import 'package:flutter/material.dart';
import '../../app/theme/neo_colors.dart';
import '../../app/theme/neo_spacing.dart';
import '../../app/theme/neo_typography.dart';

enum NeoTextFieldVariant {
  structured,
  inline,
}

class NeoTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? errorText;
  final bool obscureText;
  final bool autofocus;
  final bool isDense;
  final NeoTextFieldVariant variant;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final int maxLines;
  final FocusNode? focusNode;

  const NeoTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.errorText,
    this.obscureText = false,
    this.autofocus = false,
    this.isDense = false,
    this.variant = NeoTextFieldVariant.structured,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.maxLines = 1,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    if (variant == NeoTextFieldVariant.inline) {
      return TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: NeoTypography.bodyMd,
        decoration: InputDecoration(
          isDense: true,
          filled: false,
          hintText: hintText,
          hintStyle: NeoTypography.bodyMd.copyWith(color: NeoColors.subdued),
          contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: NeoColors.primary, width: 1.5),
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: NeoTypography.headlineSm.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: NeoColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: NeoSpacing.spaceXs),
        ],
        TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          style: NeoTypography.bodyMd,
          decoration: InputDecoration(
            isDense: isDense,
            filled: true,
            fillColor: NeoColors.surfaceContainerLowest,
            hintText: hintText,
            errorText: errorText,
            hintStyle: NeoTypography.bodyMd.copyWith(color: NeoColors.subdued),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: isDense ? 10 : 12,
            ),
            border: const OutlineInputBorder(
              borderRadius: NeoSpacing.roundedSm,
              borderSide: BorderSide(color: NeoColors.borderWhisper, width: 1),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: NeoSpacing.roundedSm,
              borderSide: BorderSide(color: NeoColors.borderWhisper, width: 1),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: NeoSpacing.roundedSm,
              borderSide: BorderSide(color: NeoColors.primary, width: 1.5),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: NeoSpacing.roundedSm,
              borderSide: BorderSide(color: NeoColors.error, width: 1),
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
