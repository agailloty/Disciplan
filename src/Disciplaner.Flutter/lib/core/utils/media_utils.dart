import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../app/theme/neo_colors.dart';

/// Represents an in-memory file selected by the user for upload.
class PickedMediaFile {
  final String name;
  final Uint8List bytes;
  final int sizeBytes;
  final String contentType;

  const PickedMediaFile({
    required this.name,
    required this.bytes,
    required this.sizeBytes,
    required this.contentType,
  });

  String get extension => MediaUtils.extractExtension(name);
  bool get isImage => MediaUtils.isImageContentType(contentType);
  bool get isPdf => MediaUtils.isPdfContentType(contentType);
  bool get isText => MediaUtils.isTextContentType(contentType);
}

/// Exception thrown when a selected file violates size or MIME type constraints.
class MediaValidationException implements Exception {
  final String message;
  const MediaValidationException(this.message);

  @override
  String toString() => message;
}

typedef MediaFilePickerOverride = Future<List<PickedMediaFile>> Function({
  required bool allowMultiple,
  required List<String> allowedExtensions,
});

/// Utilities for multimedia attachments, MIME resolution, validation, and formatting.
class MediaUtils {
  MediaUtils._();

  /// Maximum attachment size enforced by backend (50 MB).
  static const int maxAttachmentSizeBytes = 52428800;

  /// Maximum profile picture size enforced by backend (5 MB).
  static const int maxProfilePictureSizeBytes = 5242880;

