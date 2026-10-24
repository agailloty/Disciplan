import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';
import 'workspace_tabs.dart';

/// VS Code style editor tab strip: one tab for the dashboard, one tab max per
/// open project. Rendered above the workspace area of the desktop shell.
class WorkspaceTabBar extends ConsumerWidget {
  final String currentRoute;

  const WorkspaceTabBar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ref.watch(workspaceTabsProvider);
    final selectedProjectId = ref.watch(selectedProjectIdProvider);
    final l10n = context.l10n;

    return Container(
      height: 38,
      decoration: const BoxDecoration(
        color: NeoColors.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: NeoColors.borderWhisper, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              children: [
                for (final tab in tabs)
                  _WorkspaceTabItem(
                    tab: tab,
                    isActive: isWorkspaceTabActive(
                      tab,
                      currentRoute,
                      selectedProjectId,
                    ),
                    closeTooltip: l10n.tabCloseTooltip,
                    onTap: () => navigateToTab(context, ref, tab),
                    onClose: () => _closeTab(context, ref, tab),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _closeTab(BuildContext context, WidgetRef ref, WorkspaceTab tab) {
    final selectedProjectId = ref.read(selectedProjectIdProvider);
    final wasActive =
        isWorkspaceTabActive(tab, currentRoute, selectedProjectId);
    final replacement =
        ref.read(workspaceTabsProvider.notifier).close(tab.id);
    if (!wasActive) return;

    // Closing the active tab activates its neighbour, or the welcome view
    // when no tab remains (VS Code empty editor).
    if (replacement != null) {
      navigateToTab(context, ref, replacement);
    } else {
      context.go('/welcome');
    }
  }
}

class _WorkspaceTabItem extends StatefulWidget {
  final WorkspaceTab tab;
  final bool isActive;
  final String closeTooltip;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _WorkspaceTabItem({
    required this.tab,
    required this.isActive,
    required this.closeTooltip,
    required this.onTap,
    required this.onClose,
  });

  @override
  State<_WorkspaceTabItem> createState() => _WorkspaceTabItemState();
}

class _WorkspaceTabItemState extends State<_WorkspaceTabItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDashboard = widget.tab.type == WorkspaceTabType.dashboard;
    final title = isDashboard ? l10n.dashboardTitle : widget.tab.title;
    final showClose = widget.isActive || _isHovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          width: 210,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: widget.isActive
                ? NeoColors.surface
                : (_isHovered
                    ? NeoColors.surfaceContainer
                    : Colors.transparent),
            border: Border(
              right: const BorderSide(color: NeoColors.borderWhisper, width: 1),
              top: BorderSide(
                color: widget.isActive
                    ? NeoColors.kineticAmber
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isDashboard ? Icons.home_outlined : Icons.folder_copy_outlined,
                size: 14,
                color: widget.isActive
                    ? NeoColors.primary
                    : NeoColors.subdued,
              ),
              const SizedBox(width: 6),
              if (!isDashboard && widget.tab.projectKey != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: NeoColors.kineticAmber.withValues(alpha: 0.14),
                    borderRadius: NeoSpacing.roundedSm,
                  ),
                  child: Text(
                    widget.tab.projectKey!,
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: NeoColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NeoTypography.bodySm.copyWith(
                    fontSize: 12,
                    fontWeight:
                        widget.isActive ? FontWeight.w600 : FontWeight.w500,
                    color: widget.isActive
                        ? NeoColors.onSurface
                        : NeoColors.muted,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 20,
                height: 20,
                child: showClose
                    ? Tooltip(
                        message: widget.closeTooltip,
                        child: InkWell(
                          onTap: widget.onClose,
                          borderRadius: NeoSpacing.roundedSm,
                          child: Icon(
                            Icons.close,
                            size: 13,
                            color: NeoColors.muted,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
