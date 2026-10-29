import 'dart:typed_data';
import 'file_downloader_stub.dart'
    if (dart.library.js_interop) 'file_downloader_web.dart'
    if (dart.library.io) 'file_downloader_io.dart';

/// Cross-platform utility for saving or opening downloaded binary files.
class FileDownloader {
  FileDownloader._();

  static bool get isWeb => isWebPlatformImpl;

  /// Saves/downloads [bytes] as [fileName] with [contentType].
  /// Returns `true` if the download was initiated or saved, `false` if cancelled by user.
  static Future<bool> saveOrDownload({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) {
    return saveOrDownloadFileImpl(
      bytes: bytes,
      fileName: fileName,
      contentType: contentType,
    );
  }

  /// Opens [bytes] in a new browser tab on Web, or prompts to save on native platforms.
  static Future<bool> openInNewTab({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) {
    return openFileInNewTabImpl(
      bytes: bytes,
      fileName: fileName,
      contentType: contentType,
    );
  }
}

