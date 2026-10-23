import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ticket_providers.dart';
import 'widgets/dense_ticket_row.dart';
import 'widgets/mobile_ticket_detail_sheet.dart';
import 'widgets/multi_select_action_bar.dart';
import 'widgets/save_view_modal.dart';
import 'widgets/split_inspector_panel.dart';

class MyTasksView extends ConsumerStatefulWidget {
  const MyTasksView({super.key});

  @override
  ConsumerState<MyTasksView> createState() => _MyTasksViewState();
}

class _MyTasksViewState extends ConsumerState<MyTasksView> {
  String _activeTab = 'all'; // 'all', 'inProgress', 'backlog', 'urgent', 'done'

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(myTasksProvider);
    final selectedIds = ref.watch(selectedTicketIdsProvider);
    final savedViewsAsync = ref.watch(savedViewsListProvider);
    final selectedDetailId = ref.watch(selectedTicketDetailIdProvider);
    final isDesktop = MediaQuery.of(context).size.width >= NeoSpacing.mobileBreakpoint;

    final mainStack = Stack(
        children: [
          tasksAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: NeoColors.primary),
            ),
            error: (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 40, color: NeoColors.error),
                  const SizedBox(height: NeoSpacing.spaceSm),
                  Text('Erreur de chargement: $err', style: NeoTypography.bodyMd),
                  const SizedBox(height: NeoSpacing.spaceMd),
                  ElevatedButton(
                    onPressed: () => ref.read(myTasksProvider.notifier).refresh(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
            data: (allTasks) {
              final inProgressCount = allTasks
                  .where((t) => t.status.category == StatusCategory.inProgress)
                  .length;
              final urgentCount = allTasks
                  .where((t) =>
                      t.priority == CardPriority.critical ||
                      t.priority == CardPriority.high)
                  .length;
              final doneCount = allTasks
                  .where((t) => t.status.category == StatusCategory.done)
                  .length;

              // Apply active tab filter
              final filteredTasks = allTasks.where((t) {
                switch (_activeTab) {
                  case 'inProgress':
                    return t.status.category == StatusCategory.inProgress;
                  case 'backlog':
                    return t.status.category == StatusCategory.backlog;
                  case 'urgent':
                    return t.priority == CardPriority.critical ||
                        t.priority == CardPriority.high;
                  case 'done':
                    return t.status.category == StatusCategory.done;
                  case 'all':
                  default:
                    return true;
                }
              }).toList();

              return RefreshIndicator(
                color: NeoColors.primary,
                onRefresh: () => ref.read(myTasksProvider.notifier).refresh(),
                child: ListView(
                  padding: const EdgeInsets.all(NeoSpacing.spaceLg),
                  children: [
                    // 1. Header with Breadcrumb & Title
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: NeoColors.kineticAmber.withValues(alpha: 0.15),
                                      borderRadius: NeoSpacing.roundedSm,
                                    ),
                                    child: Text(
                                      'ESPACE PERSONNEL',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: NeoColors.secondary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: NeoSpacing.spaceSm),
                                  Text('•', style: NeoTypography.bodySm.copyWith(color: NeoColors.muted)),
                                  const SizedBox(width: NeoSpacing.spaceSm),
                                  Text(
                                    'Cycle actif',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 11,
                                      color: NeoColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: NeoSpacing.spaceXs),
                              Text('Mes Tâches', style: NeoTypography.headlineLg),
                              const SizedBox(height: 2),
                              Text(
                                '$inProgressCount tâche(s) en cours requièrent votre attention.',
                                style: NeoTypography.bodyMd.copyWith(color: NeoColors.muted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: NeoSpacing.spaceSm),

                        // Action button: Save current view
                        OutlinedButton.icon(
                          onPressed: () {
                            SaveViewModal.show(
                              context,
                              initialCategory: _activeTab == 'inProgress'
                                  ? StatusCategory.inProgress
                                  : (_activeTab == 'backlog'
                                      ? StatusCategory.backlog
                                      : null),
                              initialPriority: _activeTab == 'urgent'
                                  ? CardPriority.critical
                                  : null,
                            );
                          },
                          icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                          label: const Text('Sauvegarder la vue'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: NeoColors.onSurface,
                            side: const BorderSide(color: NeoColors.borderWhisper),
                            shape: RoundedRectangleBorder(
                              borderRadius: NeoSpacing.roundedMd,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: NeoSpacing.spaceLg),

                    // 2. Metric Counters Cards
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                title: 'En cours',
                                count: inProgressCount,
                                color: NeoColors.statusAmber,
                                icon: Icons.timelapse,
                              ),
                            ),
                            const SizedBox(width: NeoSpacing.spaceSm),
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Urgentes',
                                count: urgentCount,
                                color: NeoColors.error,
                                icon: Icons.crisis_alert,
                              ),
                            ),
                            const SizedBox(width: NeoSpacing.spaceSm),
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Terminées',
                                count: doneCount,
                                color: NeoColors.emerald,
                                icon: Icons.check_circle_outline,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: NeoSpacing.spaceLg),

                    // 3. Filter tabs & Saved Views Rail
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterPill('Toutes (${allTasks.length})', 'all'),
                                const SizedBox(width: NeoSpacing.spaceXs),
                                _buildFilterPill('En cours ($inProgressCount)', 'inProgress'),
                                const SizedBox(width: NeoSpacing.spaceXs),
                                _buildFilterPill('À faire', 'backlog'),
                                const SizedBox(width: NeoSpacing.spaceXs),
                                _buildFilterPill('Urgentes ($urgentCount)', 'urgent'),
                                const SizedBox(width: NeoSpacing.spaceXs),
                                _buildFilterPill('Terminées ($doneCount)', 'done'),
                              ],
                            ),
                          ),
                        ),

                        // Saved views chips if any
                        savedViewsAsync.when(
                          data: (views) {
                            if (views.isEmpty) return const SizedBox.shrink();
                            return PopupMenuButton<String>(
                              tooltip: 'Vues enregistrées',
                              icon: const Icon(Icons.bookmarks_outlined, size: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: NeoSpacing.roundedMd,
                                side: const BorderSide(color: NeoColors.borderWhisper),
                              ),
                              onSelected: (viewId) {
                                ref.read(selectedSavedViewIdProvider.notifier).setViewId(viewId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Vue sauvegardée activée.')),
                                );
                              },
                              itemBuilder: (context) => views.map((v) {
                                return PopupMenuItem(
                                  value: v.id,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.bookmark_outline, size: 16),
                                      const SizedBox(width: 8),
                                      Text(v.name),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (error, stack) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    const SizedBox(height: NeoSpacing.spaceMd),

                    // 4. Task List Container
                    Container(
                      decoration: BoxDecoration(
                        color: NeoColors.surfaceContainerLowest,
                        borderRadius: NeoSpacing.roundedLg,
                        border: Border.all(color: NeoColors.borderWhisper),
                      ),
                      child: filteredTasks.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(NeoSpacing.spaceXl),
                              child: Center(
                                child: Text(
                                  'Aucune tâche ne correspond à ce filtre.',
                                  style: NeoTypography.bodyMd.copyWith(
                                    color: NeoColors.muted,
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: filteredTasks.map((ticket) {
                                return DenseTicketRow(
                                  ticket: ticket,
                                  isSelected: selectedIds.contains(ticket.id),
                                  onTap: () {
                                    if (isDesktop) {
                                      ref
                                          .read(selectedTicketDetailIdProvider.notifier)
                                          .select(ticket.id);
                                    } else {
                                      MobileTicketDetailSheet.show(context, ticket.id);
                                    }
                                  },
                                  onSelectedChanged: (val) {
                                    ref
                                        .read(selectedTicketIdsProvider.notifier)
                                        .toggle(ticket.id);
                                  },
                                  onDelete: () async {
                                    await ref
                                        .read(ticketRepositoryProvider)
                                        .deleteTicket(ticket.id);
                                    ref.read(myTasksProvider.notifier).refresh();
                                  },
                                );
                              }).toList(),
                            ),
                    ),
                    const SizedBox(height: 80), // Padding for batch actions bar
                  ],
                ),
              );
            },
          ),

          // 5. Floating MultiSelect Action Bar
          MultiSelectActionBar(
            selectedCount: selectedIds.length,
            onClear: () =>
                ref.read(selectedTicketIdsProvider.notifier).clear(),
            onStatusSelect: (category) async {
              final tasks = ref.read(myTasksProvider).value ?? [];
              final selected = tasks.where((t) => selectedIds.contains(t.id));
              for (final t in selected) {
                await ref
                    .read(ticketRepositoryProvider)
                    .changeStatus(t.id, t.status.id);
              }
              ref.read(selectedTicketIdsProvider.notifier).clear();
              ref.read(myTasksProvider.notifier).refresh();
            },
            onDelete: () async {
              await ref
                  .read(myTasksProvider.notifier)
                  .batchDelete(selectedIds);
            },
          ),
        ],
      );

    return Scaffold(
      backgroundColor: NeoColors.surfaceContainerLowest,
      body: Row(
        children: [
          Expanded(child: mainStack),
          if (selectedDetailId != null && isDesktop)
            SplitInspectorPanel(
              ticketId: selectedDetailId,
              onClose: () =>
                  ref.read(selectedTicketDetailIdProvider.notifier).clear(),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: NeoSpacing.spaceMd,
        vertical: NeoSpacing.spaceSm,
      ),
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLow,
        borderRadius: NeoSpacing.roundedMd,
        border: Border.all(color: NeoColors.borderWhisper),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: NeoSpacing.roundedSm,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: NeoSpacing.spaceSm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: NeoTypography.labelSm.copyWith(color: NeoColors.muted),
              ),
              Text(
                '$count',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: NeoColors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String label, String tabKey) {
    final isActive = _activeTab == tabKey;
    return InkWell(
      onTap: () => setState(() => _activeTab = tabKey),
      borderRadius: NeoSpacing.roundedMd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? NeoColors.primary
              : NeoColors.surfaceContainerLow,
          borderRadius: NeoSpacing.roundedMd,
          border: Border.all(
            color: isActive ? NeoColors.primary : NeoColors.borderWhisper,
          ),
        ),
        child: Text(
          label,
          style: NeoTypography.labelSm.copyWith(
            color: isActive ? Colors.white : NeoColors.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
