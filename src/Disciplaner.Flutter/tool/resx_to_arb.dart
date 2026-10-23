// Converts the Blazor .resx resource files into Flutter .arb files so both
// clients share the same localization keys and messages.
//
// Usage: dart run tool/resx_to_arb.dart
import 'dart:convert';
import 'dart:io';

const resxDir =
    '../Disciplaner.Web/Client/Resources';
const outputDir = 'lib/l10n';
const extraKeysPath = 'tool/flutter_extra_keys.json';

void main() {
  final fr = _parseResx('$resxDir/AppResources.resx');
  final en = _parseResx('$resxDir/AppResources.en.resx');

  final frKeys = fr.keys.toSet();
  final enKeys = en.keys.toSet();
  final missingInEn = frKeys.difference(enKeys).toList()..sort();
  final missingInFr = enKeys.difference(frKeys).toList()..sort();
  if (missingInEn.isNotEmpty || missingInFr.isNotEmpty) {
    stderr.writeln('Key mismatch between resx files:');
    stderr.writeln('  missing in en: $missingInEn');
    stderr.writeln('  missing in fr: $missingInFr');
    exitCode = 1;
  }

  final extras = _loadExtraKeys();

  _writeArb('fr', fr, extras);
  _writeArb('en', en, extras);
  stdout.writeln(
      'Wrote app_fr.arb (${fr.length + extras.length} keys) and app_en.arb');
}

/// Keys specific to the Flutter client (no Blazor counterpart).
///
/// Shape: { "key": { "fr": "...", "en": "...", "placeholders": { "n": "int" } } }
Map<String, dynamic> _loadExtraKeys() {
  final file = File(extraKeysPath);
  if (!file.existsSync()) return {};
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

/// Placeholder metadata per ARB key: placeholder index -> (name, type).
const placeholderSpecs = <String, List<(String, String)>>{
  'boardDeleteConfirm': [('name', 'String')],
  'boardColumnCount': [('count', 'int')],
  'projectTicketCount': [('count', 'int')],
  'projectSprintCount': [('count', 'int')],
  'projectDeleteConfirm': [('name', 'String')],
  'sprintSelectedCount': [('count', 'int')],
  'sprintTicketsMoved': [('count', 'int')],
  'sprintTicketCount': [('count', 'int')],
  'ticketCreatedOn': [('date', 'String')],
  'ticketUpdatedOn': [('date', 'String')],
  'ticketParent': [('parent', 'String')],
  'statusOrderLabel': [('order', 'int')],
  'colDeleteConfirm': [('name', 'String')],
  'homeWelcome': [('name', 'String')],
  'adminUsersHeadingCount': [('count', 'int')],
  'adminInvitationsHeading': [('count', 'int')],
  'timeMinutesAgo': [('count', 'int')],
  'timeHoursAgo': [('count', 'int')],
  'timeDaysAgo': [('count', 'int')],
  'labelCount': [('count', 'int')],
  'labelDeleteConfirm': [('name', 'String')],
  'labelItemCount': [('tickets', 'int'), ('boards', 'int')],
  'membersRemoveConfirm': [('name', 'String')],
  'cardDeleteConfirm': [('name', 'String')],
  'attachmentErrorUpload': [('error', 'String')],
  'attachmentErrorDownload': [('error', 'String')],
  'attachmentErrorOpen': [('error', 'String')],
  'attachmentErrorDelete': [('error', 'String')],
  'attachmentErrorLoad': [('error', 'String')],
};

/// Resx name (e.g. "Nav.MyTickets") -> ARB key (e.g. "navMyTickets").
String toArbKey(String resxName) {
  final segments = resxName.split('.');
  if (segments.length == 1) return segments[0].toLowerCase();
  final buffer = StringBuffer(segments[0].toLowerCase());
  for (final segment in segments.skip(1)) {
    final camel =
        segment.split(RegExp('[_-]')).map((s) => _capitalize(s)).join();
    buffer.write(camel);
  }
  return buffer.toString();
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String _unescapeXml(String value) => value
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&apos;', "'")
    .replaceAll('&#39;', "'")
    .replaceAll('&amp;', '&');

Map<String, String> _parseResx(String path) {
  final content = File(path).readAsStringSync();
  final regex = RegExp(r'<data name="([^"]+)"[^>]*>\s*<value>(.*?)</value>');
  final entries = <String, String>{};
  for (final match in regex.allMatches(content)) {
    final name = match.group(1)!;
    final value = _unescapeXml(match.group(2)!);
    entries[name] = value;
  }
  return entries;
}

Map<String, dynamic> _buildArb(
    String locale, Map<String, String> resx, Map<String, dynamic> extras) {
  final arb = <String, dynamic>{'@@locale': locale};
  final usedKeys = <String>{};
  for (final entry in resx.entries) {
    final key = toArbKey(entry.key);
    if (!usedKeys.add(key)) {
      throw StateError('ARB key collision: $key (from ${entry.key})');
    }
    arb[key] = _withPlaceholders(key, entry.value, locale, arb);
  }
  for (final entry in extras.entries) {
    final key = entry.key;
    final spec = entry.value as Map<String, dynamic>;
    if (!usedKeys.add(key)) {
      throw StateError('ARB key collision: $key (from flutter_extra_keys)');
    }
    final placeholders = spec['placeholders'] as Map<String, dynamic>?;
    // Extras use named placeholders directly ({name} syntax).
    var message = (spec[locale] ?? spec['fr']).toString();
    if (placeholders != null && locale == 'fr') {
      arb['@$key'] = {
        'placeholders': {
          for (final name in placeholders.keys)
            name: {'type': placeholders[name]}
        }
      };
    }
    arb[key] = message;
  }
  return arb;
}

/// Replaces resx positional placeholders ({0}, {1}) with the named
/// placeholders declared in [placeholderSpecs] and records metadata for the
/// template locale.
String _withPlaceholders(String key, String value, String locale,
    Map<String, dynamic> arb) {
  var message = value;
  final specs = placeholderSpecs[key];
  if (specs != null) {
    for (var i = 0; i < specs.length; i++) {
      message = message.replaceAll('{$i}', '{${specs[i].$1}}');
    }
    if (RegExp(r'\{\d\}').hasMatch(message)) {
      throw StateError('Unmapped placeholder in $key: $message');
    }
    if (locale == 'fr') {
      arb['@$key'] = {
        'placeholders': {
          for (final (name, type) in specs) name: {'type': type}
        }
      };
    }
  }
  return message;
}

void _writeArb(
    String locale, Map<String, String> resx, Map<String, dynamic> extras) {
  final arb = _buildArb(locale, resx, extras);
  final encoder = const JsonEncoder.withIndent('  ');
  final file = File('$outputDir/app_$locale.arb');
  file.createSync(recursive: true);
  file.writeAsStringSync('${encoder.convert(arb)}\n');
}
