import 'package:flutter/material.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/core/shortcuts/app_shortcuts.dart';
import 'desktop_app_shell.dart';
import 'mobile_app_shell.dart';

class AdaptiveAppShell extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const AdaptiveAppShell({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return AppShortcutsWrapper(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= NeoSpacing.mobileBreakpoint;
          if (isDesktop) {
            return DesktopAppShell(
              currentRoute: currentRoute,
              child: child,
            );
          }
          return MobileAppShell(
            currentRoute: currentRoute,
            child: child,
          );
        },
      ),
    );
  }
}
