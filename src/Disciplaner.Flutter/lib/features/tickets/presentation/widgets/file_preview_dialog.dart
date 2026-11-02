import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdfx/pdfx.dart';
import '../../../../app/theme/neo_colors.dart';
import '../../../../app/theme/neo_spacing.dart';
import '../../../../core/models/collaboration_models.dart';
import '../../../../core/utils/file_downloader.dart';
import '../../../../core/utils/media_utils.dart';
import '../ticket_providers.dart';

/// Integrated multimedia viewer for tickets and comments.
///
/// Supports interactive previewing of:
/// - Images (JPG, PNG, GIF, WebP, etc.) with pinch-to-zoom, pan and double-tap zoom
/// - PDF documents with page navigation and pinch-to-zoom
/// - Plain text and source code (MD, JSON, CSV, XML, etc.) with line numbers and copy action
/// - Fallback info card with instant download for non-previewable formats (ZIP, DOCX, etc.)
///
/// Responsive: adapts automatically to mobile screens using a dedicated fullscreen layout.
class FilePreviewDialog extends ConsumerStatefulWidget {
  final String attachmentId;
  final String fileName;
  final String? contentType;
  final int? fileSizeBytes;
  final String? uploadedByDisplayName;
  final DateTime? uploadedAt;
  final Uint8List? initialBytes;

  const FilePreviewDialog({
    super.key,
    required this.attachmentId,
    required this.fileName,
    this.contentType,
    this.fileSizeBytes,
    this.uploadedByDisplayName,
    this.uploadedAt,
    this.initialBytes,
  });

