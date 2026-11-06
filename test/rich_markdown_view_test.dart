import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rich_markdown/rich_markdown.dart';

void main() {
  group('RichMarkdownView - Rendering', () {
    testWidgets('renders standard Markdown text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RichMarkdownView(
              data: '# Title\n\nThis is **bold** text.',
              type: ContentType.markdown,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RichMarkdownView), findsOneWidget);
    });

    testWidgets('renders Markdown with inline and block LaTeX math', (tester) async {
      const content = r'''
Formula: $E = mc^2$

$$
\frac{a}{b}
$$
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RichMarkdownView(
              data: content,
              type: ContentType.markdown,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RichMarkdownView), findsOneWidget);
      expect(find.byType(Math), findsWidgets);
    });

    testWidgets('renders ContentType.latex as block math', (tester) async {
      const formula = r'\int_0^1 x^2\,dx';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RichMarkdownView(
              data: formula,
              type: ContentType.latex,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RichMarkdownView), findsOneWidget);
      expect(find.byType(Math), findsOneWidget);
    });

    testWidgets('renders ContentType.html with embedded math', (tester) async {
      const htmlContent = r'<p>Math: $x^2$</p>';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RichMarkdownView(
              data: htmlContent,
              type: ContentType.html,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RichMarkdownView), findsOneWidget);
      expect(find.byType(Math), findsOneWidget);
    });

    testWidgets('gracefully handles malformed LaTeX with fallback widget', (tester) async {
      // Malformed LaTeX that flutter_math cannot parse
      const brokenContent = r'$\frac{broken$';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RichMarkdownView(
              data: brokenContent,
              type: ContentType.markdown,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // View renders without crashing
      expect(find.byType(RichMarkdownView), findsOneWidget);
    });

    testWidgets('uses custom mathErrorBuilder when LaTeX expression is malformed', (tester) async {
      const invalidLatex = r'$\unknownMacroWithSyntaxError{{{}$';
      var customErrorCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RichMarkdownView(
              data: invalidLatex,
              type: ContentType.markdown,
              mathErrorBuilder: (context, error, tex) {
                customErrorCalled = true;
                return Text('CustomError: $tex');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RichMarkdownView), findsOneWidget);
      expect(customErrorCalled, isTrue);
      expect(find.textContaining('CustomError:'), findsOneWidget);
    });

    testWidgets('handles simulated progressive streaming without crashes', (tester) async {
      final streamStates = [
        'The result is ',
        r'The result is $',
        r'The result is $x',
        r'The result is $x = 1$',
        r'The result is $x = 1$, and block is $$\frac{1}{2}$$',
      ];

      for (final text in streamStates) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RichMarkdownView(
                data: text,
                type: ContentType.markdown,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(RichMarkdownView), findsOneWidget);
      }
    });

    testWidgets('applies custom textStyle and link callbacks properly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RichMarkdownView(
              data: '[Click here](https://flutter.dev)',
              type: ContentType.markdown,
              textStyle: const TextStyle(fontSize: 18, color: Colors.blue),
              onLinkTap: (url) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RichMarkdownView), findsOneWidget);
    });
  });
}
