import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'neo_colors.dart';

abstract final class NeoTypography {
  static TextStyle get headlineXl => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 40 / 32,
        letterSpacing: -0.02 * 32,
        color: NeoColors.primary,
      );

  static TextStyle get headlineXlMobile => GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 34 / 26,
        letterSpacing: -0.015 * 26,
        color: NeoColors.primary,
      );

  static TextStyle get headlineLg => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        letterSpacing: -0.02 * 24,
        color: NeoColors.primary,
      );

  static TextStyle get headlineMd => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 26 / 18,
        letterSpacing: -0.015 * 18,
        color: NeoColors.primary,
      );

  static TextStyle get headlineSm => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 22 / 15,
        letterSpacing: -0.01 * 15,
        color: NeoColors.primary,
      );

  static TextStyle get bodyLg => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        letterSpacing: -0.005 * 16,
        color: NeoColors.primary,
      );

  static TextStyle get bodyMd => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 21 / 14,
        letterSpacing: 0,
        color: NeoColors.primary,
      );

  static TextStyle get bodySm => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 19 / 13,
        letterSpacing: 0.005 * 13,
        color: NeoColors.primary,
      );

  static TextStyle get labelMd => GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.02 * 12,
        color: NeoColors.muted,
      );

  static TextStyle get labelSm => GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 14 / 11,
        letterSpacing: 0.03 * 11,
        color: NeoColors.muted,
      );

  static TextStyle get codeInline => GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        letterSpacing: 0,
        color: NeoColors.primary,
      );
}
