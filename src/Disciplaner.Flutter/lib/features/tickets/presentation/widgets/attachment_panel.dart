import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/neo_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/models/collaboration_models.dart';
import '../../../../core/utils/file_downloader.dart';
import '../../../../core/utils/media_utils.dart';
import '../ticket_providers.dart';
import 'file_preview_dialog.dart';

/// Interactive panel for viewing, uploading, previewing, downloading, and
/// deleting attachments on a ticket.
class TicketAttachmentsSection extends ConsumerStatefulWidget {
  final String ticketId;
  final bool isCompact;

  const TicketAttachmentsSection({
    super.key,
    required this.ticketId,
    this.isCompact = false,
  });

  @override
  ConsumerState<TicketAttachmentsSection> createState() =>
      _TicketAttachmentsSectionState();
}

class _TicketAttachmentsSectionState
    extends ConsumerState<TicketAttachmentsSection> {
  bool _isUploading = false;
  String? _errorMessage;
  final Set<String> _downloadingIds = {};
  final Set<String> _deletingIds = {};

  Future<void> _pickAndUpload() async {
    if (_isUploading) return;
    setState(() => _errorMessage = null);

    List<PickedMediaFile> files;
    try {
      files = await MediaUtils.pickAttachmentFiles(allowMultiple: true);
    } on MediaValidationException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.message);
      }
      return;
    } catch (e) {
      if (mounted) {
        setState(
          () => _errorMessage = context.l10n.attachmentErrorUpload(e.toString()),
        );
      }
      return;
    }

    if (files.isEmpty || !mounted) return;

    setState(() => _isUploading = true);
    try {
      final repo = ref.read(ticketRepositoryProvider);
      for (final file in files) {
        await repo.uploadTicketAttachment(widget.ticketId, file);
      }
      ref.invalidate(ticketAttachmentsProvider(widget.ticketId));
      ref.invalidate(ticketHistoryProvider(widget.ticketId));
    } catch (e) {
      if (mounted) {
        setState(
          () => _errorMessage = context.l10n.attachmentErrorUpload(e.toString()),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _downloadAttachment(AttachmentDto att) async {
    if (_downloadingIds.contains(att.id)) return;
    setState(() {
      _downloadingIds.add(att.id);
      _errorMessage = null;
    });

    try {
      final (bytes, downloadedMime) = await ref
          .read(attachmentDownloadProvider(att.id).future);
      final mime = att.contentType.isNotEmpty
          ? att.contentType
          : downloadedMime;
      await FileDownloader.saveOrDownload(
        bytes: bytes,
        fileName: att.originalFileName,
        contentType: mime,
      );
    } catch (e) {
      if (mounted) {
        setState(
          () => _errorMessage =
              context.l10n.attachmentErrorDownload(e.toString()),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _downloadingIds.remove(att.id));
      }
    }
  }

  Future<void> _deleteAttachment(AttachmentDto att) async {
    if (_deletingIds.contains(att.id)) return;
    setState(() {
      _deletingIds.add(att.id);
      _errorMessage = null;
    });

    try {
      final repo = ref.read(ticketRepositoryProvider);
      await repo.deleteAttachment(att.id);
      ref.invalidate(ticketAttachmentsProvider(widget.ticketId));
      ref.invalidate(ticketHistoryProvider(widget.ticketId));
    } catch (e) {
      if (mounted) {
        setState(
          () => _errorMessage = context.l10n.attachmentErrorDelete(e.toString()),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _deletingIds.remove(att.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final attachmentsAsync =
        ref.watch(ticketAttachmentsProvider(widget.ticketId));

    return attachmentsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(minHeight: 2),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          l10n.attachmentErrorLoad(err.toString()),
          style: GoogleFonts.inter(fontSize: 12, color: NeoColors.error),
        ),
      ),
      data: (attachments) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.attach_file,
                  size: 16,
                  color: NeoColors.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    l10n.attachmentSectionLabel,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: NeoColors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: NeoColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${attachments.length}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: NeoColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _isUploading ? null : _pickAndUpload,
                  style: TextButton.styleFrom(
                    foregroundColor: NeoColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: _isUploading
                      ? const SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: NeoColors.primary,
                          ),
                        )
                      : const Icon(Icons.add, size: 15),
                  label: Text(
                    _isUploading ? l10n.attachmentUploading : l10n.attachmentAdd,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: NeoColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: NeoColors.error.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 15,
                      color: NeoColors.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: NeoColors.error,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _errorMessage = null),
                      child: const Icon(
                        Icons.close,
                        size: 15,
                        color: NeoColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            if (attachments.isEmpty)
              InkWell(
                onTap: _isUploading ? null : _pickAndUpload,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: NeoColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: NeoColors.borderWhisper),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cloud_upload_outlined,
                        size: 18,
                        color: NeoColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.attachmentEmpty,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: NeoColors.onSurfaceVariant
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...attachments.map(
                (att) => _AttachmentCard(
                  attachment: att,
                  isDownloading: _downloadingIds.contains(att.id),
                  isDeleting: _deletingIds.contains(att.id),
                  onPreview: () => FilePreviewDialog.show(
                    context,
                    attachment: att,
                  ),
                  onDownload: () => _downloadAttachment(att),
                  onDelete: () => _deleteAttachment(att),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AttachmentCard extends ConsumerWidget {
  final AttachmentDto attachment;
  final bool isDownloading;
  final bool isDeleting;
  final VoidCallback onPreview;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _AttachmentCard({
    required this.attachment,
    required this.isDownloading,
    required this.isDeleting,
    required this.onPreview,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mime = attachment.contentType.isNotEmpty
        ? attachment.contentType
        : MediaUtils.resolveMimeType(attachment.originalFileName);
    final isImage = MediaUtils.isImageContentType(mime);
    final accentColor = MediaUtils.colorForContentType(mime);
    final dateStr = DateFormat('dd/MM/yyyy HH:mm')
        .format(attachment.uploadedAt.toLocal());

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: NeoColors.borderWhisper),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isImage)
            _InlineImagePreviewBanner(
              attachmentId: attachment.id,
              onTap: onPreview,
            ),
          InkWell(
            onTap: onPreview,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      MediaUtils.iconForContentType(mime),
                      size: 18,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attachment.originalFileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: NeoColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${MediaUtils.formatFileSize(attachment.fileSizeBytes)} • ${attachment.uploadedByDisplayName} • $dateStr',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: NeoColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.attachmentPreview,
                    icon: const Icon(Icons.visibility_outlined, size: 17),
                    color: NeoColors.onSurfaceVariant,
                    visualDensity: VisualDensity.compact,
                    onPressed: onPreview,
                  ),
                  IconButton(
                    tooltip: l10n.attachmentDownload,
                    icon: isDownloading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download_outlined, size: 17),
                    color: NeoColors.primary,
                    visualDensity: VisualDensity.compact,
                    onPressed: isDownloading ? null : onDownload,
                  ),
                  IconButton(
                    tooltip: l10n.delete,
                    icon: isDeleting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline, size: 17),
                    color: NeoColors.error,
                    visualDensity: VisualDensity.compact,
                    onPressed: isDeleting ? null : onDelete,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineImagePreviewBanner extends ConsumerWidget {
  final String attachmentId;
  final VoidCallback onTap;

  const _InlineImagePreviewBanner({
    required this.attachmentId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadAsync = ref.watch(attachmentDownloadProvider(attachmentId));
    return downloadAsync.maybeWhen(
      data: (result) {
        final (bytes, _) = result;
        if (bytes.isEmpty) return const SizedBox.shrink();
        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: 130,
            width: double.infinity,
            color: NeoColors.surfaceContainerLowest,
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

/// Renders attachments belonging to a specific comment (`GET /api/comments/{commentId}/attachments`).
class CommentAttachmentsList extends ConsumerStatefulWidget {
  final String commentId;
  final String ticketId;

  const CommentAttachmentsList({
    super.key,
    required this.commentId,
    required this.ticketId,
  });

  @override
  ConsumerState<CommentAttachmentsList> createState() =>
      _CommentAttachmentsListState();
}

class _CommentAttachmentsListState
    extends ConsumerState<CommentAttachmentsList> {
  final Set<String> _deletingIds = {};

  Future<void> _download(AttachmentDto att) async {
    try {
      final (bytes, downloadedMime) = await ref
          .read(attachmentDownloadProvider(att.id).future);
      final mime = att.contentType.isNotEmpty
          ? att.contentType
          : downloadedMime;
      await FileDownloader.saveOrDownload(
        bytes: bytes,
        fileName: att.originalFileName,
        contentType: mime,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.attachmentErrorDownload(e.toString()),
            ),
            backgroundColor: NeoColors.error,
          ),
        );
      }
    }
  }

  Future<void> _delete(AttachmentDto att) async {
    if (_deletingIds.contains(att.id)) return;
    setState(() => _deletingIds.add(att.id));
    try {
      final repo = ref.read(ticketRepositoryProvider);
      await repo.deleteAttachment(att.id);
      ref.invalidate(commentAttachmentsProvider(widget.commentId));
      ref.invalidate(ticketHistoryProvider(widget.ticketId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.attachmentErrorDelete(e.toString())),
            backgroundColor: NeoColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _deletingIds.remove(att.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final attachmentsAsync =
        ref.watch(commentAttachmentsProvider(widget.commentId));

    return attachmentsAsync.maybeWhen(
      data: (attachments) {
        if (attachments.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            children: attachments.map((att) {
              final mime = att.contentType.isNotEmpty
                  ? att.contentType
                  : MediaUtils.resolveMimeType(att.originalFileName);
              final accent = MediaUtils.colorForContentType(mime);
              final isDeleting = _deletingIds.contains(att.id);

              return Container(
                constraints: const BoxConstraints(maxWidth: 280),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: NeoColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: NeoColors.borderWhisper),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      MediaUtils.iconForContentType(mime),
                      size: 15,
                      color: accent,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: InkWell(
                        onTap: () => FilePreviewDialog.show(
                          context,
                          attachment: att,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              att.originalFileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: NeoColors.onSurface,
                              ),
                            ),
                            Text(
                              MediaUtils.formatFileSize(att.fileSizeBytes),
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9.5,
                                color: NeoColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => _download(att),
                      child: const Padding(
                        padding: EdgeInsets.all(3),
                        child: Icon(
                          Icons.download_outlined,
                          size: 14,
                          color: NeoColors.primary,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: isDeleting ? null : () => _delete(att),
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: isDeleting
                              ? NeoColors.onSurfaceVariant
                              : NeoColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

/// Horizontal/wrapped strip displaying pending [PickedMediaFile] items before upload.
class PendingFilesStrip extends StatelessWidget {
  final List<PickedMediaFile> files;
  final ValueChanged<int> onRemoveAt;

  const PendingFilesStrip({
    super.key,
    required this.files,
    required this.onRemoveAt,
  });

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: List.generate(files.length, (index) {
          final file = files[index];
          final accent = MediaUtils.colorForContentType(file.contentType);
          return Container(
            constraints: const BoxConstraints(maxWidth: 240),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: NeoColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: NeoColors.borderSubtle),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (file.isImage && file.bytes.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.memory(
                      file.bytes,
                      width: 22,
                      height: 22,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        MediaUtils.iconForContentType(file.contentType),
                        size: 15,
                        color: accent,
                      ),
                    ),
                  )
                else
                  Icon(
                    MediaUtils.iconForContentType(file.contentType),
                    size: 15,
                    color: accent,
                  ),
                const SizedBox(width: 6),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: NeoColors.onSurface,
                        ),
                      ),
                      Text(
                        MediaUtils.formatFileSize(file.sizeBytes),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9.5,
                          color: NeoColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => onRemoveAt(index),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: NeoColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
