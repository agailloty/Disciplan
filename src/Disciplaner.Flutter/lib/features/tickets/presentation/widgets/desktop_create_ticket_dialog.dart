import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/l10n/enum_l10n.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/sprint_models.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/core/utils/media_utils.dart';
import 'package:disciplaner_flutter/core/widgets/neo_button.dart';
import 'package:disciplaner_flutter/core/widgets/priority_icon.dart'
    hide TicketType;
import 'package:disciplaner_flutter/core/widgets/user_avatar.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_state.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';
import 'package:disciplaner_flutter/features/sprints/presentation/sprint_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../ticket_providers.dart';
import 'attachment_panel.dart';

class DesktopCreateTicketDialog extends ConsumerStatefulWidget {
  final String? initialProjectId;
  final String? initialSprintId;

  const DesktopCreateTicketDialog({
    super.key,
    this.initialProjectId,
    this.initialSprintId,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialProjectId,
    String? initialSprintId,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => DesktopCreateTicketDialog(
        initialProjectId: initialProjectId,
        initialSprintId: initialSprintId,
      ),
    );
  }

  @override
  ConsumerState<DesktopCreateTicketDialog> createState() =>
      _DesktopCreateTicketDialogState();
}

class _DesktopCreateTicketDialogState
    extends ConsumerState<DesktopCreateTicketDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<PickedMediaFile> _pendingFiles = [];

  final TicketType _type = TicketType.task;
  CardPriority _priority = CardPriority.medium;
  DateTime? _dueDate;
  String? _assigneeId;
  String? _assigneeName;
  bool _assigneeTouched = false;
  String? _sprintId;
  bool _createMore = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _sprintId = widget.initialSprintId;
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

  Future<void> _pickFiles() async {
    try {
      final files = await MediaUtils.pickAttachmentFiles(allowMultiple: true);
      if (files.isNotEmpty && mounted) {
        setState(() {
          _pendingFiles.addAll(files);
          _errorMessage = null;
        });
      }
    } on MediaValidationException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _errorMessage = context.l10n.attachmentErrorUpload(e.toString()),
        );
      }
    }
  }

  Future<void> _handleSubmit(String projectId, String? assigneeId) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _errorMessage = context.l10n.ticketsTitleRequired);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(ticketRepositoryProvider);

      final createdTicket = await repo.createTicket(
        projectId,
        CreateTicketRequest(
          title: title,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          type: _type,
          priority: _priority,
          dueDate: _dueDate,
          assigneeId: assigneeId,
          sprintId: _sprintId,
        ),
      );

      if (_pendingFiles.isNotEmpty) {
        for (final file in _pendingFiles) {
          await repo.uploadTicketAttachment(createdTicket.id, file);
        }
      }

      ref.invalidate(projectBacklogProvider(projectId));
      if (_sprintId != null) {
        ref.invalidate(sprintTicketsProvider(_sprintId!));
      }
      ref.read(myTasksProvider.notifier).refresh();

      if (mounted) {
        if (_createMore) {
          _titleController.clear();
          _descriptionController.clear();
          setState(() {
            _pendingFiles.clear();
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.ticketsTaskCreatedNext)),
          );
        } else {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentProject = ref.watch(currentProjectDetailProvider).value;
    final projectId = widget.initialProjectId ?? currentProject?.id ?? '';
    final projectDetail = projectId.isNotEmpty
        ? (ref.watch(projectDetailByIdProvider(projectId)).value ?? currentProject)
        : currentProject;
    final authState = ref.watch(authNotifierProvider);
    final currentSession =
        authState is AuthAuthenticated ? authState.session : null;
    final assignableMembers = projectDetail?.assignableMembers(
          currentUserId: currentSession?.userId,
          currentUserDisplayName: currentSession?.displayName,
        ) ??
        const [];
    // Politique du projet : assigner le créateur par défaut tant que
    // l'utilisateur n'a pas explicitement touché le champ assigné.
    final policyDefaultAssignee = (!_assigneeTouched &&
            _assigneeId == null &&
            (projectDetail?.defaultAssigneePolicy ?? DefaultAssigneePolicy.none) ==
                DefaultAssigneePolicy.creator &&
            currentSession != null)
        ? assignableMembers
            .where((m) => m.userId == currentSession.userId)
            .firstOrNull
        : null;
    final effectiveAssigneeId = _assigneeId ?? policyDefaultAssignee?.userId;
    final effectiveAssigneeName = _assigneeName ?? policyDefaultAssignee?.displayName;
    final sprintsAsync = projectId.isNotEmpty
        ? ref.watch(projectSprintsProvider(projectId))
        : const AsyncValue.data(<SprintDto>[]);

    return Dialog(
      backgroundColor: NeoColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: NeoSpacing.roundedXl,
        side: const BorderSide(color: NeoColors.borderWhisper),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Padding(
          padding: const EdgeInsets.all(NeoSpacing.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header with Breadcrumb & Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        currentProject?.name ?? l10n.appTitle,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: NeoColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('/', style: NeoTypography.bodySm.copyWith(color: NeoColors.muted)),
                      const SizedBox(width: 6),
                      Text(
                        l10n.ticketsNewTask,
                        style: NeoTypography.bodySm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: NeoColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: NeoColors.muted,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: NeoSpacing.spaceMd),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(NeoSpacing.spaceSm),
                  decoration: BoxDecoration(
                    color: NeoColors.error.withValues(alpha: 0.1),
                    borderRadius: NeoSpacing.roundedSm,
                  ),
                  child: Text(
                    _errorMessage!,
                    style: NeoTypography.bodySm.copyWith(color: NeoColors.error),
                  ),
                ),
                const SizedBox(height: NeoSpacing.spaceSm),
              ],

              // 2. Title field (clean, spacious)
              TextField(
                controller: _titleController,
                autofocus: true,
                style: NeoTypography.headlineMd.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: l10n.ticketsTaskTitleHint,
                  hintStyle: NeoTypography.headlineMd.copyWith(
                    color: NeoColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: NeoSpacing.spaceSm),

              // 3. Description field
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                style: NeoTypography.bodyMd,
                decoration: InputDecoration(
                  hintText: l10n.ticketsDescriptionHint,
                  hintStyle: NeoTypography.bodyMd.copyWith(color: NeoColors.muted),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: NeoSpacing.spaceMd),

              // Pending files strip
              PendingFilesStrip(
                files: _pendingFiles,
                onRemoveAt: (idx) => setState(() => _pendingFiles.removeAt(idx)),
              ),

              // 4. Properties Strip (Horizontal Pills)
              Wrap(
                spacing: NeoSpacing.spaceSm,
                runSpacing: NeoSpacing.spaceSm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Priority selector
                  PopupMenuButton<CardPriority>(
                    tooltip: l10n.priority,
                    shape: RoundedRectangleBorder(
                      borderRadius: NeoSpacing.roundedMd,
                      side: const BorderSide(color: NeoColors.borderWhisper),
                    ),
                    onSelected: (p) => setState(() => _priority = p),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: CardPriority.low,
                        child: Text(CardPriority.low.localizedLabel(l10n)),
                      ),
                      PopupMenuItem(
                        value: CardPriority.medium,
                        child: Text(CardPriority.medium.localizedLabel(l10n)),
                      ),
                      PopupMenuItem(
                        value: CardPriority.high,
                        child: Text(CardPriority.high.localizedLabel(l10n)),
                      ),
                      PopupMenuItem(
                        value: CardPriority.critical,
                        child: Text(CardPriority.critical.localizedLabel(l10n)),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: NeoColors.surfaceContainerLow,
                        borderRadius: NeoSpacing.roundedFull,
                        border: Border.all(color: NeoColors.borderWhisper),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PriorityIcon(priority: _mapPriority(_priority), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            _priority.localizedLabel(l10n).toUpperCase(),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: NeoColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Assignee selector
                  if (assignableMembers.isNotEmpty)
                    PopupMenuButton<String>(
                      tooltip: l10n.ticketsAssignTo,
                      shape: RoundedRectangleBorder(
                        borderRadius: NeoSpacing.roundedMd,
                        side: const BorderSide(color: NeoColors.borderWhisper),
                      ),
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
                        ...assignableMembers.map((m) {
                          return PopupMenuItem(
                            value: m.userId,
                            child: Row(
                              children: [
                                UserAvatar(name: m.displayName, size: 20),
                                const SizedBox(width: 8),
                                Text(m.displayName, style: NeoTypography.bodySm),
                              ],
                            ),
                          );
                        }),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: NeoColors.surfaceContainerLow,
                          borderRadius: NeoSpacing.roundedFull,
                          border: Border.all(color: NeoColors.borderWhisper),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            UserAvatar(
                              name: effectiveAssigneeName ?? l10n.ticketNoAssignee,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              effectiveAssigneeName ?? l10n.ticketsAssign,
                              style: NeoTypography.bodySm.copyWith(
                                color: effectiveAssigneeName != null
                                    ? NeoColors.onSurface
                                    : NeoColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Sprint / Cycle selector
                  sprintsAsync.when(
                    data: (sprints) {
                      return PopupMenuButton<String>(
                        tooltip: l10n.ticketSprint,
                        shape: RoundedRectangleBorder(
                          borderRadius: NeoSpacing.roundedMd,
                          side: const BorderSide(color: NeoColors.borderWhisper),
                        ),
                        onSelected: (sId) => setState(
                          () => _sprintId = sId == '__BACKLOG__' ? null : sId,
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: '__BACKLOG__',
                            child: Text(l10n.ticketsBacklogNoSprint),
                          ),
                          ...sprints.map((s) => PopupMenuItem(
                                value: s.id,
                                child: Text(s.name),
                              )),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: NeoColors.surfaceContainerLow,
                            borderRadius: NeoSpacing.roundedFull,
                            border: Border.all(color: NeoColors.borderWhisper),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timelapse, size: 14, color: NeoColors.muted),
                              const SizedBox(width: 6),
                              Text(
                                _sprintId != null && sprints.isNotEmpty
                                    ? (sprints
                                        .where((s) => s.id == _sprintId)
                                        .map((s) => s.name)
                                        .firstOrNull ??
                                        l10n.projectBacklog)
                                    : l10n.projectBacklog,
                                style: NeoTypography.bodySm,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),

                  // Due Date
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _dueDate = picked);
                      }
                    },
                    borderRadius: NeoSpacing.roundedFull,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: NeoColors.surfaceContainerLow,
                        borderRadius: NeoSpacing.roundedFull,
                        border: Border.all(color: NeoColors.borderWhisper),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: NeoColors.muted),
                          const SizedBox(width: 6),
                          Text(
                            _dueDate != null
                                ? DateFormat('d MMM', Localizations.localeOf(context).toString()).format(_dueDate!)
                                : l10n.ticketDueDate,
                            style: NeoTypography.bodySm.copyWith(
                              color: _dueDate != null
                                  ? NeoColors.onSurface
                                  : NeoColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Attach files pill
                  InkWell(
                    onTap: _isLoading ? null : _pickFiles,
                    borderRadius: NeoSpacing.roundedFull,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _pendingFiles.isNotEmpty
                            ? NeoColors.primary.withValues(alpha: 0.14)
                            : NeoColors.surfaceContainerLow,
                        borderRadius: NeoSpacing.roundedFull,
                        border: Border.all(
                          color: _pendingFiles.isNotEmpty
                              ? NeoColors.primary.withValues(alpha: 0.4)
                              : NeoColors.borderWhisper,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.attach_file,
                            size: 14,
                            color: _pendingFiles.isNotEmpty
                                ? NeoColors.primary
                                : NeoColors.muted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _pendingFiles.isEmpty
                                ? l10n.attachmentAttach
                                : '${l10n.attachmentAttach} (${_pendingFiles.length})',
                            style: NeoTypography.bodySm.copyWith(
                              color: _pendingFiles.isNotEmpty
                                  ? NeoColors.primary
                                  : NeoColors.muted,
                              fontWeight: _pendingFiles.isNotEmpty
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: NeoSpacing.spaceLg),

              // 5. Footer: "Créer une autre" + Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: InkWell(
                      onTap: () => setState(() => _createMore = !_createMore),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _createMore,
                            onChanged: (val) => setState(() => _createMore = val ?? false),
                            activeColor: NeoColors.primary,
                          ),
                          Flexible(
                            child: Text(l10n.ticketsCreateAnother, style: NeoTypography.bodySm),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      NeoButton(
                        label: l10n.cancel,
                        variant: NeoButtonVariant.secondary,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: NeoSpacing.spaceSm),
                      NeoButton(
                        label: l10n.ticketsCreateTask,
                        isLoading: _isLoading,
                        onPressed: projectId.isNotEmpty
                            ? () => _handleSubmit(projectId, effectiveAssigneeId)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