  /// Allowed file extensions matching backend `FileStorageOptions.AllowedContentTypes`.
  static const List<String> allowedAttachmentExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'txt',
    'csv',
    'zip',
  ];

  /// Allowed image extensions for profile pictures.
  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];

  /// Exact mapping from lowercase extension to backend-accepted MIME type.
  static const Map<String, String> _extensionToMime = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'pdf': 'application/pdf',
    'doc': 'application/msword',
    'docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xls': 'application/vnd.ms-excel',
    'xlsx':
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'ppt': 'application/vnd.ms-powerpoint',
    'pptx':
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'txt': 'text/plain',
    'csv': 'text/csv',
    'zip': 'application/zip',
  };

  /// Allowed MIME types on the backend.
  static const Set<String> allowedContentTypes = {
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'text/plain',
    'text/csv',
    'application/zip',
    'application/x-zip-compressed',
  };

  /// Allowed image MIME types on the backend.
  static const Set<String> allowedImageContentTypes = {
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
  };

  /// Optional test override so widget tests can simulate picking files without native dialogs.
  static MediaFilePickerOverride? debugPickerOverride;

  /// Extracts the lowercase file extension without the leading dot.
  static String extractExtension(String fileName) {
    final trimmed = fileName.trim();
    final dotIndex = trimmed.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == trimmed.length - 1) return '';
    return trimmed.substring(dotIndex + 1).toLowerCase();
  }

  /// Resolves the canonical MIME type from [fileName] (or [fallback]).
  static String resolveMimeType(String fileName, {String? fallback}) {
    final ext = extractExtension(fileName);
    final byExt = _extensionToMime[ext];
    if (byExt != null) return byExt;
    if (fallback != null && fallback.isNotEmpty) {
      return fallback.toLowerCase();
    }
    return 'application/octet-stream';
  }

  static bool isImageContentType(String contentType) {
    return contentType.toLowerCase().startsWith('image/');
  }

  static bool isPdfContentType(String contentType) {
    return contentType.toLowerCase() == 'application/pdf';
  }

  static bool isTextContentType(String contentType) {
    final lower = contentType.toLowerCase();
    return lower == 'text/plain' || lower == 'text/csv';
  }

  static bool isSpreadsheetContentType(String contentType) {
    final lower = contentType.toLowerCase();
    return lower.contains('excel') ||
        lower.contains('spreadsheet') ||
        lower == 'text/csv';
  }

  static bool isWordContentType(String contentType) {
    final lower = contentType.toLowerCase();
    return lower.contains('msword') || lower.contains('wordprocessingml');
  }

  static bool isPresentationContentType(String contentType) {
    final lower = contentType.toLowerCase();
    return lower.contains('powerpoint') || lower.contains('presentationml');
  }

  static bool isArchiveContentType(String contentType) {
    final lower = contentType.toLowerCase();
    return lower.contains('zip');
  }

  /// Returns whether the file can be previewed inline inside the modal.
  static bool isPreviewable(String contentType) {
    return isImageContentType(contentType) ||
        isPdfContentType(contentType) ||
        isTextContentType(contentType);
  }

  /// Formats a byte size into a human-readable French string (`o`, `Ko`, `Mo`).
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes o';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} Ko';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} Mo';
  }

  /// Returns an appropriate Material icon for a given [contentType].
  static IconData iconForContentType(String contentType) {
    if (isImageContentType(contentType)) return Icons.image_outlined;
    if (isPdfContentType(contentType)) return Icons.picture_as_pdf_outlined;
    if (isSpreadsheetContentType(contentType)) return Icons.table_chart_outlined;
    if (isWordContentType(contentType)) return Icons.description_outlined;
    if (isPresentationContentType(contentType)) return Icons.slideshow_outlined;
    if (isTextContentType(contentType)) return Icons.article_outlined;
    if (isArchiveContentType(contentType)) return Icons.folder_zip_outlined;
    return Icons.insert_drive_file_outlined;
  }

  /// Returns a semantic accent color for a given [contentType].
  static Color colorForContentType(String contentType) {
    if (isImageContentType(contentType)) return NeoColors.primary;
    if (isPdfContentType(contentType)) return NeoColors.error;
    if (isSpreadsheetContentType(contentType)) return NeoColors.emerald;
    if (isWordContentType(contentType)) return const Color(0xFF38BDF8);
    if (isPresentationContentType(contentType)) return NeoColors.warning;
    if (isArchiveContentType(contentType)) return NeoColors.warning;
    return NeoColors.onSurfaceVariant;
  }

  /// Opens the platform file picker to choose one or more attachment files.
  /// Validates file size (max 50 MB) and allowed content types.
  static Future<List<PickedMediaFile>> pickAttachmentFiles({
    bool allowMultiple = true,
  }) async {
    final files = await _pickRawFiles(
      allowMultiple: allowMultiple,
      allowedExtensions: allowedAttachmentExtensions,
    );
    for (final file in files) {
      if (file.sizeBytes > maxAttachmentSizeBytes) {
        throw MediaValidationException(
          'Le fichier "${file.name}" dépasse la taille maximale autorisée (50 Mo).',
        );
      }
      if (!allowedContentTypes.contains(file.contentType.toLowerCase())) {
        throw MediaValidationException(
          'Le format du fichier "${file.name}" n\'est pas pris en charge.',
        );
      }
    }
    return files;
  }

  /// Opens the platform file picker to choose a single profile picture (max 5 MB, image only).
  static Future<PickedMediaFile?> pickProfilePicture() async {
    final files = await _pickRawFiles(
      allowMultiple: false,
      allowedExtensions: allowedImageExtensions,
    );
    if (files.isEmpty) return null;
    final file = files.first;
    if (file.sizeBytes > maxProfilePictureSizeBytes) {
      throw MediaValidationException(
        'L\'image "${file.name}" dépasse la taille maximale autorisée (5 Mo).',
      );
    }
    if (!allowedImageContentTypes.contains(file.contentType.toLowerCase())) {
      throw MediaValidationException(
        'Seuls les formats JPEG, PNG, GIF et WebP sont acceptés.',
      );
    }
    return file;
  }

  static Future<List<PickedMediaFile>> _pickRawFiles({
    required bool allowMultiple,
    required List<String> allowedExtensions,
  }) async {
    if (debugPickerOverride != null) {
      return debugPickerOverride!(
        allowMultiple: allowMultiple,
        allowedExtensions: allowedExtensions,
      );
    }

    final List<PlatformFile> platformFiles;
    if (allowMultiple) {
      platformFiles = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );
    } else {
      final single = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );
      platformFiles = single != null ? [single] : const [];
    }

    if (platformFiles.isEmpty) {
      return const [];
    }

    final picked = <PickedMediaFile>[];
    for (final platformFile in platformFiles) {
      final bytes = await platformFile.xFile.readAsBytes();
      final mimeType = resolveMimeType(platformFile.name);
      picked.add(
        PickedMediaFile(
          name: platformFile.name,
          bytes: bytes,
          sizeBytes: bytes.length,
          contentType: mimeType,
        ),
      );
    }
    return picked;
  }
}
