import 'package:flutter/material.dart';

abstract final class NeoSpacing {
  // Grille 4px
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 12.0;
  static const double spaceLg = 20.0;
  static const double spaceXl = 32.0;

  // Gutter & Marges de layout
  static const double gutter = 16.0;
  static const double gutterDesktop = 20.0;
  static const double marginMobile = 16.0;
  static const double marginTablet = 24.0;
  static const double marginDesktop = 32.0;

  // Breakpoints
  static const double mobileBreakpoint = 840.0;
  static const double desktopLargeBreakpoint = 1280.0;

  // Rayons de bordure
  static const double radiusSm = 4.0;
  static const double radiusMd = 6.0;
  static const double radiusLg = 8.0;
  static const double radiusXl = 12.0;
  static const double radiusFull = 9999.0;

  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius roundedFull = BorderRadius.all(Radius.circular(radiusFull));
}