  /// Opens the viewer for a backend [AttachmentDto].
  static Future<void> show(
    BuildContext context, {
    required AttachmentDto attachment,
  }) {
    return showDialog<void>(
      context: context,
      useSafeArea: false,
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

  /// Opens the viewer by attachment ID.
  static Future<void> showById(
    BuildContext context, {
    required String attachmentId,
    required String fileName,
    String? contentType,
    int? fileSizeBytes,
    String? uploadedByDisplayName,
    DateTime? uploadedAt,
  }) {
    return showDialog<void>(
      context: context,
      useSafeArea: false,
      builder: (_) => FilePreviewDialog(
        attachmentId: attachmentId,
        fileName: fileName,
        contentType: contentType,
        fileSizeBytes: fileSizeBytes,
        uploadedByDisplayName: uploadedByDisplayName,
        uploadedAt: uploadedAt,
      ),
    );
  }

  /// Opens the viewer directly with in-memory [bytes] (e.g. pending uploads or local files).
  static Future<void> showBytes(
    BuildContext context, {
    required Uint8List bytes,
    required String fileName,
    String? contentType,
    int? fileSizeBytes,
    String? uploadedByDisplayName,
    DateTime? uploadedAt,
  }) {
    return showDialog<void>(
      context: context,
      useSafeArea: false,
      builder: (_) => FilePreviewDialog(
        attachmentId: '',
        fileName: fileName,
        contentType: contentType,
        fileSizeBytes: fileSizeBytes ?? bytes.length,
        uploadedByDisplayName: uploadedByDisplayName,
        uploadedAt: uploadedAt,
        initialBytes: bytes,
      ),
    );
  }

  @override
  ConsumerState<FilePreviewDialog> createState() => _FilePreviewDialogState();
}

class _FilePreviewDialogState extends ConsumerState<FilePreviewDialog> {
  bool _isSaving = false;

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
    final screenSize = MediaQuery.sizeOf(context);
    final isMobile = screenSize.width < NeoSpacing.mobileBreakpoint;

    // Direct in-memory bytes provided
    if (widget.initialBytes != null) {
      final bytes = widget.initialBytes!;
      final mimeType = _effectiveMimeType(null);
      return _buildFrame(
        isMobile: isMobile,
        screenSize: screenSize,
        child: _buildLoadedContent(
          bytes: bytes,
          mimeType: mimeType,
          isMobile: isMobile,
        ),
      );
    }

    final downloadAsync =
        ref.watch(attachmentDownloadProvider(widget.attachmentId));

    return _buildFrame(
      isMobile: isMobile,
      screenSize: screenSize,
      child: downloadAsync.when(
        loading: () => _buildLoadingState(isMobile),
        error: (error, _) => _buildErrorState(error, isMobile),
        data: (result) {
          final (bytes, downloadedMime) = result;
          final mimeType = _effectiveMimeType(downloadedMime);
          return _buildLoadedContent(
            bytes: bytes,
            mimeType: mimeType,
            isMobile: isMobile,
          );
        },
      ),
    );
  }

  Widget _buildFrame({
    required bool isMobile,
    required Size screenSize,
    required Widget child,
  }) {
    if (isMobile) {
      return Dialog.fullscreen(
        backgroundColor: NeoColors.surface,
        child: SafeArea(
          child: Material(
            color: NeoColors.surface,
            child: child,
          ),
        ),
      );
    }

    return Dialog(
      backgroundColor: NeoColors.surfaceContainerLow,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: NeoColors.borderSubtle),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 980,
          maxHeight: screenSize.height * 0.90,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: child,
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isMobile) {
    return Column(
      mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
      children: [
        _buildHeader(
          mimeType: _effectiveMimeType(null),
          bytes: null,
          isMobile: isMobile,
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
                  'Chargement du document…',
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
    );
  }

  Widget _buildErrorState(Object error, bool isMobile) {
    return Column(
      mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
      children: [
        _buildHeader(
          mimeType: _effectiveMimeType(null),
          bytes: null,
          isMobile: isMobile,
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
                    size: 40,
                    color: NeoColors.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Impossible de charger le document : $error',
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
    );
  }

  Widget _buildLoadedContent({
    required Uint8List bytes,
    required String mimeType,
    required bool isMobile,
  }) {
    return Column(
      mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(
          mimeType: mimeType,
          bytes: bytes,
          isMobile: isMobile,
        ),
        const Divider(height: 1, color: NeoColors.borderWhisper),
        Expanded(
          child: _buildBody(
            bytes: bytes,
            mimeType: mimeType,
            isMobile: isMobile,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader({
    required String mimeType,
    required Uint8List? bytes,
    required bool isMobile,
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

    final accentColor = MediaUtils.colorForContentType(mimeType);

    return Container(
      color: NeoColors.surfaceContainerLow,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 10 : 12,
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 32 : 36,
            height: isMobile ? 32 : 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              MediaUtils.iconForContentType(mimeType),
              size: isMobile ? 16 : 18,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 13.5 : 14,
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
                      fontSize: 10.5,
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
                visualDensity: VisualDensity.compact,
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
              visualDensity: VisualDensity.compact,
              onPressed:
                  _isSaving ? null : () => _handleDownload(bytes, mimeType),
            ),
          ],
          IconButton(
            tooltip: 'Fermer',
            icon: const Icon(Icons.close, size: 19),
            color: NeoColors.onSurfaceVariant,
            visualDensity: VisualDensity.compact,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody({
    required Uint8List bytes,
    required String mimeType,
    required bool isMobile,
  }) {
    if (MediaUtils.isImageContentType(mimeType)) {
      return _ImageViewerWidget(
        bytes: bytes,
        fileName: widget.fileName,
        isMobile: isMobile,
      );
    }

    if (MediaUtils.isPdfContentType(mimeType)) {
      return _PdfViewerWidget(
        bytes: bytes,
        fileName: widget.fileName,
        isMobile: isMobile,
        onDownload: () => _handleDownload(bytes, mimeType),
      );
    }

    if (MediaUtils.isTextOrCode(mimeType, widget.fileName)) {
      return _TextViewerWidget(
        bytes: bytes,
        fileName: widget.fileName,
        isMobile: isMobile,
      );
    }

    return _buildFallbackCard(
      bytes: bytes,
      mimeType: mimeType,
      subtitle:
          'L\'aperçu direct n\'est pas disponible pour ce type de fichier.',
      isMobile: isMobile,
    );
  }

  Widget _buildFallbackCard({
    required Uint8List bytes,
    required String mimeType,
    required String subtitle,
    required bool isMobile,
  }) {
    final accentColor = MediaUtils.colorForContentType(mimeType);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                MediaUtils.iconForContentType(mimeType),
                size: 34,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 18),
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
            const SizedBox(height: 22),
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
      ),
    );
  }
}

/// Interactive Image viewer with pinch-to-zoom, pan, double-tap zoom and control dock.
class _ImageViewerWidget extends StatefulWidget {
  final Uint8List bytes;
  final String fileName;
  final bool isMobile;

  const _ImageViewerWidget({
    required this.bytes,
    required this.fileName,
    required this.isMobile,
  });

  @override
  State<_ImageViewerWidget> createState() => _ImageViewerWidgetState();
}

class _ImageViewerWidgetState extends State<_ImageViewerWidget> {
  final TransformationController _transformController =
      TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    setState(() {
      _transformController.value = Matrix4.identity();
    });
  }

  void _zoomIn() {
    setState(() {
      _transformController.value = _transformController.value.clone()
        ..scaleByDouble(1.35, 1.35, 1.35, 1.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _transformController.value = _transformController.value.clone()
        ..scaleByDouble(1 / 1.35, 1 / 1.35, 1 / 1.35, 1.0);
    });
  }

  void _handleDoubleTap() {
    setState(() {
      if (_transformController.value.isIdentity()) {
        _transformController.value =
            Matrix4.identity()..scaleByDouble(2.5, 2.5, 2.5, 1.0);
      } else {
        _resetZoom();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xFF0F1115),
          width: double.infinity,
          height: double.infinity,
          child: GestureDetector(
            onDoubleTap: _handleDoubleTap,
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.5,
              maxScale: 6.0,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.memory(
                    widget.bytes,
                    fit: BoxFit.contain,
                    errorBuilder: (_, error, _) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.broken_image_outlined,
                            size: 44,
                            color: NeoColors.muted,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Impossible de décoder cette image.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: NeoColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Floating zoom controls (dock at bottom-right)
        Positioned(
          right: 14,
          bottom: 14,
          child: Container(
            decoration: BoxDecoration(
              color: NeoColors.surfaceContainerHigh.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: NeoColors.borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Zoom arrière',
                  icon: const Icon(Icons.zoom_out, size: 18),
                  color: NeoColors.onSurface,
                  visualDensity: VisualDensity.compact,
                  onPressed: _zoomOut,
                ),
                IconButton(
                  tooltip: 'Réinitialiser le zoom',
                  icon: const Icon(Icons.center_focus_strong, size: 18),
                  color: NeoColors.onSurface,
                  visualDensity: VisualDensity.compact,
                  onPressed: _resetZoom,
                ),
                IconButton(
                  tooltip: 'Zoom avant',
                  icon: const Icon(Icons.zoom_in, size: 18),
                  color: NeoColors.onSurface,
                  visualDensity: VisualDensity.compact,
                  onPressed: _zoomIn,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Integrated PDF document viewer with pinch-to-zoom and page navigation.
class _PdfViewerWidget extends StatefulWidget {
  final Uint8List bytes;
  final String fileName;
  final bool isMobile;
  final VoidCallback? onDownload;

  const _PdfViewerWidget({
    required this.bytes,
    required this.fileName,
    required this.isMobile,
    this.onDownload,
  });

  @override
  State<_PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<_PdfViewerWidget> {
  PdfControllerPinch? _pdfController;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  int _pageCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final supported = await hasPdfSupport();
      if (!supported) {
        if (mounted) {
          setState(() {
            _errorMessage =
                'Le visualiseur interactif PDF n\'est pas disponible sur cette plateforme.';
            _isLoading = false;
          });
        }
        return;
      }

      final doc = await PdfDocument.openData(widget.bytes);
      if (!mounted) return;
      final controller = PdfControllerPinch(
        document: Future.value(doc),
        initialPage: 1,
      );
      setState(() {
        _pdfController = controller;
        _pageCount = doc.pagesCount;
        _isLoading = false;
      });
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
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_pdfController != null && _currentPage < _pageCount) {
      _pdfController!.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _previousPage() {
    if (_pdfController != null && _currentPage > 1) {
      _pdfController!.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 140,
                child: LinearProgressIndicator(
                  minHeight: 3,
                  color: NeoColors.primary,
                  backgroundColor: NeoColors.surfaceContainerHigh,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Préparation du visualiseur PDF…',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: NeoColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null || _pdfController == null) {
      // Graceful fallback if native PDF rendering engine isn't available or fails
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: NeoColors.error.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_outlined,
                  size: 34,
                  color: NeoColors.error,
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
                'Document PDF prêt à être consulté ou téléchargé.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: NeoColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              if (widget.onDownload != null)
                FilledButton.icon(
                  onPressed: widget.onDownload,
                  style: FilledButton.styleFrom(
                    backgroundColor: NeoColors.primary,
                    foregroundColor: NeoColors.onPrimary,
                  ),
                  icon: const Icon(Icons.download_outlined, size: 17),
                  label: const Text('Télécharger le PDF'),
                ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Container(
            color: const Color(0xFF1E2024),
            child: PdfViewPinch(
              controller: _pdfController!,
              onPageChanged: (page) {
                if (mounted) setState(() => _currentPage = page);
              },
              scrollDirection: Axis.vertical,
              padding: 12,
              backgroundDecoration: const BoxDecoration(
                color: Color(0xFF1E2024),
              ),
            ),
          ),
        ),
        // Floating bottom pagination dock
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            color: NeoColors.surfaceContainerLow,
            border: Border(
              top: BorderSide(color: NeoColors.borderWhisper),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Page précédente',
                icon: const Icon(Icons.chevron_left, size: 22),
                color: NeoColors.onSurface,
                onPressed: _currentPage > 1 ? _previousPage : null,
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: NeoColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Page $_currentPage / $_pageCount',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: NeoColors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Page suivante',
                icon: const Icon(Icons.chevron_right, size: 22),
                color: NeoColors.onSurface,
                onPressed: _currentPage < _pageCount ? _nextPage : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Plain text and source code viewer with line numbers and copy functionality.
class _TextViewerWidget extends StatelessWidget {
  final Uint8List bytes;
  final String fileName;
  final bool isMobile;

  const _TextViewerWidget({
    required this.bytes,
    required this.fileName,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final decoded = utf8.decode(bytes, allowMalformed: true);
    final lines = decoded.split('\n');
    final lineCount = lines.isEmpty ? 1 : lines.length;

    return Container(
      color: NeoColors.surfaceContainerLowest,
      width: double.infinity,
      child: Column(
        children: [
          // Toolbar with quick actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: const BoxDecoration(
              color: NeoColors.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(color: NeoColors.borderWhisper),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '$lineCount ligne${lineCount > 1 ? 's' : ''} • UTF-8',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: NeoColors.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: decoded));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contenu copié dans le presse-papier.'),
                        backgroundColor: NeoColors.surfaceContainerHigh,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 14),
                  label: const Text('Copier'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: NeoColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Line numbers gutter
                      Container(
                        padding: const EdgeInsets.only(right: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(color: NeoColors.borderWhisper),
                          ),
                        ),
                        child: Text(
                          List.generate(lineCount, (i) => '${i + 1}').join('\n'),
                          textAlign: TextAlign.right,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            height: 1.5,
                            color: NeoColors.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Text content
                      SelectableText(
                        decoded.isEmpty ? '(Fichier vide)' : decoded,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          height: 1.5,
                          color: NeoColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
