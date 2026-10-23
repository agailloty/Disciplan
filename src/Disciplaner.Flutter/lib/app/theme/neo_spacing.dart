import 'package:flutter/material.dart';

abstract final class NeoSpacing {
  // Grille 4px
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 12.0;
  static const double spaceLg = 20.0;
  static const double spaceXl = 32.0;
  static const double space2Xl = 48.0;

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

  /// Responsive page padding adapted to screen width
  static EdgeInsets responsivePagePadding(double width) {
    if (width < mobileBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    }
    if (width < desktopLargeBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
    }
    return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
  }

  /// Responsive split inspector width (shrinks gracefully on medium laptops)
  static double inspectorWidth(double screenWidth) {
    if (screenWidth < 1024) return 380.0;
    if (screenWidth < 1440) return 440.0;
    return 460.0;
  }
}
