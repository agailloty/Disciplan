import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

Future<bool> saveOrDownloadFileImpl({
  required Uint8List bytes,
  required String fileName,
  required String contentType,
}) async {
  final jsArray = <JSAny>[bytes.toJS].toJS;
  final blob = web.Blob(jsArray, web.BlobPropertyBag(type: contentType));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = fileName;
  anchor.style.display = 'none';
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  Future<void>.delayed(const Duration(seconds: 30), () {
    web.URL.revokeObjectURL(url);
  });
  return true;
}

Future<bool> openFileInNewTabImpl({
  required Uint8List bytes,
  required String fileName,
  required String contentType,
}) async {
  final jsArray = <JSAny>[bytes.toJS].toJS;
  final blob = web.Blob(jsArray, web.BlobPropertyBag(type: contentType));
  final url = web.URL.createObjectURL(blob);
  web.window.open(url, '_blank');
  Future<void>.delayed(const Duration(minutes: 2), () {
    web.URL.revokeObjectURL(url);
  });
  return true;
}

bool get isWebPlatformImpl => true;

