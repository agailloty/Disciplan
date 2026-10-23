import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ticket_providers.dart';
import 'widgets/dense_ticket_row.dart';
import 'widgets/multi_select_action_bar.dart';

class ProjectListView extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectListView({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectListView> createState() => _ProjectListViewState();
}

class _ProjectListViewState extends ConsumerState<ProjectListView> {
  final Map<StatusCategory, bool> _expandedSections = {
    StatusCategory.inProgress: true,
    StatusCategory.backlog: true,
    StatusCategory.done: false,
  };

  final Map<StatusCategory, TextEditingController> _quickControllers = {
    StatusCategory.inProgress: TextEditingController(),
    StatusCategory.backlog: TextEditingController(),
    StatusCategory.done: TextEditingController(),
  };

  @override
  void dispose() {
    for (final c in _quickControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handleQuickAdd(StatusCategory category) async {
    final controller = _quickControllers[category]!;
    final title = controller.text.trim();
    if (title.isEmpty) return;

    try {
      final repo = ref.read(ticketRepositoryProvider);
      await repo.createTicket(
        widget.projectId,
        CreateTicketRequest(
          title: title,
          type: TicketType.task,
          priority: CardPriority.medium,
        ),
      );
      controller.clear();
      ref.invalidate(projectBacklogProvider(widget.projectId));
      ref.invalidate(currentProjectDetailProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la création : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketsAsync = ref.watch(projectBacklogProvider(widget.projectId));
    final selectedIds = ref.watch(selectedTicketIdsProvider);

    return Scaffold(
      backgroundColor: NeoColors.surfaceContainerLowest,
      body: Stack(
        children: [
          ticketsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: NeoColors.primary),
            ),
            error: (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 40, color: NeoColors.error),
                  const SizedBox(height: NeoSpacing.spaceSm),
                  Text('Erreur de chargement: $err', style: NeoTypography.bodyMd),
                  const SizedBox(height: NeoSpacing.spaceMd),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(projectBacklogProvider(widget.projectId));
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
            data: (tickets) {
              if (tickets.isEmpty) {
                return _buildEmptyState();
              }

              final inProgress = tickets
                  .where((t) => t.status.category == StatusCategory.inProgress)
                  .toList();
              final backlog = tickets
                  .where((t) => t.status.category == StatusCategory.backlog)
                  .toList();
              final done = tickets
                  .where((t) => t.status.category == StatusCategory.done)
                  .toList();

              return ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: NeoSpacing.spaceLg,
                  vertical: NeoSpacing.spaceLg,
                ),
                children: [
                  _buildSection(
                    title: 'En cours',
                    icon: Icons.timelapse_outlined,
                    iconColor: NeoColors.statusAmber,
                    category: StatusCategory.inProgress,
                    tickets: inProgress,
                    selectedIds: selectedIds,
                  ),
                  const SizedBox(height: NeoSpacing.spaceLg),
                  _buildSection(
                    title: 'À faire',
                    icon: Icons.radio_button_unchecked,
                    iconColor: NeoColors.muted,
                    category: StatusCategory.backlog,
                    tickets: backlog,
                    selectedIds: selectedIds,
                  ),
                  const SizedBox(height: NeoSpacing.spaceLg),
                  _buildSection(
                    title: 'Terminé',
                    icon: Icons.check_circle_outline,
                    iconColor: NeoColors.emerald,
                    category: StatusCategory.done,
                    tickets: done,
                    selectedIds: selectedIds,
                  ),
                  const SizedBox(height: 80), // Space for floating bar
                ],
              );
            },
          ),

          // Floating batch actions bar
          MultiSelectActionBar(
            selectedCount: selectedIds.length,
            onClear: () =>
                ref.read(selectedTicketIdsProvider.notifier).clear(),
            onStatusSelect: (category) async {
              final project = ref.read(currentProjectDetailProvider).value;
              final targetStatus = project?.statuses.firstWhere(
                (s) => s.category == category,
                orElse: () => project.statuses.first,
              );
              if (targetStatus != null) {
                final repo = ref.read(ticketRepositoryProvider);
                for (final id in selectedIds) {
                  await repo.changeStatus(id, targetStatus.id);
                }
                ref.read(selectedTicketIdsProvider.notifier).clear();
                ref.invalidate(projectBacklogProvider(widget.projectId));
              }
            },
            onDelete: () async {
              final repo = ref.read(ticketRepositoryProvider);
              for (final id in selectedIds) {
                await repo.deleteTicket(id);
              }
              ref.read(selectedTicketIdsProvider.notifier).clear();
              ref.invalidate(projectBacklogProvider(widget.projectId));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.format_list_bulleted,
            size: 48,
            color: NeoColors.muted,
          ),
          const SizedBox(height: NeoSpacing.spaceMd),
          Text('Aucun ticket dans le backlog', style: NeoTypography.headlineMd),
          const SizedBox(height: NeoSpacing.spaceSm),
          Text(
            'Ajoutez votre première tâche rapide ci-dessous.',
            style: NeoTypography.bodyMd.copyWith(color: NeoColors.muted),
          ),
          const SizedBox(height: NeoSpacing.spaceLg),
          SizedBox(
            width: 400,
            child: TextField(
              controller: _quickControllers[StatusCategory.backlog],
              decoration: const InputDecoration(
                hintText: '+ Ajouter une tâche rapide... (Entrée)',
                prefixIcon: Icon(Icons.add, size: 18),
              ),
              onSubmitted: (_) => _handleQuickAdd(StatusCategory.backlog),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required StatusCategory category,
    required List<TicketDto> tickets,
    required Set<String> selectedIds,
  }) {
    final isExpanded = _expandedSections[category] ?? true;

    return Container(
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLowest,
        borderRadius: NeoSpacing.roundedLg,
        border: Border.all(color: NeoColors.borderWhisper),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Header
          InkWell(
            onTap: () {
              setState(() {
                _expandedSections[category] = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: NeoSpacing.spaceMd,
                vertical: NeoSpacing.spaceSm,
              ),
              decoration: BoxDecoration(
                color: NeoColors.surfaceContainerLow,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(NeoSpacing.radiusLg),
                  bottom: Radius.circular(isExpanded ? 0 : NeoSpacing.radiusLg),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    size: 18,
                    color: NeoColors.muted,
                  ),
                  const SizedBox(width: NeoSpacing.spaceXs),
                  Icon(icon, size: 16, color: iconColor),
                  const SizedBox(width: NeoSpacing.spaceSm),
                  Text(
                    title,
                    style: NeoTypography.labelMd.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: NeoSpacing.spaceSm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: NeoColors.surfaceContainerHigh,
                      borderRadius: NeoSpacing.roundedSm,
                    ),
                    child: Text(
                      '${tickets.length}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: NeoColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Section Content
          if (isExpanded) ...[
            if (tickets.isEmpty)
              Padding(
                padding: const EdgeInsets.all(NeoSpacing.spaceMd),
                child: Text(
                  'Aucune tâche dans cette section.',
                  style: NeoTypography.bodySm.copyWith(
                    color: NeoColors.muted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ...tickets.map(
                (ticket) => DenseTicketRow(
                  ticket: ticket,
                  isSelected: selectedIds.contains(ticket.id),
                  onSelectedChanged: (val) {
                    ref
                        .read(selectedTicketIdsProvider.notifier)
                        .toggle(ticket.id);
                  },
                  onDelete: () async {
                    await ref
                        .read(ticketRepositoryProvider)
                        .deleteTicket(ticket.id);
                    ref.invalidate(projectBacklogProvider(widget.projectId));
                  },
                ),
              ),

            // Inline Quick Add Field
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: NeoSpacing.spaceMd,
                vertical: 6,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: NeoColors.borderWhisper, width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add,
                    size: 16,
                    color: NeoColors.muted,
                  ),
                  const SizedBox(width: NeoSpacing.spaceSm),
                  Expanded(
                    child: TextField(
                      controller: _quickControllers[category],
                      style: NeoTypography.bodySm,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        hintText: 'Ajouter une tâche dans "$title"...',
                        hintStyle: NeoTypography.bodySm.copyWith(
                          color: NeoColors.muted,
                          fontStyle: FontStyle.italic,
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _handleQuickAdd(category),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: NeoColors.surfaceContainerLow,
                      borderRadius: NeoSpacing.roundedSm,
                      border: Border.all(color: NeoColors.borderWhisper),
                    ),
                    child: Text(
                      'Entrée',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        color: NeoColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
