// Audits lib/ for user-facing string literals that should be localized.
//
// Usage: dart run tool/l10n_audit.dart [path]
// Reports string literals that look like UI text (contain a space, a French
// accent, or two or more letters starting with an uppercase word).
import 'dart:io';

void main(List<String> args) {
  final root = args.isNotEmpty ? args.first : 'lib';
  final findings = <String>[];
  final dir = Directory(root);
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (entity.path.contains('l10n')) continue;
    final lines = entity.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trimLeft().startsWith('//')) continue;
      if (line.contains('import ') || line.contains('package:')) continue;
      for (final match in RegExp(r'''['"]([^'"]{2,})['"]''')
          .allMatches(line)) {
        final literal = match.group(1)!;
        if (_looksLocalized(literal) || _looksLikeUiText(literal)) {
          findings.add('${entity.path}:${i + 1}: $literal');
        }
      }
    }
  }
  stdout.writeln(findings.join('\n'));
  stdout.writeln('--- ${findings.length} findings');
}

final _storageAndProtocolTokens = RegExp(
  r'^(Bearer |api/|/api|/auth|/users|/projects|/tickets|/sprints|/boards'
  r'|/labels|/admin|/invitations|/settings|http|ws:|_key$|token|refresh|'
  r'application/|Content-|Accept|Authorization|disciplaner|dis_)[a-zA-Z0-9_/.-]*$',
);
final _frAccent = RegExp(r'[àâäçéèêëîïôöùûüœÀÂÄÇÉÈÊËÎÏÔÖÙÛÜŒ]');
final _uiLike = RegExp(r'^[A-ZÀÂÄÇÉÈÊËÎÏÔÖÙÛÜŒ][a-zà-ÿ]+( [a-zà-ÿA-Z0-9à-ÿ…]+)+$');

bool _looksLocalized(String literal) {
  if (_storageAndProtocolTokens.hasMatch(literal)) return false;
  return literal.contains(_frAccent);
}

bool _looksLikeUiText(String literal) {
  if (_storageAndProtocolTokens.hasMatch(literal)) return false;
  return _uiLike.hasMatch(literal);
}
