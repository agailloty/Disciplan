import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:disciplaner_flutter/features/projects/presentation/create_project_modal.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';
import 'package:disciplaner_flutter/features/sprints/presentation/widgets/create_sprint_modal.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/ticket_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/desktop_create_ticket_dialog.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/mobile_create_ticket_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CommandPaletteItem {
  final String category; // 'Actions rapides', 'Navigation', 'Tickets'
  final String title;
  final String? subtitle;
  final String? shortcut;
  final IconData icon;
  final VoidCallback onSelect;

  const CommandPaletteItem({
    required this.category,
    required this.title,
    this.subtitle,
    this.shortcut,
    required this.icon,
    required this.onSelect,
  });
}

class CommandPaletteModal extends ConsumerStatefulWidget {
  const CommandPaletteModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (context) => const CommandPaletteModal(),
    );
  }

  @override
  ConsumerState<CommandPaletteModal> createState() => _CommandPaletteModalState();
}

class _CommandPaletteModalState extends ConsumerState<CommandPaletteModal> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  int _selectedIndex = 0;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<CommandPaletteItem> _buildItems(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDesktop = MediaQuery.of(context).size.width >= NeoSpacing.mobileBreakpoint;
    final items = <CommandPaletteItem>[];

    // 1. Actions rapides
    items.add(
      CommandPaletteItem(
        category: l10n.cmdCategoryActions,
        title: l10n.cmdCreateTask,
        shortcut: 'C',
        icon: Icons.add_task,
        onSelect: () {
          Navigator.of(context).pop();
          if (isDesktop) {
            DesktopCreateTicketDialog.show(context);
          } else {
            MobileCreateTicketSheet.show(context);
          }
        },
      ),
    );
    items.add(
      CommandPaletteItem(
        category: l10n.cmdCategoryActions,
        title: l10n.sprintCreateTitle,
        shortcut: 'S',
        icon: Icons.timelapse,
        onSelect: () {
          Navigator.of(context).pop();
          final projId = ref.read(selectedProjectIdProvider);
          if (projId != null) {
            CreateSprintModal.show(context, projectId: projId);
          } else {
            context.go('/cycles');
          }
        },
      ),
    );
    items.add(
      CommandPaletteItem(
        category: l10n.cmdCategoryActions,
        title: l10n.projCreateNew,
        shortcut: 'P',
        icon: Icons.create_new_folder_outlined,
        onSelect: () {
          Navigator.of(context).pop();
          CreateProjectModal.show(context);
        },
      ),
    );

    // 2. Navigation
    items.add(
      CommandPaletteItem(
        category: l10n.cmdCategoryNavigation,
        title: l10n.cmdNavSprintKanban,
        shortcut: 'G K',
        icon: Icons.view_kanban_outlined,
        onSelect: () {
          Navigator.of(context).pop();
          context.go('/kanban');
        },
      ),
    );
    items.add(
      CommandPaletteItem(
        category: l10n.cmdCategoryNavigation,
        title: l10n.cmdNavCycles,
        shortcut: 'G C',
        icon: Icons.cached,
        onSelect: () {
          Navigator.of(context).pop();
          context.go('/cycles');
        },
      ),
    );
    items.add(
      CommandPaletteItem(
        category: l10n.cmdCategoryNavigation,
        title: l10n.cmdNavCalendar,
        shortcut: 'G D',
        icon: Icons.calendar_today_outlined,
        onSelect: () {
          Navigator.of(context).pop();
          context.go('/calendar');
        },
      ),
    );
    items.add(
      CommandPaletteItem(
        category: l10n.cmdCategoryNavigation,
        title: l10n.cmdNavSettings,
        shortcut: 'G S',
        icon: Icons.settings_outlined,
        onSelect: () {
          Navigator.of(context).pop();
          context.go('/settings');
        },
      ),
    );

    // 3. Tickets from MyTasks cache
    final myTasks = ref.read(myTasksProvider).asData?.value ?? [];
    for (final ticket in myTasks) {
      items.add(
        CommandPaletteItem(
          category: l10n.cmdCategoryTickets,
          title: ticket.title,
          subtitle: ticket.status.name,
          shortcut: ticket.ticketRef,
          icon: Icons.assignment_outlined,
          onSelect: () {
            Navigator.of(context).pop();
            context.go('/tickets/${ticket.ticketRef}');
          },
        ),
      );
    }

    // Filter by query
    if (_query.trim().isEmpty) {
      return items;
    }

    final lower = _query.trim().toLowerCase();
    return items.where((item) {
      final matchTitle = item.title.toLowerCase().contains(lower);
      final matchCategory = item.category.toLowerCase().contains(lower);
      final matchShortcut = (item.shortcut ?? '').toLowerCase().contains(lower);
      return matchTitle || matchCategory || matchShortcut;
    }).toList();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final items = _buildItems(context, ref);
    if (items.isEmpty) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1) % items.length;
      });
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _selectedIndex = (_selectedIndex - 1 + items.length) % items.length;
      });
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_selectedIndex >= 0 && _selectedIndex < items.length) {
        items[_selectedIndex].onSelect();
      }
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filteredItems = _buildItems(context, ref);
    if (_selectedIndex >= filteredItems.length) {
      _selectedIndex = 0;
    }

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKeyEvent,
      child: Center(
        child: Container(
          width: 640,
          margin: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 40),
          constraints: const BoxConstraints(maxHeight: 520),
          decoration: BoxDecoration(
            color: NeoColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F1A1917),
                blurRadius: 30,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Color(0x0A1A1917),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
            border: Border.all(color: NeoColors.borderWhisper),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Input Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: NeoColors.borderWhisper, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 20, color: NeoColors.muted),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        style: NeoTypography.headlineSm.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.cmdSearchHint,
                          hintStyle: NeoTypography.headlineSm.copyWith(
                            color: NeoColors.muted.withValues(alpha: 0.6),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (val) {
                          setState(() {
                            _query = val;
                            _selectedIndex = 0;
                          });
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: NeoColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        l10n.cmdEscapeKey.toUpperCase(),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: NeoColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filtered Results
              Flexible(
                child: filteredItems.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(NeoSpacing.spaceXl),
                        child: Text(
                          l10n.cmdNoResults(_query),
                          style: NeoTypography.bodyMd.copyWith(color: NeoColors.muted),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final isSelected = index == _selectedIndex;

                          final showCategoryHeader = index == 0 ||
                              filteredItems[index - 1].category != item.category;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showCategoryHeader)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    top: 10,
                                    bottom: 4,
                                  ),
                                  child: Text(
                                    item.category.toUpperCase(),
                                    style: NeoTypography.labelSm.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                      color: NeoColors.muted,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              InkWell(
                                onTap: item.onSelect,
                                onHover: (hovered) {
                                  if (hovered) {
                                    setState(() => _selectedIndex = index);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? NeoColors.surfaceContainer
                                        : Colors.transparent,
                                    border: Border(
                                      left: BorderSide(
                                        color: isSelected
                                            ? NeoColors.kineticAmber
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        item.icon,
                                        size: 18,
                                        color: isSelected
                                            ? NeoColors.primary
                                            : NeoColors.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: NeoTypography.bodyMd.copyWith(
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: NeoColors.primary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (item.shortcut != null) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? NeoColors.surfaceContainerLowest
                                                : NeoColors.surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: NeoColors.borderWhisper,
                                            ),
                                          ),
                                          child: Text(
                                            item.shortcut!,
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? NeoColors.primary
                                                  : NeoColors.muted,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),

              // Footer Bar with navigation shortcuts hints
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  color: NeoColors.surfaceContainerLow,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                  border: Border(
                    top: BorderSide(color: NeoColors.borderWhisper, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.cmdNavigate,
                          style: NeoTypography.labelSm.copyWith(color: NeoColors.muted),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '↑↓',
                          style: GoogleFonts.jetBrainsMono(fontSize: 11, color: NeoColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.cmdOpen,
                          style: NeoTypography.labelSm.copyWith(color: NeoColors.muted),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '↵',
                          style: GoogleFonts.jetBrainsMono(fontSize: 11, color: NeoColors.primary),
                        ),
                      ],
                    ),
                    Text(
                      l10n.cmdFooterBrand,
                      style: NeoTypography.labelSm.copyWith(
                        color: NeoColors.muted.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
