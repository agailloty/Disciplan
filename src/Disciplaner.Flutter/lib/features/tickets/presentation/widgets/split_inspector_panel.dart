import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/core/models/sprint_models.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/core/widgets/priority_icon.dart'
    hide TicketType;
import 'package:disciplaner_flutter/core/widgets/user_avatar.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_state.dart';
import 'package:disciplaner_flutter/features/kanban/presentation/kanban_providers.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';
import 'package:disciplaner_flutter/features/sprints/presentation/sprint_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../ticket_providers.dart';

class SplitInspectorPanel extends ConsumerStatefulWidget {
  final String ticketId;
  final VoidCallback? onClose;

  const SplitInspectorPanel({
    super.key,
    required this.ticketId,
    this.onClose,
  });

  @override
  ConsumerState<SplitInspectorPanel> createState() => _SplitInspectorPanelState();
}

class _SplitInspectorPanelState extends ConsumerState<SplitInspectorPanel>
    with SingleTickerProviderStateMixin {
  static const String _unassignedSentinel = '__UNASSIGNED__';
  static const String _backlogSprintSentinel = '__BACKLOG__';

  late TabController _tabController;
  final _commentController = TextEditingController();
  final _subtaskController = TextEditingController();
  bool _isAddingComment = false;
  bool _isAddingSubtask = false;
  bool _isUpdatingTicket = false;

  TicketPriority _mapPriority(CardPriority p) {
    switch (p) {
      case CardPriority.low:
        return TicketPriority.low;
      case CardPriority.medium:
        return TicketPriority.medium;
      case CardPriority.high:
        return TicketPriority.high;
      case CardPriority.critical:
        return TicketPriority.urgent;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  void _invalidateTicketViews(TicketDto ticket, {String? previousSprintId}) {
    ref.invalidate(ticketDetailProvider(widget.ticketId));
    ref.invalidate(ticketHistoryProvider(widget.ticketId));
    ref.invalidate(projectBacklogProvider(ticket.projectId));
    if (ticket.sprintId != null) {
      ref.invalidate(sprintTicketsProvider(ticket.sprintId!));
      ref.invalidate(kanbanStateProvider(ticket.sprintId!));
      ref.invalidate(sprintMetricsProvider(ticket.sprintId!));
    }
    if (previousSprintId != null && previousSprintId != ticket.sprintId) {
      ref.invalidate(sprintTicketsProvider(previousSprintId));
      ref.invalidate(kanbanStateProvider(previousSprintId));
      ref.invalidate(sprintMetricsProvider(previousSprintId));
    }
    ref.read(myTasksProvider.notifier).refresh();
  }

  Future<void> _updateTicketFields(
    TicketDto ticket, {
    CardPriority? priority,
    String? assigneeId,
    bool updateAssignee = false,
    DateTime? dueDate,
    bool updateDueDate = false,
  }) async {
    setState(() => _isUpdatingTicket = true);
    try {
      final repo = ref.read(ticketRepositoryProvider);
      await repo.updateTicket(
        ticket.id,
        UpdateTicketRequest(
          title: ticket.title,
          description: ticket.description,
          type: ticket.type,
          priority: priority ?? ticket.priority,
          storyPoints: null,
          dueDate: updateDueDate ? dueDate : ticket.dueDate,
          assigneeId: updateAssignee ? assigneeId : ticket.assigneeId,
        ),
      );
      _invalidateTicketViews(ticket);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de mise à jour : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingTicket = false);
    }
  }

  Future<void> _changeStatus(TicketDto ticket, String statusId) async {
    setState(() => _isUpdatingTicket = true);
    try {
      await ref.read(ticketRepositoryProvider).changeStatus(ticket.id, statusId);
      _invalidateTicketViews(ticket);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur changement de statut : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingTicket = false);
    }
  }

  Future<void> _changeSprint(TicketDto ticket, String? targetSprintId) async {
    final prevSprint = ticket.sprintId;
    setState(() => _isUpdatingTicket = true);
    try {
      await ref.read(ticketRepositoryProvider).moveToSprint(ticket.id, targetSprintId);
      _invalidateTicketViews(ticket, previousSprintId: prevSprint);
      ref.invalidate(projectSprintsProvider(ticket.projectId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur changement de sprint : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingTicket = false);
    }
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isAddingComment = true);
    try {
      final repo = ref.read(ticketRepositoryProvider);
      await repo.addComment(widget.ticketId, text);
      _commentController.clear();
      ref.invalidate(ticketCommentsProvider(widget.ticketId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur ajout commentaire: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAddingComment = false);
    }
  }

  Future<void> _addSubtask(TicketDto ticket) async {
    final text = _subtaskController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isAddingSubtask = true);
    try {
      final repo = ref.read(ticketRepositoryProvider);
      await repo.createTicket(
        ticket.projectId,
        CreateTicketRequest(
          title: text,
          parentTicketId: ticket.id,
          sprintId: ticket.sprintId,
          type: TicketType.subtask,
          priority: ticket.priority,
        ),
      );
      _subtaskController.clear();
      _invalidateTicketViews(ticket);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur ajout sous-tâche: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAddingSubtask = false);
    }
  }

  Future<void> _toggleSubtaskDone(
    TicketDto parentTicket,
    TicketDto subtask,
    ProjectDetailDto? project,
  ) async {
    if (project == null || project.statuses.isEmpty) return;
    final isCurrentlyDone = subtask.status.category == StatusCategory.done;
    final targetCategory =
        isCurrentlyDone ? StatusCategory.backlog : StatusCategory.done;
    final targetStatus = project.statuses.firstWhere(
      (s) => s.category == targetCategory,
      orElse: () => project.statuses.first,
    );
    try {
      await ref
          .read(ticketRepositoryProvider)
          .changeStatus(subtask.id, targetStatus.id);
      _invalidateTicketViews(parentTicket);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur mise à jour sous-tâche: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketAsync = ref.watch(ticketDetailProvider(widget.ticketId));
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: NeoSpacing.inspectorWidth(screenWidth),
      decoration: const BoxDecoration(
        color: NeoColors.surfaceContainerLowest,
        border: Border(
          left: BorderSide(color: NeoColors.borderWhisper),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(-4, 0),
          ),
        ],
      ),
      child: ticketAsync.when(
        data: (ticket) => _buildContent(context, ticket),
        loading: () => const Center(
          child: CircularProgressIndicator(color: NeoColors.primary, strokeWidth: 2),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(NeoSpacing.spaceMd),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: NeoColors.error, size: 36),
                const SizedBox(height: NeoSpacing.spaceSm),
                Text('Impossible de charger le ticket', style: NeoTypography.headlineSm),
                const SizedBox(height: NeoSpacing.spaceXs),
                Text(err.toString(), style: NeoTypography.bodySm, textAlign: TextAlign.center),
                const SizedBox(height: NeoSpacing.spaceMd),
                ElevatedButton(
                  onPressed: () => ref.invalidate(ticketDetailProvider(widget.ticketId)),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TicketDto ticket) {
    final project = ref.watch(projectDetailByIdProvider(ticket.projectId)).value ??
        ref.watch(currentProjectDetailProvider).value;

    return Column(
      children: [
        // Header
        _buildHeader(ticket, project),
        if (_isUpdatingTicket)
          const LinearProgressIndicator(
            minHeight: 2,
            color: NeoColors.primary,
            backgroundColor: NeoColors.surfaceContainerHigh,
          )
        else
          const Divider(height: 1, color: NeoColors.surfaceContainerHigh),

        // Scrollable Body
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(NeoSpacing.spaceMd),
            children: [
              // Title
              Text(
                ticket.title,
                style: NeoTypography.headlineLg.copyWith(fontSize: 20),
              ),
              const SizedBox(height: NeoSpacing.spaceSm),

              // Description
              if (ticket.description != null && ticket.description!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(NeoSpacing.spaceSm),
                  decoration: BoxDecoration(
                    color: NeoColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ticket.description!,
                    style: NeoTypography.bodyMd.copyWith(color: NeoColors.onSurfaceVariant),
                  ),
                ),
              const SizedBox(height: NeoSpacing.spaceMd),

              // Key Properties (interactive)
              _buildPropertiesSection(ticket, project),
              const SizedBox(height: NeoSpacing.spaceMd),

              // Labels
              _buildLabelsSection(ticket),
              const SizedBox(height: NeoSpacing.spaceMd),

              // Subtasks / Livrables (real child tickets only)
              _buildSubtasksSection(ticket, project),
              const SizedBox(height: NeoSpacing.spaceMd),

              // Attachments
              _buildAttachmentsSection(ticket),
              const SizedBox(height: NeoSpacing.spaceMd),

              // Activity tabs (Comments / History)
              _buildActivityTabs(ticket),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(TicketDto ticket, ProjectDetailDto? project) {
    final statuses = project?.statuses ?? const <TicketStatusDto>[];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: NeoSpacing.spaceMd,
        vertical: NeoSpacing.spaceSm,
      ),
      color: NeoColors.surfaceContainerLowest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Ref
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: NeoColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ticket.ticketRef,
                  style: NeoTypography.labelSm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: NeoColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: NeoSpacing.spaceXs),
              // Interactive Status chip
              PopupMenuButton<String>(
                tooltip: 'Changer le statut',
                enabled: statuses.isNotEmpty,
                onSelected: (statusId) => _changeStatus(ticket, statusId),
                itemBuilder: (context) => statuses
                    .map(
                      (s) => PopupMenuItem<String>(
                        value: s.id,
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Color(
                                  int.tryParse(s.color.replaceAll('#', '0xFF')) ??
                                      0xFFE5A800,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(s.name, style: NeoTypography.bodySm),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: NeoColors.secondaryContainer.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: NeoColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ticket.status.name,
                        style: NeoTypography.labelSm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: NeoColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_drop_down, size: 14, color: NeoColors.secondary),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.share_outlined, size: 18),
                tooltip: 'Copier le lien',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: ticket.ticketRef));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Référence copiée dans le presse-papier'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                tooltip: 'Fermer',
                onPressed: widget.onClose ??
                    () => ref.read(selectedTicketDetailIdProvider.notifier).clear(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesSection(TicketDto ticket, ProjectDetailDto? project) {
    final authState = ref.watch(authNotifierProvider);
    final session = authState is AuthAuthenticated ? authState.session : null;
    final members = project?.assignableMembers(
          currentUserId: session?.userId,
          currentUserDisplayName: session?.displayName,
          currentUserEmail: session?.email,
        ) ??
        const <MemberDto>[];

    final sprints = ref
            .watch(projectSprintsProvider(ticket.projectId))
            .asData
            ?.value
            .where((s) => s.status != SprintStatus.closed)
            .toList() ??
        const <SprintDto>[];

    return Container(
      padding: const EdgeInsets.all(NeoSpacing.spaceSm),
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NeoColors.borderWhisper),
      ),
      child: Column(
        children: [
          // 1. Priorité (interactive)
          _buildPropertyRow(
            'Priorité',
            PopupMenuButton<CardPriority>(
              tooltip: 'Modifier la priorité',
              onSelected: (p) => _updateTicketFields(ticket, priority: p),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: CardPriority.low,
                  child: Row(
                    children: [
                      const PriorityIcon(priority: TicketPriority.low, size: 14),
                      const SizedBox(width: 8),
                      Text(CardPriority.low.label, style: NeoTypography.bodySm),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: CardPriority.medium,
                  child: Row(
                    children: [
                      const PriorityIcon(priority: TicketPriority.medium, size: 14),
                      const SizedBox(width: 8),
                      Text(CardPriority.medium.label, style: NeoTypography.bodySm),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: CardPriority.high,
                  child: Row(
                    children: [
                      const PriorityIcon(priority: TicketPriority.high, size: 14),
                      const SizedBox(width: 8),
                      Text(CardPriority.high.label, style: NeoTypography.bodySm),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: CardPriority.critical,
                  child: Row(
                    children: [
                      const PriorityIcon(priority: TicketPriority.urgent, size: 14),
                      const SizedBox(width: 8),
                      Text(CardPriority.critical.label, style: NeoTypography.bodySm),
                    ],
                  ),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PriorityIcon(priority: _mapPriority(ticket.priority), size: 15),
                    const SizedBox(width: 6),
                    Text(
                      ticket.priority.label,
                      style: NeoTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit_outlined, size: 13, color: NeoColors.muted),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 12, color: NeoColors.surfaceContainerHigh),

          // 2. Assigné (interactive)
          _buildPropertyRow(
            'Assigné',
            PopupMenuButton<String>(
              tooltip: 'Assigner à un membre du projet',
              onSelected: (selectedValue) {
                final newAssigneeId =
                    selectedValue == _unassignedSentinel ? null : selectedValue;
                _updateTicketFields(
                  ticket,
                  assigneeId: newAssigneeId,
                  updateAssignee: true,
                );
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: _unassignedSentinel,
                  child: Row(
                    children: [
                      const Icon(Icons.person_off_outlined, size: 16, color: NeoColors.muted),
                      const SizedBox(width: 8),
                      Text('Non assigné', style: NeoTypography.bodySm),
                    ],
                  ),
                ),
                if (members.isNotEmpty) const PopupMenuDivider(),
                ...members.map(
                  (m) => PopupMenuItem<String>(
                    value: m.userId,
                    child: Row(
                      children: [
                        UserAvatar(name: m.displayName, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            m.displayName,
                            style: NeoTypography.bodySm.copyWith(
                              fontWeight: ticket.assigneeId == m.userId
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (ticket.assigneeId == m.userId)
                          const Icon(Icons.check, size: 15, color: NeoColors.emerald),
                      ],
                    ),
                  ),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (ticket.assigneeName != null) ...[
                      UserAvatar(name: ticket.assigneeName!, size: 18),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          ticket.assigneeName!,
                          overflow: TextOverflow.ellipsis,
                          style: NeoTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ] else
                      Text(
                        'Non assigné (Cliquer)',
                        style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                      ),
                    const SizedBox(width: 4),
                    const Icon(Icons.person_add_alt_1_outlined, size: 13, color: NeoColors.muted),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 12, color: NeoColors.surfaceContainerHigh),

          // 3. Sprint / Cycle (interactive)
          _buildPropertyRow(
            'Sprint / Cycle',
            PopupMenuButton<String>(
              tooltip: 'Affecter à un sprint',
              onSelected: (val) {
                final sprintId = val == _backlogSprintSentinel ? null : val;
                _changeSprint(ticket, sprintId);
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: _backlogSprintSentinel,
                  child: Row(
                    children: [
                      const Icon(Icons.inbox_outlined, size: 16, color: NeoColors.muted),
                      const SizedBox(width: 8),
                      Text('Backlog (sans sprint)', style: NeoTypography.bodySm),
                    ],
                  ),
                ),
                if (sprints.isNotEmpty) const PopupMenuDivider(),
                ...sprints.map(
                  (s) => PopupMenuItem<String>(
                    value: s.id,
                    child: Row(
                      children: [
                        Icon(
                          s.status == SprintStatus.active
                              ? Icons.bolt_rounded
                              : Icons.timelapse_outlined,
                          size: 16,
                          color: s.status == SprintStatus.active
                              ? NeoColors.emerald
                              : NeoColors.muted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(s.name, style: NeoTypography.bodySm),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        ticket.sprintName ?? 'Backlog (sans sprint)',
                        overflow: TextOverflow.ellipsis,
                        style: NeoTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit_outlined, size: 13, color: NeoColors.muted),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 12, color: NeoColors.surfaceContainerHigh),

          // 4. Échéance (interactive)
          _buildPropertyRow(
            'Échéance',
            InkWell(
              borderRadius: NeoSpacing.roundedSm,
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: ticket.dueDate ?? now,
                  firstDate: now.subtract(const Duration(days: 365)),
                  lastDate: now.add(const Duration(days: 365 * 2)),
                );
                if (picked != null) {
                  await _updateTicketFields(
                    ticket,
                    dueDate: picked,
                    updateDueDate: true,
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ticket.dueDate != null
                          ? DateFormat('dd MMM yyyy').format(ticket.dueDate!)
                          : 'Aucune',
                      style: NeoTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.calendar_today_outlined, size: 13, color: NeoColors.muted),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyRow(String label, Widget valueWidget) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: NeoTypography.bodySm.copyWith(color: NeoColors.onSurfaceVariant),
        ),
        const SizedBox(width: NeoSpacing.spaceSm),
        Flexible(child: valueWidget),
      ],
    );
  }

  Widget _buildLabelsSection(TicketDto ticket) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LABELS',
              style: NeoTypography.labelSm.copyWith(
                fontWeight: FontWeight.w600,
                color: NeoColors.onSurfaceVariant,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (ticket.labels.isEmpty)
          Text(
            'Aucun label associé',
            style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: ticket.labels.map((label) {
              return Chip(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                backgroundColor: NeoColors.surfaceContainerHigh,
                label: Text(
                  label.name,
                  style: NeoTypography.labelSm.copyWith(fontSize: 11),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildSubtasksSection(TicketDto ticket, ProjectDetailDto? project) {
    final subtasksAsync = ref.watch(ticketSubtasksProvider(ticket));
    final subtasks = subtasksAsync.asData?.value ?? const <TicketDto>[];
    final doneCount =
        subtasks.where((t) => t.status.category == StatusCategory.done).length;
    final totalCount = subtasks.length;
    final progress = totalCount > 0 ? doneCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(NeoSpacing.spaceSm),
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NeoColors.borderWhisper),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Sous-tâches & Livrables',
                  overflow: TextOverflow.ellipsis,
                  style: NeoTypography.headlineSm.copyWith(fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: NeoColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$doneCount/$totalCount',
                  style: NeoTypography.labelSm.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (totalCount > 0) ...[
            const SizedBox(height: NeoSpacing.spaceXs),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: NeoColors.surfaceContainerHigh,
                valueColor: const AlwaysStoppedAnimation<Color>(NeoColors.primary),
              ),
            ),
            const SizedBox(height: NeoSpacing.spaceSm),
            ...subtasks.map(
              (sub) => _buildSubtaskItem(
                sub,
                sub.status.category == StatusCategory.done,
                onToggle: () => _toggleSubtaskDone(ticket, sub, project),
              ),
            ),
          ] else ...[
            const SizedBox(height: NeoSpacing.spaceXs),
            Text(
              'Aucune sous-tâche pour ce ticket.',
              style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
            ),
          ],
          const SizedBox(height: NeoSpacing.spaceXs),
          // Quick add subtask
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _subtaskController,
                  style: NeoTypography.bodySm,
                  decoration: const InputDecoration(
                    hintText: '+ Ajouter une sous-tâche...',
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                  ),
                  onSubmitted: (_) => _addSubtask(ticket),
                ),
              ),
              IconButton(
                icon: _isAddingSubtask
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_circle_outline, size: 18),
                onPressed: () => _addSubtask(ticket),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubtaskItem(
    TicketDto subtask,
    bool isDone, {
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: isDone,
              onChanged: (_) => onToggle(),
              activeColor: NeoColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              subtask.title,
              style: NeoTypography.bodySm.copyWith(
                decoration: isDone ? TextDecoration.lineThrough : null,
                color: isDone ? NeoColors.onSurfaceVariant : NeoColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection(TicketDto ticket) {
    final attachmentsAsync = ref.watch(ticketAttachmentsProvider(widget.ticketId));

    return Container(
      padding: const EdgeInsets.all(NeoSpacing.spaceSm),
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NeoColors.borderWhisper),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.attach_file, size: 16, color: NeoColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Pièces jointes',
                        overflow: TextOverflow.ellipsis,
                        style: NeoTypography.headlineSm.copyWith(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          attachmentsAsync.when(
            data: (attachments) {
              if (attachments.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: NeoSpacing.spaceXs),
                  child: Text(
                    'Aucune pièce jointe',
                    style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                  ),
                );
              }
              return Column(
                children: attachments.map((att) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const Icon(Icons.insert_drive_file_outlined, size: 20),
                    title: Text(att.fileName, style: NeoTypography.bodySm),
                    subtitle: Text('${(att.sizeBytes / 1024).round()} Ko', style: NeoTypography.labelSm),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTabs(TicketDto ticket) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          controller: _tabController,
          labelColor: NeoColors.primary,
          unselectedLabelColor: NeoColors.muted,
          indicatorColor: NeoColors.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'Commentaires'),
            Tab(text: 'Historique'),
          ],
        ),
        const SizedBox(height: NeoSpacing.spaceSm),
        SizedBox(
          height: 320,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCommentsTab(),
              _buildHistoryTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsTab() {
    final commentsAsync = ref.watch(ticketCommentsProvider(widget.ticketId));

    return Column(
      children: [
        Expanded(
          child: commentsAsync.when(
            data: (comments) {
              if (comments.isEmpty) {
                return Center(
                  child: Text(
                    'Aucun commentaire pour le moment.',
                    style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: NeoSpacing.spaceXs),
                itemCount: comments.length,
                separatorBuilder: (_, _) => const SizedBox(height: NeoSpacing.spaceSm),
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return Container(
                    padding: const EdgeInsets.all(NeoSpacing.spaceSm),
                    decoration: BoxDecoration(
                      color: NeoColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                UserAvatar(name: comment.authorName, size: 20),
                                const SizedBox(width: NeoSpacing.spaceXs),
                                Text(
                                  comment.authorName,
                                  style: NeoTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Text(
                              DateFormat('dd/MM HH:mm').format(comment.createdAt),
                              style: NeoTypography.labelSm.copyWith(color: NeoColors.muted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          comment.content,
                          style: NeoTypography.bodyMd.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (err, _) => Center(child: Text('Erreur: $err')),
          ),
        ),
        // Comment composer
        Padding(
          padding: const EdgeInsets.only(top: NeoSpacing.spaceXs),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: NeoTypography.bodySm,
                  decoration: InputDecoration(
                    hintText: 'Ajouter un commentaire...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: NeoColors.borderWhisper),
                    ),
                  ),
                  onSubmitted: (_) => _postComment(),
                ),
              ),
              const SizedBox(width: NeoSpacing.spaceXs),
              IconButton(
                icon: _isAddingComment
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send, size: 18, color: NeoColors.primary),
                onPressed: _postComment,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    final historyAsync = ref.watch(ticketHistoryProvider(widget.ticketId));

    return historyAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Text(
              'Aucune modification enregistrée.',
              style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: NeoSpacing.spaceXs),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: NeoColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: NeoSpacing.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: NeoTypography.bodySm.copyWith(color: NeoColors.primary),
                            children: [
                              TextSpan(
                                text: entry.actorName,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              TextSpan(text: ' • ${_formatHistoryKind(entry.kind)}'),
                            ],
                          ),
                        ),
                        if (entry.newValue != null)
                          Text(
                            '${entry.oldValue != null ? "${entry.oldValue} → " : ""}${entry.newValue}',
                            style: NeoTypography.labelSm.copyWith(color: NeoColors.muted),
                          ),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(entry.occurredAt),
                          style: NeoTypography.labelSm.copyWith(
                            color: NeoColors.muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (err, _) => Center(child: Text('Erreur: $err')),
    );
  }

  String _formatHistoryKind(String kind) {
    switch (kind) {
      case 'created':
        return 'a créé le ticket';
      case 'status_changed':
        return 'a changé le statut';
      case 'priority_changed':
        return 'a modifié la priorité';
      case 'assignee_changed':
        return 'a modifié l\'assignation';
      case 'sprint_changed':
        return 'a changé le sprint';
      default:
        return kind;
    }
  }
}
