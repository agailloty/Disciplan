import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/l10n/enum_l10n.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/core/models/sprint_models.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/core/utils/ticket_share_links.dart';
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

class MobileTicketDetailSheet extends ConsumerStatefulWidget {
  final String ticketId;

  const MobileTicketDetailSheet({
    super.key,
    required this.ticketId,
  });

  static Future<void> show(BuildContext context, String ticketId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MobileTicketDetailSheet(ticketId: ticketId),
    );
  }

  @override
  ConsumerState<MobileTicketDetailSheet> createState() =>
      _MobileTicketDetailSheetState();
}

class _MobileTicketDetailSheetState
    extends ConsumerState<MobileTicketDetailSheet> {
  static const String _unassignedSentinel = '__UNASSIGNED__';
  static const String _backlogSprintSentinel = '__BACKLOG__';

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
  void dispose() {
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
          SnackBar(content: Text(context.l10n.ticketsUpdateFailed(e.toString()))),
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
          SnackBar(content: Text(context.l10n.ticketsStatusChangeFailed(e.toString()))),
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
          SnackBar(content: Text(context.l10n.ticketsSprintChangeFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingTicket = false);
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
          SnackBar(content: Text(context.l10n.ticketsSubtaskAddFailed(e.toString()))),
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
          SnackBar(content: Text(context.l10n.ticketsSubtaskUpdateFailed(e.toString()))),
        );
      }
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(context.l10n.ticketsCommentPosted),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.ticketsErrorDetail(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isAddingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ticketAsync = ref.watch(ticketDetailProvider(widget.ticketId));

    return Container(
      height: MediaQuery.of(context).size.height * 0.94,
      decoration: const BoxDecoration(
        color: NeoColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: NeoColors.borderWhisper,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: NeoSpacing.spaceMd,
              vertical: NeoSpacing.spaceXs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  l10n.ticketsTicketDetailTitle,
                  style: NeoTypography.headlineSm.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          if (_isUpdatingTicket)
            const LinearProgressIndicator(
              minHeight: 2,
              color: NeoColors.primary,
              backgroundColor: NeoColors.surfaceContainerHigh,
            ),

          Expanded(
            child: ticketAsync.when(
              data: (ticket) => _buildDetail(context, ticket),
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
                      Text(l10n.ticketsTicketLoadError, style: NeoTypography.headlineSm),
                      const SizedBox(height: NeoSpacing.spaceXs),
                      Text(err.toString(), style: NeoTypography.bodySm, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Quick floating comment composer
          _buildCommentComposer(),
        ],
      ),
    );
  }

  Widget _buildDetail(BuildContext context, TicketDto ticket) {
    final l10n = context.l10n;
    final project = ref.watch(projectDetailByIdProvider(ticket.projectId)).value ??
        ref.watch(currentProjectDetailProvider).value;
    final statuses = project?.statuses ?? const <TicketStatusDto>[];

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

    final subtasksAsync = ref.watch(ticketSubtasksProvider(ticket));
    final subtasks = subtasksAsync.asData?.value ?? const <TicketDto>[];
    final doneCount =
        subtasks.where((t) => t.status.category == StatusCategory.done).length;
    final totalCount = subtasks.length;
    final progress = totalCount > 0 ? doneCount / totalCount : 0.0;

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: NeoSpacing.spaceMd,
        vertical: NeoSpacing.spaceXs,
      ),
      children: [
        // Top Meta / Status Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Wrap(
                spacing: NeoSpacing.spaceXs,
                runSpacing: NeoSpacing.spaceXs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Interactive Status Pill
                  PopupMenuButton<String>(
                    enabled: statuses.isNotEmpty,
                    onSelected: (sId) => _changeStatus(ticket, sId),
                    itemBuilder: (context) => statuses
                        .map(
                          (s) => PopupMenuItem<String>(
                            value: s.id,
                            child: Text(s.name),
                          ),
                        )
                        .toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: NeoColors.secondaryContainer.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: NeoColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            ticket.status.name,
                            style: NeoTypography.headlineSm.copyWith(
                              fontSize: 13,
                              color: NeoColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.arrow_drop_down, size: 15, color: NeoColors.secondary),
                        ],
                      ),
                    ),
                  ),
                  // Interactive Priority Chip
                  PopupMenuButton<CardPriority>(
                    onSelected: (p) => _updateTicketFields(ticket, priority: p),
                    itemBuilder: (context) => [
                      PopupMenuItem(value: CardPriority.low, child: Text(CardPriority.low.localizedLabel(l10n))),
                      PopupMenuItem(value: CardPriority.medium, child: Text(CardPriority.medium.localizedLabel(l10n))),
                      PopupMenuItem(value: CardPriority.high, child: Text(CardPriority.high.localizedLabel(l10n))),
                      PopupMenuItem(value: CardPriority.critical, child: Text(CardPriority.critical.localizedLabel(l10n))),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: NeoColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PriorityIcon(priority: _mapPriority(ticket.priority), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            ticket.priority.localizedLabel(l10n).toUpperCase(),
                            style: NeoTypography.labelSm.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.arrow_drop_down, size: 14, color: NeoColors.muted),
                        ],
                      ),
                    ),
                  ),
                  // Ticket ID
                  Text(
                    ticket.ticketRef,
                    style: NeoTypography.labelSm.copyWith(
                      color: NeoColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share, size: 18),
              onPressed: () {
                final baseUrl =
                    ref.read(serverConfigStorageProvider).getBaseUrl();
                Clipboard.setData(
                  ClipboardData(
                    text: buildTicketShareUrl(baseUrl, ticket.ticketRef),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(l10n.ticketsTicketLinkCopied),
                    duration: const Duration(milliseconds: 1500),
                  ),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: NeoSpacing.spaceSm),

        // Main Title
        Text(
          ticket.title,
          style: NeoTypography.headlineLg.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),

        const SizedBox(height: NeoSpacing.spaceMd),

        // Key Properties 2x2 Grid (interactive)
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.2,
          crossAxisSpacing: NeoSpacing.spaceXs,
          mainAxisSpacing: NeoSpacing.spaceXs,
          children: [
            // Assignee (interactive PopupMenuButton)
            PopupMenuButton<String>(
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
                      Text(l10n.ticketNoAssignee, style: NeoTypography.bodySm),
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
                            style: NeoTypography.bodySm,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              child: _buildPropCard(
                avatar: ticket.assigneeName != null
                    ? UserAvatar(name: ticket.assigneeName!, size: 30)
                    : const CircleAvatar(
                        radius: 15,
                        backgroundColor: NeoColors.surfaceContainerHigh,
                        child: Icon(Icons.person_add_alt_1_outlined, size: 16, color: NeoColors.muted),
                      ),
                label: l10n.ticketsAssignedLabel,
                value: ticket.assigneeName ?? l10n.ticketNoAssignee,
              ),
            ),

            // Deadline (interactive)
            InkWell(
              borderRadius: BorderRadius.circular(12),
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
              child: _buildPropCard(
                avatar: const CircleAvatar(
                  radius: 15,
                  backgroundColor: NeoColors.secondaryContainer,
                  child: Icon(Icons.schedule, size: 16, color: NeoColors.secondary),
                ),
                label: l10n.ticketDueDate.toUpperCase(),
                value: ticket.dueDate != null
                    ? DateFormat('dd MMM yyyy').format(ticket.dueDate!)
                    : l10n.ticketsNotSet,
              ),
            ),

            // Project
            _buildPropCard(
              avatar: const CircleAvatar(
                radius: 15,
                backgroundColor: NeoColors.surfaceContainerHigh,
                child: Icon(Icons.campaign, size: 16, color: NeoColors.primary),
              ),
              label: l10n.colProject.toUpperCase(),
              value: ticket.projectKey,
            ),

            // Sprint (interactive)
            PopupMenuButton<String>(
              onSelected: (val) {
                final sId = val == _backlogSprintSentinel ? null : val;
                _changeSprint(ticket, sId);
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: _backlogSprintSentinel,
                  child: Text(l10n.ticketsBacklogNoSprint),
                ),
                ...sprints.map(
                  (s) => PopupMenuItem<String>(
                    value: s.id,
                    child: Text(s.name),
                  ),
                ),
              ],
              child: _buildPropCard(
                avatar: const CircleAvatar(
                  radius: 15,
                  backgroundColor: NeoColors.surfaceContainerHigh,
                  child: Icon(Icons.autorenew, size: 16, color: NeoColors.primary),
                ),
                label: l10n.ticketsCycleSprint,
                value: ticket.sprintName ?? l10n.projectBacklog,
              ),
            ),
          ],
        ),

        const SizedBox(height: NeoSpacing.spaceMd),

        // Note d'intention / Description
        if (ticket.description != null && ticket.description!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(NeoSpacing.spaceMd),
            decoration: BoxDecoration(
              color: NeoColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NeoColors.borderWhisper),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notes, size: 16, color: NeoColors.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      l10n.description.toUpperCase(),
                      style: NeoTypography.labelSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: NeoColors.onSurfaceVariant,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  ticket.description!,
                  style: NeoTypography.bodyMd.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: NeoSpacing.spaceMd),
        ],

        // Interactive Deliverables Checklist (Real Sous-tâches only)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      l10n.ticketsSubtasks,
                      style: NeoTypography.headlineSm.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: NeoColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$doneCount/$totalCount',
                      style: NeoTypography.labelSm.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            if (totalCount > 0)
              Text(
                l10n.ticketsPercentDone((progress * 100).round()),
                style: NeoTypography.labelSm.copyWith(color: NeoColors.onSurfaceVariant),
              ),
          ],
        ),
        const SizedBox(height: 6),
        if (totalCount > 0) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: NeoColors.surfaceContainerHigh,
              valueColor: const AlwaysStoppedAnimation<Color>(NeoColors.primary),
            ),
          ),
          const SizedBox(height: NeoSpacing.spaceSm),
          ...subtasks.map((sub) {
            final isDone = sub.status.category == StatusCategory.done;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: () => _toggleSubtaskDone(ticket, sub, project),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: NeoSpacing.spaceSm,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: NeoColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: NeoColors.borderWhisper),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isDone ? NeoColors.primary : NeoColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: isDone
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: NeoSpacing.spaceSm),
                      Expanded(
                        child: Text(
                          sub.title,
                          style: NeoTypography.bodyMd.copyWith(
                            decoration: isDone ? TextDecoration.lineThrough : null,
                            color: isDone ? NeoColors.onSurfaceVariant : NeoColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ] else
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              l10n.ticketsNoSubtask,
              style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
            ),
          ),

        // Quick subtask input
        Container(
          padding: const EdgeInsets.symmetric(horizontal: NeoSpacing.spaceSm, vertical: 2),
          decoration: BoxDecoration(
            color: NeoColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NeoColors.borderWhisper),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _subtaskController,
                  style: NeoTypography.bodySm,
                  decoration: InputDecoration(
                    hintText: l10n.ticketsAddSubtaskHint,
                    isDense: true,
                    border: InputBorder.none,
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
        ),

        const SizedBox(height: NeoSpacing.spaceMd),

        // Real Attachments
        _buildAttachmentsSection(),

        const SizedBox(height: NeoSpacing.spaceMd),

        // Recent activity / comments
        _buildCommentsThread(),

        const SizedBox(height: NeoSpacing.spaceXl),
      ],
    );
  }

  Widget _buildPropCard({
    required Widget avatar,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(NeoSpacing.spaceSm),
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          avatar,
          const SizedBox(width: NeoSpacing.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: NeoTypography.labelSm.copyWith(
                    color: NeoColors.onSurfaceVariant,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value,
                  style: NeoTypography.headlineSm.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    final l10n = context.l10n;
    final attachmentsAsync = ref.watch(ticketAttachmentsProvider(widget.ticketId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.attachmentSectionLabel,
          style: NeoTypography.headlineSm.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        attachmentsAsync.when(
          data: (attachments) {
            if (attachments.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(NeoSpacing.spaceMd),
                decoration: BoxDecoration(
                  color: NeoColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.ticketsNoAttachment,
                  style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                ),
              );
            }
            return Column(
              children: attachments.map((att) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(NeoSpacing.spaceSm),
                  decoration: BoxDecoration(
                    color: NeoColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: NeoColors.borderWhisper),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.insert_drive_file_outlined, color: NeoColors.primary, size: 20),
                      const SizedBox(width: NeoSpacing.spaceSm),
                      Expanded(
                        child: Text(
                          att.fileName,
                          style: NeoTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${(att.sizeBytes / 1024).round()} Ko',
                        style: NeoTypography.labelSm.copyWith(color: NeoColors.muted),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildCommentsThread() {
    final l10n = context.l10n;
    final commentsAsync = ref.watch(ticketCommentsProvider(widget.ticketId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.ticketsRecentExchanges,
          style: NeoTypography.headlineSm.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: NeoSpacing.spaceSm),
        commentsAsync.when(
          data: (comments) {
            if (comments.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(NeoSpacing.spaceMd),
                decoration: BoxDecoration(
                  color: NeoColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.ticketsNoExchange,
                  style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                ),
              );
            }
            return Column(
              children: comments.map((comment) {
                return Container(
                  margin: const EdgeInsets.only(bottom: NeoSpacing.spaceSm),
                  padding: const EdgeInsets.all(NeoSpacing.spaceSm),
                  decoration: BoxDecoration(
                    color: NeoColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UserAvatar(name: comment.authorName, size: 28),
                      const SizedBox(width: NeoSpacing.spaceSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  comment.authorName,
                                  style: NeoTypography.headlineSm.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  DateFormat('HH:mm').format(comment.createdAt),
                                  style: NeoTypography.labelSm.copyWith(
                                    color: NeoColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              comment.content,
                              style: NeoTypography.bodySm.copyWith(
                                color: NeoColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (err, _) => Text(l10n.ticketsErrorDetail(err.toString()), style: NeoTypography.bodySm),
        ),
      ],
    );
  }

  Widget _buildCommentComposer() {
    final l10n = context.l10n;
    return Container(
      padding: EdgeInsets.only(
        left: NeoSpacing.spaceMd,
        right: NeoSpacing.spaceMd,
        top: NeoSpacing.spaceXs,
        bottom: MediaQuery.of(context).viewInsets.bottom + NeoSpacing.spaceSm,
      ),
      decoration: const BoxDecoration(
        color: NeoColors.surface,
        border: Border(top: BorderSide(color: NeoColors.surfaceContainerHigh)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: NeoSpacing.spaceSm, vertical: 4),
        decoration: BoxDecoration(
          color: NeoColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: NeoColors.borderWhisper),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                style: NeoTypography.bodyMd,
                decoration: InputDecoration(
                  hintText: l10n.ticketsAddNoteHint,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                onSubmitted: (_) => _postComment(),
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: NeoColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: _isAddingComment
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_upward, size: 16, color: Colors.white),
                onPressed: _postComment,
                tooltip: l10n.cardCommentSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
