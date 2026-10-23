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
  final _commentController = TextEditingController();
  bool _isAddingComment = false;
  final List<bool> _subtasksDone = [true, true, false, false];
  final List<String> _subtaskTitles = [
    'Gabarits 4x3 JCDecaux & Clear Channel',
    'Déclinaison abribus 120x176 cm',
    'Validation colorimétrique avec l\'imprimeur',
    'Export des fichiers haute définition',
  ];

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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Commentaire publié'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAddingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  'Détail Ticket',
                  style: NeoTypography.headlineSm.copyWith(fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
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
                      Text('Erreur chargement ticket', style: NeoTypography.headlineSm),
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
    final doneCount = _subtasksDone.where((d) => d).length;
    final totalCount = _subtasksDone.length;
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
                  // Status Pill
                  Container(
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
                      ],
                    ),
                  ),
                  // Priority Chip
                  Container(
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
                          ticket.priority.label.toUpperCase(),
                          style: NeoTypography.labelSm.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ],
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.share, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: ticket.ticketRef));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text('Lien du ticket copié'),
                        duration: Duration(milliseconds: 1500),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border, size: 18),
                  onPressed: () {},
                ),
              ],
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

        // Key Properties 2x2 Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.2,
          crossAxisSpacing: NeoSpacing.spaceXs,
          mainAxisSpacing: NeoSpacing.spaceXs,
          children: [
            // Assignee
            _buildPropCard(
              avatar: ticket.assigneeName != null
                  ? UserAvatar(name: ticket.assigneeName!, size: 30)
                  : const CircleAvatar(
                      radius: 15,
                      backgroundColor: NeoColors.surfaceContainerHigh,
                      child: Icon(Icons.person, size: 16, color: NeoColors.muted),
                    ),
              label: 'ASSIGNÉ',
              value: ticket.assigneeName ?? 'Non assigné',
            ),
            // Deadline
            _buildPropCard(
              avatar: const CircleAvatar(
                radius: 15,
                backgroundColor: NeoColors.secondaryContainer,
                child: Icon(Icons.schedule, size: 16, color: NeoColors.secondary),
              ),
              label: 'ÉCHÉANCE',
              value: ticket.dueDate != null
                  ? DateFormat('dd MMM yyyy').format(ticket.dueDate!)
                  : 'Non définie',
            ),
            // Project
            _buildPropCard(
              avatar: const CircleAvatar(
                radius: 15,
                backgroundColor: NeoColors.surfaceContainerHigh,
                child: Icon(Icons.campaign, size: 16, color: NeoColors.primary),
              ),
              label: 'PROJET',
              value: ticket.projectKey,
            ),
            // Sprint
            _buildPropCard(
              avatar: const CircleAvatar(
                radius: 15,
                backgroundColor: NeoColors.surfaceContainerHigh,
                child: Icon(Icons.palette, size: 16, color: NeoColors.primary),
              ),
              label: 'CYCLE / SPRINT',
              value: ticket.sprintName ?? 'Backlog',
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
                      'NOTE D\'INTENTION',
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

        // Interactive Deliverables Checklist (Sous-tâches)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      'Livrables requis',
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
            Text(
              '${(progress * 100).round()}% complété',
              style: NeoTypography.labelSm.copyWith(color: NeoColors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Progress track
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

        // Checklist items
        ...List.generate(_subtaskTitles.length, (index) {
          final isDone = _subtasksDone[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              onTap: () {
                setState(() {
                  _subtasksDone[index] = !_subtasksDone[index];
                });
              },
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
                        _subtaskTitles[index],
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

        const SizedBox(height: NeoSpacing.spaceMd),

        // Fichier de travail / Attachments
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Fichier de travail',
                style: NeoTypography.headlineSm.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              'Synchronisé',
              style: NeoTypography.labelSm.copyWith(color: NeoColors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(NeoSpacing.spaceMd),
          decoration: BoxDecoration(
            color: NeoColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NeoColors.borderWhisper),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: NeoColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.design_services, color: NeoColors.primary, size: 22),
              ),
              const SizedBox(width: NeoSpacing.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maquette Figma - Affichage Urbain',
                      style: NeoTypography.headlineSm.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('142 Mo', style: NeoTypography.labelSm.copyWith(color: NeoColors.onSurfaceVariant)),
                        const Text('•', style: TextStyle(color: NeoColors.borderWhisper)),
                        Text('Mis à jour à 11:20', style: NeoTypography.labelSm.copyWith(color: NeoColors.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.open_in_new, size: 18, color: NeoColors.onSurfaceVariant),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsThread() {
    final commentsAsync = ref.watch(ticketCommentsProvider(widget.ticketId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Échanges récents',
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
                  'Aucun échange pour le moment.',
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
                                  style: NeoTypography.headlineSm.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  DateFormat('HH:mm').format(comment.createdAt),
                                  style: NeoTypography.labelSm.copyWith(color: NeoColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              comment.content,
                              style: NeoTypography.bodySm.copyWith(color: NeoColors.onSurfaceVariant),
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
          error: (err, _) => Text('Erreur: $err', style: NeoTypography.bodySm),
        ),
      ],
    );
  }

  Widget _buildCommentComposer() {
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
                decoration: const InputDecoration(
                  hintText: 'Ajouter une note...',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.attach_file, size: 20, color: NeoColors.onSurfaceVariant),
              onPressed: () {},
              tooltip: 'Joindre un fichier',
            ),
            IconButton(
              icon: const Icon(Icons.mic_none, size: 20, color: NeoColors.onSurfaceVariant),
              onPressed: () {},
              tooltip: 'Note vocale',
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
                tooltip: 'Envoyer',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
