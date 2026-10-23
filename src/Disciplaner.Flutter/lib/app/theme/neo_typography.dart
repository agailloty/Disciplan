import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'neo_colors.dart';

abstract final class NeoTypography {
  static TextStyle get headlineXl => GoogleFonts.inter(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 38 / 30,
        letterSpacing: -0.025 * 30,
        color: NeoColors.primary,
      );

  static TextStyle get headlineXlMobile => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
        letterSpacing: -0.02 * 24,
        color: NeoColors.primary,
      );

  static TextStyle get headlineLg => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 30 / 22,
        letterSpacing: -0.02 * 22,
        color: NeoColors.primary,
      );

  static TextStyle get headlineMd => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 24 / 17,
        letterSpacing: -0.015 * 17,
        color: NeoColors.primary,
      );

  static TextStyle get headlineSm => GoogleFonts.inter(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        height: 20 / 14.5,
        letterSpacing: -0.01 * 14.5,
        color: NeoColors.primary,
      );

  static TextStyle get titleMd => headlineSm;

  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 15.5,
        fontWeight: FontWeight.w400,
        height: 24 / 15.5,
        letterSpacing: -0.005 * 15.5,
        color: NeoColors.primary,
      );

  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        letterSpacing: -0.005 * 14,
        color: NeoColors.primary,
      );

  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 18 / 13,
        letterSpacing: 0,
        color: NeoColors.primary,
      );

  static TextStyle get labelMd => GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        height: 18 / 12.5,
        letterSpacing: 0,
        color: NeoColors.onSurfaceVariant,
      );

  static TextStyle get labelSm => GoogleFonts.inter(
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        height: 16 / 11.5,
        letterSpacing: 0.01 * 11.5,
        color: NeoColors.muted,
      );

  static TextStyle get codeInline => GoogleFonts.ibmPlexMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0,
        color: NeoColors.primary,
      );

  static TextStyle get codeSm => GoogleFonts.ibmPlexMono(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 15 / 11,
        letterSpacing: 0,
        color: NeoColors.muted,
      );
}
