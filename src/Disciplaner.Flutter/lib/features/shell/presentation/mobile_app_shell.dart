import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/shortcuts/app_shortcuts.dart';
import 'package:disciplaner_flutter/core/widgets/user_avatar.dart';
import 'package:disciplaner_flutter/features/activity/presentation/activity_drawer.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_state.dart';
import 'package:disciplaner_flutter/features/search/presentation/command_palette_modal.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/mobile_create_ticket_sheet.dart';

class MobileAppShell extends ConsumerWidget {
  final Widget child;
  final String currentRoute;

  const MobileAppShell({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<bool>(quickCreateTicketOpenProvider, (prev, current) {
      if (current) {
        ref.read(quickCreateTicketOpenProvider.notifier).set(false);
        MobileCreateTicketSheet.show(context);
      }
    });

    ref.listen<bool>(commandPaletteOpenProvider, (prev, current) {
      if (current) {
        ref.read(commandPaletteOpenProvider.notifier).set(false);
        CommandPaletteModal.show(context);
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final user = authState is AuthAuthenticated ? authState.session : null;

    return Scaffold(
      backgroundColor: NeoColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          bottom: false,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: NeoColors.surface,
              border: Border(
                bottom: BorderSide(color: NeoColors.borderWhisper, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: NeoColors.primary,
                        borderRadius: NeoSpacing.roundedSm,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'D',
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: NeoSpacing.spaceSm),
                    Text(
                      _titleForRoute(),
                      style: NeoTypography.headlineSm.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_outlined, size: 20),
                      tooltip: 'Activité récente',
                      onPressed: () {
                        ActivityDrawer.show(context);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, size: 20),
                      onPressed: () {
                        ref.read(commandPaletteOpenProvider.notifier).toggle();
                      },
                    ),
                    const SizedBox(width: 4),
                    UserAvatar(
                      name: user?.displayName ?? 'Admin',
                      size: 26,
                      isOnline: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: child,
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: NeoColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(Icons.add, size: 20),
        onPressed: () {
          MobileCreateTicketSheet.show(context);
        },
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: NeoColors.surface,
          border: Border(
            top: BorderSide(color: NeoColors.borderWhisper, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _buildNavItem(
                    context,
                    icon: Icons.folder_open,
                    label: 'Projets',
                    isSelected: currentRoute.startsWith('/projects'),
                    onTap: () => context.go('/projects'),
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    context,
                    icon: Icons.view_kanban,
                    label: 'Sprint',
                    isSelected: currentRoute.startsWith('/kanban'),
                    onTap: () => context.go('/kanban'),
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    context,
                    icon: Icons.check_circle_outline,
                    label: 'Tâches',
                    isSelected: currentRoute.startsWith('/my-tasks'),
                    onTap: () => context.go('/my-tasks'),
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    context,
                    icon: Icons.timelapse,
                    label: 'Cycles',
                    isSelected: currentRoute.startsWith('/cycles'),
                    onTap: () => context.go('/cycles'),
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    context,
                    icon: Icons.settings_outlined,
                    label: 'Paramètres',
                    isSelected: currentRoute.startsWith('/settings'),
                    onTap: () => context.go('/settings'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? NeoColors.primary : NeoColors.muted;
    return InkWell(
      onTap: onTap,
      borderRadius: NeoSpacing.roundedSm,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: NeoTypography.labelSm.copyWith(
                fontSize: 10,
                color: color,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _titleForRoute() {
    if (currentRoute.startsWith('/projects')) return 'Projets';
    if (currentRoute.startsWith('/kanban')) return 'Sprint';
    if (currentRoute.startsWith('/my-tasks')) return 'Mes Tâches';
    if (currentRoute.startsWith('/cycles')) return 'Cycles';
    if (currentRoute.startsWith('/calendar')) return 'Calendrier';
    if (currentRoute.startsWith('/settings')) return 'Paramètres';
    return 'Disciplan';
  }
}
