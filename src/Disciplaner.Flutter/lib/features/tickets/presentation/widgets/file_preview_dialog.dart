import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/neo_colors.dart';
import '../../../../core/models/collaboration_models.dart';
import '../../../../core/utils/file_downloader.dart';
import '../../../../core/utils/media_utils.dart';
import '../ticket_providers.dart';

class FilePreviewDialog extends ConsumerStatefulWidget {
  final String attachmentId;
  final String fileName;
  final String? contentType;
  final int? fileSizeBytes;
  final String? uploadedByDisplayName;
  final DateTime? uploadedAt;

  const FilePreviewDialog({
    super.key,
    required this.attachmentId,
    required this.fileName,
    this.contentType,
    this.fileSizeBytes,
    this.uploadedByDisplayName,
    this.uploadedAt,
  });

  static Future<void> show(
    BuildContext context, {
    required AttachmentDto attachment,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => FilePreviewDialog(
        attachmentId: attachment.id,
        fileName: attachment.originalFileName,
        contentType: attachment.contentType,
        fileSizeBytes: attachment.fileSizeBytes,
        uploadedByDisplayName: attachment.uploadedByDisplayName,
        uploadedAt: attachment.uploadedAt,
      ),
    );
  }

  static Future<void> showById(
    BuildContext context, {
    required String attachmentId,
    required String fileName,
    String? contentType,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => FilePreviewDialog(
        attachmentId: attachmentId,
        fileName: fileName,
        contentType: contentType,
      ),
    );
  }

  @override
  ConsumerState<FilePreviewDialog> createState() => _FilePreviewDialogState();
}

class _FilePreviewDialogState extends ConsumerState<FilePreviewDialog> {
  final TransformationController _transformController =
      TransformationController();
  bool _isSaving = false;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  String _effectiveMimeType(String? downloadedMime) {
    final declared = widget.contentType;
    if (declared != null &&
        declared.isNotEmpty &&
        declared != 'application/octet-stream') {
      return declared;
    }
    if (downloadedMime != null &&
        downloadedMime.isNotEmpty &&
        downloadedMime != 'application/octet-stream') {
      return downloadedMime;
    }
    return MediaUtils.resolveMimeType(widget.fileName);
  }

