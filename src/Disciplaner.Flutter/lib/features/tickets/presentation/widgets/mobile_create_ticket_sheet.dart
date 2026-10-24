import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/l10n/enum_l10n.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/core/widgets/priority_icon.dart'
    hide TicketType;
import 'package:disciplaner_flutter/core/widgets/user_avatar.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_state.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../ticket_providers.dart';

class MobileCreateTicketSheet extends ConsumerStatefulWidget {
  final String? initialProjectId;
  final String? initialSprintId;

  const MobileCreateTicketSheet({
    super.key,
    this.initialProjectId,
    this.initialSprintId,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialProjectId,
    String? initialSprintId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MobileCreateTicketSheet(
        initialProjectId: initialProjectId,
        initialSprintId: initialSprintId,
      ),
    );
  }

  @override
  ConsumerState<MobileCreateTicketSheet> createState() =>
      _MobileCreateTicketSheetState();
}

class _MobileCreateTicketSheetState
    extends ConsumerState<MobileCreateTicketSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  CardPriority _priority = CardPriority.medium;
  StatusCategory _status = StatusCategory.backlog;
  DateTime? _dueDate;
  String? _assigneeId;
  String? _assigneeName;
  bool _assigneeTouched = false;
  String? _selectedProjectId;
  String? _selectedSprintId;
  bool _createMore = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.initialProjectId;
    _selectedSprintId = widget.initialSprintId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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

  Future<void> _handleSubmit(String projectId) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _errorMessage = context.l10n.ticketsTitleRequired);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Politique du projet : assigner le créateur par défaut tant que
    // l'utilisateur n'a pas explicitement touché le champ assigné.
    var assigneeId = _assigneeId;
    if (!_assigneeTouched && assigneeId == null) {
      final projectDetail =
          ref.read(projectDetailByIdProvider(projectId)).value;
      final authState = ref.read(authNotifierProvider);
      final session = authState is AuthAuthenticated ? authState.session : null;
      if ((projectDetail?.defaultAssigneePolicy ??
                  DefaultAssigneePolicy.none) ==
              DefaultAssigneePolicy.creator &&
          session != null) {
        final members = projectDetail!.assignableMembers(
          currentUserId: session.userId,
          currentUserDisplayName: session.displayName,
        );
        assigneeId = members
            .where((m) => m.userId == session.userId)
            .firstOrNull
            ?.userId;
      }
    }

    try {
      final repo = ref.read(ticketRepositoryProvider);
      await repo.createTicket(
        projectId,
        CreateTicketRequest(
          title: title,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          type: TicketType.task,
          priority: _priority,
          sprintId: _selectedSprintId,
          assigneeId: assigneeId,
          dueDate: _dueDate,
        ),
      );

      ref.invalidate(projectBacklogProvider(projectId));
      ref.invalidate(myTasksProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: NeoColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: NeoColors.emerald, size: 18),
                const SizedBox(width: NeoSpacing.spaceSm),
                Text(
                  context.l10n.ticketsTaskCreated,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            duration: const Duration(milliseconds: 2000),
          ),
        );

        if (_createMore) {
          _titleController.clear();
          _descriptionController.clear();
          setState(() {
            _isLoading = false;
          });
        } else {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final projectsAsync = ref.watch(projectsListProvider);
    final projects = projectsAsync.asData?.value ?? <ProjectSummaryDto>[];

    final effectiveProjectId = _selectedProjectId ??
        ref.watch(selectedProjectIdProvider) ??
        (projects.isNotEmpty ? projects.first.id : null);

    final selectedProject = projects.where((p) => p.id == effectiveProjectId).firstOrNull ??
        (projects.isNotEmpty ? projects.first : null);

    final projectDetail = effectiveProjectId != null
        ? ref.watch(projectDetailByIdProvider(effectiveProjectId)).value
        : null;
    final authState = ref.watch(authNotifierProvider);
    final currentSession =
        authState is AuthAuthenticated ? authState.session : null;
    final assignableMembers = projectDetail?.assignableMembers(
          currentUserId: currentSession?.userId,
          currentUserDisplayName: currentSession?.displayName,
        ) ??
        const <MemberDto>[];
    // Politique du projet : afficher le créateur comme assigné par défaut.
    final policyDefaultAssignee = (!_assigneeTouched &&
            _assigneeId == null &&
            (projectDetail?.defaultAssigneePolicy ??
                    DefaultAssigneePolicy.none) ==
                DefaultAssigneePolicy.creator &&
            currentSession != null)
        ? assignableMembers
            .where((m) => m.userId == currentSession.userId)
            .firstOrNull
        : null;
    final effectiveAssigneeName =
        _assigneeName ?? policyDefaultAssignee?.displayName;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
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
          // Top bar (Annuler / Pill / Créer)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: NeoSpacing.spaceMd,
              vertical: NeoSpacing.spaceXs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    l10n.cancel,
                    style: NeoTypography.bodyMd.copyWith(color: NeoColors.onSurfaceVariant),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: NeoSpacing.spaceSm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: NeoColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: NeoColors.emerald,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        selectedProject?.key ?? 'NEW',
                        style: NeoTypography.labelSm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: NeoColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: (_isLoading || effectiveProjectId == null)
                      ? null
                      : () => _handleSubmit(effectiveProjectId),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.arrow_forward, size: 16),
                  label: Text(l10n.create),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NeoColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: NeoSpacing.spaceMd,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_errorMessage != null)
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: NeoSpacing.spaceMd,
                vertical: 4,
              ),
              padding: const EdgeInsets.all(NeoSpacing.spaceSm),
              decoration: BoxDecoration(
                color: NeoColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: NeoColors.error, fontSize: 13),
              ),
            ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: NeoSpacing.spaceMd,
                vertical: NeoSpacing.spaceSm,
              ),
              children: [
                // Title and description card
                Container(
                  padding: const EdgeInsets.all(NeoSpacing.spaceMd),
                  decoration: BoxDecoration(
                    color: NeoColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: NeoColors.borderWhisper),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        autofocus: true,
                        style: NeoTypography.headlineMd.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: l10n.ticketsTaskTitleActionHint,
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const Divider(height: NeoSpacing.spaceMd, color: NeoColors.surfaceContainerHigh),
                      TextField(
                        controller: _descriptionController,
                        style: NeoTypography.bodyMd,
                        maxLines: 4,
                        minLines: 2,
                        decoration: InputDecoration(
                          hintText: l10n.ticketsNotesHint,
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: NeoSpacing.spaceMd),

                // Quick metadata section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        l10n.ticketsQuickMetadata,
                        style: NeoTypography.labelSm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: NeoColors.onSurfaceVariant,
                          letterSpacing: 0.8,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        l10n.ticketsEditableAnytime,
                        style: NeoTypography.labelSm.copyWith(color: NeoColors.muted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: NeoSpacing.spaceXs),

                Container(
                  decoration: BoxDecoration(
                    color: NeoColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: NeoColors.borderWhisper),
                  ),
                  child: Column(
                    children: [
                      // Status row
                      _buildMetaRow(
                        icon: Icons.radio_button_unchecked,
                        label: l10n.status,
                        action: PopupMenuButton<StatusCategory>(
                          initialValue: _status,
                          onSelected: (cat) => setState(() => _status = cat),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                  _status.localizedLabel(l10n),
                                  style: NeoTypography.headlineSm.copyWith(
                                    fontSize: 13,
                                    color: NeoColors.secondary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.expand_more, size: 16, color: NeoColors.onSurfaceVariant),
                              ],
                            ),
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(value: StatusCategory.backlog, child: Text(l10n.ticketsTodo)),
                            PopupMenuItem(value: StatusCategory.inProgress, child: Text(l10n.statuscategoryInProgress)),
                            PopupMenuItem(value: StatusCategory.done, child: Text(l10n.statuscategoryDone)),
                          ],
                        ),
                      ),
                      const Divider(height: 1, indent: NeoSpacing.spaceSm, endIndent: NeoSpacing.spaceSm),

                      // Priority row
                      _buildMetaRow(
                        icon: Icons.signal_cellular_alt_2_bar,
                        label: l10n.priority,
                        action: PopupMenuButton<CardPriority>(
                          initialValue: _priority,
                          onSelected: (p) => setState(() => _priority = p),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: NeoColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PriorityIcon(priority: _mapPriority(_priority), size: 15),
                                const SizedBox(width: 6),
                                Text(
                                  _priority.localizedLabel(l10n),
                                  style: NeoTypography.headlineSm.copyWith(fontSize: 13),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.expand_more, size: 16, color: NeoColors.onSurfaceVariant),
                              ],
                            ),
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(value: CardPriority.low, child: Text(CardPriority.low.localizedLabel(l10n))),
                            PopupMenuItem(value: CardPriority.medium, child: Text(CardPriority.medium.localizedLabel(l10n))),
                            PopupMenuItem(value: CardPriority.high, child: Text(CardPriority.high.localizedLabel(l10n))),
                            PopupMenuItem(value: CardPriority.critical, child: Text(CardPriority.critical.localizedLabel(l10n))),
                          ],
                        ),
                      ),
                      const Divider(height: 1, indent: NeoSpacing.spaceSm, endIndent: NeoSpacing.spaceSm),

                      // Assignee row
                      _buildMetaRow(
                        icon: Icons.person_outline,
                        label: l10n.ticketAssignee,
                        action: PopupMenuButton<String>(
                          onSelected: (userId) {
                            setState(() {
                              _assigneeTouched = true;
                              if (userId == '__UNASSIGNED__') {
                                _assigneeId = null;
                                _assigneeName = null;
                              } else {
                                final m = assignableMembers.firstWhere(
                                  (member) => member.userId == userId,
                                );
                                _assigneeId = m.userId;
                                _assigneeName = m.displayName;
                              }
                            });
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: '__UNASSIGNED__',
                              child: Text(l10n.ticketNoAssignee),
                            ),
                            ...assignableMembers.map(
                              (m) => PopupMenuItem(
                                value: m.userId,
                                child: Row(
                                  children: [
                                    UserAvatar(name: m.displayName, size: 18),
                                    const SizedBox(width: 8),
                                    Text(m.displayName),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: NeoColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (effectiveAssigneeName != null) ...[
                                  UserAvatar(name: effectiveAssigneeName, size: 18),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      effectiveAssigneeName,
                                      overflow: TextOverflow.ellipsis,
                                      style: NeoTypography.headlineSm.copyWith(fontSize: 13),
                                    ),
                                  ),
                                ] else ...[
                                  const Icon(Icons.person_add_outlined, size: 15, color: NeoColors.muted),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      l10n.ticketNoAssignee,
                                      overflow: TextOverflow.ellipsis,
                                      style: NeoTypography.headlineSm.copyWith(
                                        fontSize: 13,
                                        color: NeoColors.muted,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(width: 4),
                                const Icon(Icons.expand_more, size: 16, color: NeoColors.onSurfaceVariant),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1, indent: NeoSpacing.spaceSm, endIndent: NeoSpacing.spaceSm),

                      // Project row
                      _buildMetaRow(
                        icon: Icons.folder_open,
                        label: l10n.colProject,
                        action: PopupMenuButton<String>(
                          initialValue: effectiveProjectId,
                          onSelected: (id) => setState(() {
                            _selectedProjectId = id;
                            _assigneeId = null;
                            _assigneeName = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: NeoColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    selectedProject?.name ?? l10n.ticketsSelectProject,
                                    overflow: TextOverflow.ellipsis,
                                    style: NeoTypography.headlineSm.copyWith(fontSize: 13),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.expand_more, size: 16, color: NeoColors.onSurfaceVariant),
                              ],
                            ),
                          ),
                          itemBuilder: (context) => projects
                              .map((p) => PopupMenuItem(value: p.id, child: Text(p.name)))
                              .toList(),
                        ),
                      ),
                      const Divider(height: 1, indent: NeoSpacing.spaceSm, endIndent: NeoSpacing.spaceSm),

                      // Due date row
                      _buildMetaRow(
                        icon: Icons.calendar_today_outlined,
                        label: l10n.ticketDueDate,
                        action: InkWell(
                          onTap: () async {
                            final now = DateTime.now();
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _dueDate ?? now,
                              firstDate: now.subtract(const Duration(days: 30)),
                              lastDate: now.add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() => _dueDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: NeoColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    _dueDate != null
                                        ? DateFormat('dd MMM yyyy').format(_dueDate!)
                                        : l10n.ticketsNone,
                                    overflow: TextOverflow.ellipsis,
                                    style: NeoTypography.headlineSm.copyWith(
                                      fontSize: 13,
                                      color: _dueDate != null
                                          ? NeoColors.onSurface
                                          : NeoColors.muted,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.expand_more, size: 16, color: NeoColors.onSurfaceVariant),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: NeoSpacing.spaceMd),

                // Toggle create another
                Container(
                  padding: const EdgeInsets.all(NeoSpacing.spaceMd),
                  decoration: BoxDecoration(
                    color: NeoColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: NeoColors.borderWhisper),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.autorenew, color: NeoColors.onSurfaceVariant, size: 22),
                      const SizedBox(width: NeoSpacing.spaceSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.ticketsCreateAnotherNext,
                              style: NeoTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              l10n.ticketsKeepOpenHint,
                              style: NeoTypography.labelSm.copyWith(color: NeoColors.muted),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _createMore,
                        activeThumbColor: NeoColors.primary,
                        onChanged: (val) => setState(() => _createMore = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: NeoSpacing.spaceXl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required Widget action,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: NeoSpacing.spaceSm,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: NeoColors.onSurfaceVariant),
              const SizedBox(width: NeoSpacing.spaceSm),
              Text(
                label,
                style: NeoTypography.bodyMd.copyWith(color: NeoColors.primary),
              ),
            ],
          ),
          const SizedBox(width: NeoSpacing.spaceSm),
          Flexible(child: action),
        ],
      ),
    );
  }
}
