import 'package:flutter/material.dart';

/// Palette de couleurs Neo-Linear issue de DESIGN.md et de l'architecture.
abstract final class NeoColors {
  // Surfaces et fonds
  static const Color surface = Color(0xFFFBF9F4);
  static const Color background = Color(0xFFFBF9F4);
  static const Color surfaceDim = Color(0xFFDBDAD5);
  static const Color surfaceBright = Color(0xFFFBF9F4);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F3EE);
  static const Color surfaceContainer = Color(0xFFF0EEE9);
  static const Color surfaceContainerHigh = Color(0xFFEAE8E3);
  static const Color surfaceContainerHighest = Color(0xFFE4E2DD);
  static const Color surfaceVariant = Color(0xFFE4E2DD);

  // Inks primaires et neutres
  static const Color primary = Color(0xFF1A1917);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1C1B19);
  static const Color onPrimaryContainer = Color(0xFF868380);
  static const Color onSurface = Color(0xFF1B1C19);
  static const Color onSurfaceVariant = Color(0xFF494740);
  static const Color muted = Color(0xFF6E6B65);
  static const Color subdued = Color(0xFFA39F96);

  // Bordures
  static const Color outline = Color(0xFF7A776F);
  static const Color outlineVariant = Color(0xFFCBC6BD);
  static const Color borderSubtle = Color(0xFFCBC6BD);
  static const Color borderWhisper = Color(0xFFE4E0D7);
  static const Color borderInput = Color(0xFFD8D4CA);

  // Accents et sémantique
  static const Color secondary = Color(0xFF7B5900);
  static const Color secondaryContainer = Color(0xFFFFBF28);
  static const Color kineticAmber = Color(0xFFE5A800);
  static const Color emerald = Color(0xFF10B981);
  static const Color statusAmber = Color(0xFFF59E0B);
  static const Color warning = Color(0xFFF59E0B);
  static const Color statusBlue = Color(0xFF3B82F6);
  static const Color statusSlate = Color(0xFF9CA3AF);
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color sidebarDark = Color(0xFF181715);
  static const Color sidebarDarkBorder = Color(0xFF2B2824);

  // Status badge tints
  static const Color statusDoneBg = Color(0x1A10B981); // 10% emerald
  static const Color statusDoneText = Color(0xFF0D9488);

  static const Color statusInProgressBg = Color(0x1FF59E0B); // 12% amber
  static const Color statusInProgressText = Color(0xFFB45309);

  static const Color statusTodoBg = Color(0x269CA3AF); // 15% slate
  static const Color statusTodoText = Color(0xFF4B5563);

  // Priorités
  static const Color priorityLow = Color(0xFF9CA3AF);
  static const Color priorityMedium = Color(0xFF3B82F6);
  static const Color priorityHigh = Color(0xFFF59E0B);
  static const Color priorityUrgent = Color(0xFFEF4444);

  // Micro-ombres douces pour overlays
  static const List<BoxShadow> overlayShadow = [
    BoxShadow(
      color: Color(0x0F1A1917),
      blurRadius: 30,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0A1A1917),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];
}