  Future<void> _handleDownload(Uint8List bytes, String mimeType) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await FileDownloader.saveOrDownload(
        bytes: bytes,
        fileName: widget.fileName,
        contentType: mimeType,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Téléchargement de "${widget.fileName}" lancé.'),
            backgroundColor: NeoColors.surfaceContainerHigh,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du téléchargement : $e'),
            backgroundColor: NeoColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _handleOpenInNewTab(Uint8List bytes, String mimeType) async {
    try {
      await FileDownloader.openInNewTab(
        bytes: bytes,
        fileName: widget.fileName,
        contentType: mimeType,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible d\'ouvrir le fichier : $e'),
            backgroundColor: NeoColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final downloadAsync =
        ref.watch(attachmentDownloadProvider(widget.attachmentId));
    final screenSize = MediaQuery.sizeOf(context);
    final isMobile = screenSize.width < 640;

    return Dialog(
      backgroundColor: NeoColors.surfaceContainerLow,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 40,
        vertical: isMobile ? 16 : 32,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: NeoColors.borderSubtle),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 920,
          maxHeight: screenSize.height * 0.86,
        ),
        child: downloadAsync.when(
          loading: () => SizedBox(
            height: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(
                  mimeType: _effectiveMimeType(null),
                  bytes: null,
                ),
                const Divider(height: 1, color: NeoColors.borderWhisper),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: NeoColors.primary,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Chargement de l\'aperçu…',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: NeoColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          error: (error, _) => SizedBox(
            height: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(
                  mimeType: _effectiveMimeType(null),
                  bytes: null,
                ),
                const Divider(height: 1, color: NeoColors.borderWhisper),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 38,
                            color: NeoColors.error,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Impossible de charger le fichier : $error',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: NeoColors.error,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => ref.invalidate(
                              attachmentDownloadProvider(widget.attachmentId),
                            ),
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          data: (result) {
            final (bytes, downloadedMime) = result;
            final mimeType = _effectiveMimeType(downloadedMime);
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(mimeType: mimeType, bytes: bytes),
                const Divider(height: 1, color: NeoColors.borderWhisper),
                Flexible(
                  child: _buildBody(bytes: bytes, mimeType: mimeType),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader({
    required String mimeType,
    required Uint8List? bytes,
  }) {
    final sizeBytes = widget.fileSizeBytes ?? bytes?.length;
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    final metaParts = <String>[
      if (sizeBytes != null) MediaUtils.formatFileSize(sizeBytes),
      if (widget.uploadedByDisplayName != null &&
          widget.uploadedByDisplayName!.isNotEmpty)
        'par ${widget.uploadedByDisplayName}',
      if (widget.uploadedAt != null)
        dateFmt.format(widget.uploadedAt!.toLocal()),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: MediaUtils.colorForContentType(mimeType)
                  .withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              MediaUtils.iconForContentType(mimeType),
              size: 18,
              color: MediaUtils.colorForContentType(mimeType),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: NeoColors.onSurface,
                  ),
                ),
                if (metaParts.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    metaParts.join(' • '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: NeoColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (bytes != null) ...[
            if (FileDownloader.isWeb)
              IconButton(
                tooltip: 'Ouvrir dans un nouvel onglet',
                icon: const Icon(Icons.open_in_new, size: 18),
                color: NeoColors.onSurfaceVariant,
                onPressed: () => _handleOpenInNewTab(bytes, mimeType),
              ),
            IconButton(
              tooltip: 'Télécharger',
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_outlined, size: 19),
              color: NeoColors.primary,
              onPressed:
                  _isSaving ? null : () => _handleDownload(bytes, mimeType),
            ),
          ],
          IconButton(
            tooltip: 'Fermer',
            icon: const Icon(Icons.close, size: 19),
            color: NeoColors.onSurfaceVariant,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody({
    required Uint8List bytes,
    required String mimeType,
  }) {
    if (MediaUtils.isImageContentType(mimeType)) {
      return Stack(
        children: [
          Container(
            color: NeoColors.surfaceContainerLowest,
            constraints: const BoxConstraints(minHeight: 320, maxHeight: 640),
            width: double.infinity,
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Image.memory(
                    bytes,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => _buildFallbackCard(
                      bytes: bytes,
                      mimeType: mimeType,
                      subtitle: 'Impossible de décoder cette image.',
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              decoration: BoxDecoration(
                color: NeoColors.surfaceContainerHigh.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: NeoColors.borderSubtle),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Réinitialiser le zoom',
                    icon: const Icon(Icons.center_focus_strong, size: 16),
                    color: NeoColors.onSurfaceVariant,
                    onPressed: () {
                      _transformController.value = Matrix4.identity();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (MediaUtils.isTextContentType(mimeType)) {
      final decoded = utf8.decode(bytes, allowMalformed: true);
      return Container(
        color: NeoColors.surfaceContainerLowest,
        constraints: const BoxConstraints(minHeight: 260, maxHeight: 580),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: SelectableText(
            decoded.isEmpty ? '(Fichier vide)' : decoded,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              height: 1.5,
              color: NeoColors.onSurface,
            ),
          ),
        ),
      );
    }

    return _buildFallbackCard(
      bytes: bytes,
      mimeType: mimeType,
      subtitle: MediaUtils.isPdfContentType(mimeType)
          ? 'Document PDF prêt à être consulté ou téléchargé.'
          : 'L\'aperçu direct n\'est pas disponible pour ce type de fichier.',
    );
  }

  Widget _buildFallbackCard({
    required Uint8List bytes,
    required String mimeType,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      color: NeoColors.surfaceContainerLowest,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: MediaUtils.colorForContentType(mimeType)
                  .withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              MediaUtils.iconForContentType(mimeType),
              size: 34,
              color: MediaUtils.colorForContentType(mimeType),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.fileName,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: NeoColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: NeoColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              if (FileDownloader.isWeb)
                OutlinedButton.icon(
                  onPressed: () => _handleOpenInNewTab(bytes, mimeType),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Ouvrir dans un nouvel onglet'),
                ),
              FilledButton.icon(
                onPressed:
                    _isSaving ? null : () => _handleDownload(bytes, mimeType),
                style: FilledButton.styleFrom(
                  backgroundColor: NeoColors.primary,
                  foregroundColor: NeoColors.onPrimary,
                ),
                icon: const Icon(Icons.download_outlined, size: 17),
                label: const Text('Télécharger le fichier'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

