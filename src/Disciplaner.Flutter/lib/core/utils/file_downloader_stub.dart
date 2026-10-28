import 'dart:typed_data';

Future<bool> saveOrDownloadFileImpl({
  required Uint8List bytes,
  required String fileName,
  required String contentType,
}) async {
  throw UnsupportedError('Cannot save file without dart:io or package:web');
}

Future<bool> openFileInNewTabImpl({
  required Uint8List bytes,
  required String fileName,
  required String contentType,
}) async {
  return saveOrDownloadFileImpl(
    bytes: bytes,
    fileName: fileName,
    contentType: contentType,
  );
}

bool get isWebPlatformImpl => false;

