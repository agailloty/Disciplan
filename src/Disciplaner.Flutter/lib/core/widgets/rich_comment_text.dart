import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/neo_colors.dart';

/// Expression régulière de détection des liens dans un commentaire.
/// Reconnaît les URL http(s) et les domaines nus préfixés par `www.`.
final RegExp _linkRegExp = RegExp(
  '(?:https?://|www\\.)[^\\s<>"\']+',
  caseSensitive: false,
);

/// Ouvre une URL détectée dans un commentaire. Une URL dépourvue de schéma
/// (ex. `www.exemple.fr`) est préfixée par `https://`.
Future<void> openCommentLink(String rawUrl) async {
  final url = rawUrl.startsWith('http://') || rawUrl.startsWith('https://')
      ? rawUrl
      : 'https://$rawUrl';
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // Aucun gestionnaire disponible : on ignore silencieusement.
  }
}

/// Corps de commentaire riche : préserve les retours à la ligne et rend
/// les liens détectés cliquables.
class RichCommentText extends StatelessWidget {
  final String content;
  final TextStyle? style;

  const RichCommentText({super.key, required this.content, this.style});

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? DefaultTextStyle.of(context).style;
    return SelectableText.rich(
      TextSpan(
        style: baseStyle,
        children: _buildSpans(content, baseStyle),
      ),
    );
  }

  List<InlineSpan> _buildSpans(String text, TextStyle baseStyle) {
    const trailingPunctuation = '.,;:!?)\'"';
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in _linkRegExp.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      // Rognage de la ponctuation finale collée au lien (ex. la phrase
      // se termine par "…" juste après l'URL).
      var url = match.group(0)!;
      var end = match.end;
      while (url.length > 1 &&
          trailingPunctuation.contains(url[url.length - 1])) {
        url = url.substring(0, url.length - 1);
        end--;
      }
      spans.add(
        TextSpan(
          text: url,
          style: baseStyle.copyWith(
            color: NeoColors.primary,
            decoration: TextDecoration.underline,
            decorationColor: NeoColors.primary,
          ),
          recognizer: TapGestureRecognizer()..onTap = () => openCommentLink(url),
        ),
      );
      cursor = end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }
    return spans.isEmpty ? [TextSpan(text: '')] : spans;
  }
}
