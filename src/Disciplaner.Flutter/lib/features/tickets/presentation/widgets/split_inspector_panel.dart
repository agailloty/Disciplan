import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/core/widgets/priority_icon.dart'
    hide TicketType;
import 'package:disciplaner_flutter/core/widgets/user_avatar.dart';
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
  late TabController _tabController;
  final _commentController = TextEditingController();
  final _subtaskController = TextEditingController();
  bool _isAddingComment = false;
  bool _isAddingSubtask = false;

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
          type: ticket.type,
          priority: ticket.priority,
        ),
      );
      _subtaskController.clear();
      ref.invalidate(ticketDetailProvider(widget.ticketId));
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

  @override
  Widget build(BuildContext context) {
    final ticketAsync = ref.watch(ticketDetailProvider(widget.ticketId));
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: NeoSpacing.inspectorWidth(screenWidth),
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLowest,
        border: const Border(
          left: BorderSide(color: NeoColors.borderWhisper),
        ),
        boxShadow: const [
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
    return Column(
      children: [
        // Header
        _buildHeader(ticket),
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

              // Key Properties
              _buildPropertiesSection(ticket),
              const SizedBox(height: NeoSpacing.spaceMd),

              // Labels
              _buildLabelsSection(ticket),
              const SizedBox(height: NeoSpacing.spaceMd),

              // Subtasks / Livrables
              _buildSubtasksSection(ticket),
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

  Widget _buildHeader(TicketDto ticket) {
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
              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                  ],
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

  Widget _buildPropertiesSection(TicketDto ticket) {
    return Container(
      padding: const EdgeInsets.all(NeoSpacing.spaceSm),
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NeoColors.borderWhisper),
      ),
      child: Column(
        children: [
          _buildPropertyRow(
            'Priorité',
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PriorityIcon(priority: _mapPriority(ticket.priority), size: 15),
                const SizedBox(width: 6),
                Text(
                  ticket.priority.label,
                  style: NeoTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Divider(height: 12, color: NeoColors.surfaceContainerHigh),
          _buildPropertyRow(
            'Assigné',
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (ticket.assigneeName != null) ...[
                  UserAvatar(name: ticket.assigneeName!, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    ticket.assigneeName!,
                    style: NeoTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
                  ),
                ] else
                  Text(
                    'Non assigné',
                    style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                  ),
              ],
            ),
          ),
          const Divider(height: 12, color: NeoColors.surfaceContainerHigh),
          _buildPropertyRow(
            'Sprint / Cycle',
            Text(
              ticket.sprintName ?? 'Backlog (sans sprint)',
              style: NeoTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const Divider(height: 12, color: NeoColors.surfaceContainerHigh),
          _buildPropertyRow(
            'Points d\'effort',
            Text(
              '${ticket.storyPoints ?? 0} pts',
              style: NeoTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const Divider(height: 12, color: NeoColors.surfaceContainerHigh),
          _buildPropertyRow(
            'Échéance',
            Text(
              ticket.dueDate != null
                  ? DateFormat('dd MMM yyyy').format(ticket.dueDate!)
                  : 'Aucune',
              style: NeoTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
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
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            ...ticket.labels.map((label) {
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
            }),
            ActionChip(
              visualDensity: VisualDensity.compact,
              avatar: const Icon(Icons.add, size: 14),
              label: const Text('Ajouter'),
              labelStyle: NeoTypography.labelSm.copyWith(fontSize: 11),
              onPressed: () {},
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubtasksSection(TicketDto ticket) {
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
                  '1/2',
                  style: NeoTypography.labelSm.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: NeoSpacing.spaceXs),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.5,
              minHeight: 4,
              backgroundColor: NeoColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(NeoColors.primary),
            ),
          ),
          const SizedBox(height: NeoSpacing.spaceSm),

          // Subtask demo items
          _buildSubtaskItem('Validation des spécifications techniques', true),
          _buildSubtaskItem('Implémentation des endpoints d\'audit', false),

          const SizedBox(height: NeoSpacing.spaceXs),
          // Quick add
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _subtaskController,
                  style: NeoTypography.bodySm,
                  decoration: const InputDecoration(
                    hintText: 'Ajouter une sous-tâche...',
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

  Widget _buildSubtaskItem(String title, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: isDone,
              onChanged: (_) {},
              activeColor: NeoColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
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
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.upload_file, size: 14),
                label: const Text('Joindre'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
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
                    trailing: IconButton(
                      icon: const Icon(Icons.download, size: 16),
                      onPressed: () {},
                    ),
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
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: const BoxDecoration(
                      color: NeoColors.muted,
                      shape: BoxShape.circle,
                    ),
                  ),
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
                              TextSpan(
                                text: ' a modifié ${entry.kind}',
                                style: const TextStyle(color: NeoColors.onSurfaceVariant),
                              ),
                              if (entry.newValue != null)
                                TextSpan(
                                  text: ' vers "${entry.newValue}"',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(entry.occurredAt),
                          style: NeoTypography.labelSm.copyWith(color: NeoColors.muted),
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
}
