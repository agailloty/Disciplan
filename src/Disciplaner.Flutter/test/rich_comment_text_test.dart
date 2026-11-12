import 'package:disciplaner_flutter/core/widgets/rich_comment_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  TextSpan rootSpan(WidgetTester tester) {
    final selectable = tester.widget<SelectableText>(
      find.byType(SelectableText),
    );
    return selectable.textSpan as TextSpan;
  }

  testWidgets('preserves newlines in comment content', (tester) async {
    await tester.pumpWidget(
      wrap(const RichCommentText(content: 'Première ligne\nSeconde ligne')),
    );
    await tester.pumpAndSettle();

    final span = rootSpan(tester);
    expect(span.toPlainText(), 'Première ligne\nSeconde ligne');
  });

  testWidgets('detects http and www links with tap recognizers', (tester) async {
    await tester.pumpWidget(
      wrap(const RichCommentText(
        content: 'Voir https://exemple.fr/doc et www.exemple.org.',
      )),
    );
    await tester.pumpAndSettle();

    final span = rootSpan(tester);
    final children = span.children!.cast<TextSpan>();
    expect(span.toPlainText(), 'Voir https://exemple.fr/doc et www.exemple.org.');

    final links = children.where((c) => c.recognizer != null).toList();
    expect(links.length, 2);
    expect(links[0].toPlainText(), 'https://exemple.fr/doc');
    expect(links[0].style!.decoration, TextDecoration.underline);
    expect(links[1].toPlainText(), 'www.exemple.org');
  });

  testWidgets('trims punctuation glued to the end of a link', (tester) async {
    await tester.pumpWidget(
      wrap(const RichCommentText(content: 'Doc : www.exemple.org.')),
    );
    await tester.pumpAndSettle();

    final span = rootSpan(tester);
    final children = span.children!.cast<TextSpan>();
    // Le lien est rogné : la ponctuation finale reste un texte ordinaire.
    expect(children[0].toPlainText(), 'Doc : ');
    expect(children[0].recognizer, isNull);
    expect(children[1].toPlainText(), 'www.exemple.org');
    expect(children[1].recognizer, isNotNull);
    expect(children[2].toPlainText(), '.');
    expect(children[2].recognizer, isNull);
  });
}
