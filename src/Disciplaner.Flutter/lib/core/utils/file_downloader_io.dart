import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

Future<bool> saveOrDownloadFileImpl({
  required Uint8List bytes,
  required String fileName,
  required String contentType,
}) async {
  final outputUri = await FilePicker.saveFile(
    dialogTitle: 'Enregistrer $fileName',
    fileName: fileName,
    bytes: bytes,
    mimeType: contentType,
  );
  return outputUri != null;
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
