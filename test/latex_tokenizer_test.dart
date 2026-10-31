import 'package:flutter_test/flutter_test.dart';
import 'package:rich_markdown/rich_markdown.dart';

void main() {
  group('LatexTokenizer - Core Delimiters', () {
    test(r'recognizes inline math with single dollar $...$', () {
      final tokens = LatexTokenizer.tokenize(r'Energy is $E = mc^2$.');

      expect(tokens, [
        const LatexToken(type: LatexTokenType.text, content: 'Energy is '),
        const LatexToken(type: LatexTokenType.inlineMath, content: 'E = mc^2'),
        const LatexToken(type: LatexTokenType.text, content: '.'),
      ]);
    });

    test(r'recognizes block math with double dollar $$...$$', () {
      final tokens = LatexTokenizer.tokenize(r'$$\frac{a}{b}$$');

      expect(tokens, [
        const LatexToken(
          type: LatexTokenType.blockMath,
          content: r'\frac{a}{b}',
        ),
      ]);
    });

    test(r'recognizes inline math with parenthesized \(...\)', () {
      final tokens = LatexTokenizer.tokenize(r'Formula: \(x^2 + y^2 = r^2\).');

      expect(tokens, [
        const LatexToken(type: LatexTokenType.text, content: 'Formula: '),
        const LatexToken(
          type: LatexTokenType.inlineMath,
          content: 'x^2 + y^2 = r^2',
        ),
        const LatexToken(type: LatexTokenType.text, content: '.'),
      ]);
    });

    test('recognizes parenthesized math with internal whitespace', () {
      final tokens = LatexTokenizer.tokenize(r'\( x + y \)');

      expect(tokens, [
        const LatexToken(type: LatexTokenType.inlineMath, content: ' x + y '),
      ]);
    });

    test(r'recognizes block math with bracketed \[...\]', () {
      final tokens = LatexTokenizer.tokenize(r'\[\int_0^1 x\,dx\]');

      expect(tokens, [
        const LatexToken(
          type: LatexTokenType.blockMath,
          content: r'\int_0^1 x\,dx',
        ),
      ]);
    });

    test('recognizes bracketed block math with internal whitespace', () {
      final tokens = LatexTokenizer.tokenize(r'\[ x^2 \]');

      expect(tokens, [
        const LatexToken(type: LatexTokenType.blockMath, content: ' x^2 '),
      ]);
    });
  });

  group('LatexTokenizer - Code Protection Edge Cases', () {
    test('does not parse math inside fenced code blocks with backticks', () {
      const input = r'''
```dart
final equation = r'$x^2$';
final block = '$$\frac{a}{b}$$';
```
''';

      final tokens = LatexTokenizer.tokenize(input);

      expect(tokens, hasLength(1));
      expect(tokens.single.type, LatexTokenType.text);
      expect(tokens.single.content, input);
    });

    test('does not parse math inside fenced code blocks with tildes', () {
      const input = r'''
~~~python
x = "$y = 2$"
~~~
''';

      final tokens = LatexTokenizer.tokenize(input);

      expect(tokens, hasLength(1));
      expect(tokens.single.type, LatexTokenType.text);
      expect(tokens.single.content, input);
    });

    test('does not parse math inside indented fenced code blocks (up to 3 spaces)', () {
      const input = r'''
   ```dart
   final x = '$y$';
   ```
''';

      final tokens = LatexTokenizer.tokenize(input);

      expect(tokens, hasLength(1));
      expect(tokens.single.type, LatexTokenType.text);
    });

    test('does not parse math inside inline code spans', () {
      final tokens = LatexTokenizer.tokenize(r'Use `$x$` and `$$y$$` in code.');

      expect(tokens.any((t) => t.isMath), isFalse);
      expect(tokens.single.content, r'Use `$x$` and `$$y$$` in code.');
    });

    test('does not parse math inside multi-backtick inline code spans', () {
      final tokens = LatexTokenizer.tokenize(r'Use `` `$x$` `` here.');

      expect(tokens.any((t) => t.isMath), isFalse);
    });

    test('does not parse math inside HTML <pre> and <code> blocks', () {
      const htmlInput = r'<pre>$x = 1$</pre> and <code>$$y$$</code>';
      final tokens = LatexTokenizer.tokenize(htmlInput);

      expect(tokens.any((t) => t.isMath), isFalse);
      expect(tokens.single.content, htmlInput);
    });
  });

  group('LatexTokenizer - Currency and Number Edge Cases', () {
    test(r'preserves standalone currency amounts like $100', () {
      final tokens = LatexTokenizer.tokenize(r'The price is $100.');

      expect(tokens, hasLength(1));
      expect(tokens.single.type, LatexTokenType.text);
      expect(tokens.single.content, r'The price is $100.');
    });

    test(r'preserves decimal currency amounts like $100.50', () {
      final tokens = LatexTokenizer.tokenize(r'Cost: $100.50 per item.');

      expect(tokens, hasLength(1));
      expect(tokens.single.content, r'Cost: $100.50 per item.');
    });

    test('preserves multiple currency amounts in the same sentence', () {
      final tokens = LatexTokenizer.tokenize(
        r'I paid $100 for the jacket and $50 for the shirt.',
      );

      expect(tokens.any((t) => t.isMath), isFalse);
    });

    test(r'preserves currency ranges like $10-$20', () {
      final tokens = LatexTokenizer.tokenize(r'Estimated budget: $10-$20.');

      expect(tokens.any((t) => t.isMath), isFalse);
    });

    test('preserves comma-separated currency list', () {
      final tokens = LatexTokenizer.tokenize(
        r'Tiers are $10, $20, and $30.',
      );

      expect(tokens.any((t) => t.isMath), isFalse);
    });

    test('correctly distinguishes currency and LaTeX in the same sentence', () {
      final tokens = LatexTokenizer.tokenize(
        r'The price is $100, while the formula is $x = y^2$.',
      );

      expect(tokens, [
        const LatexToken(
          type: LatexTokenType.text,
          content: r'The price is $100, while the formula is ',
        ),
        const LatexToken(type: LatexTokenType.inlineMath, content: 'x = y^2'),
        const LatexToken(type: LatexTokenType.text, content: '.'),
      ]);
    });

    test('parses pure math containing numbers properly', () {
      final tokens = LatexTokenizer.tokenize(r'Math: $1 + 2 = 3$.');

      expect(tokens, [
        const LatexToken(type: LatexTokenType.text, content: 'Math: '),
        const LatexToken(type: LatexTokenType.inlineMath, content: '1 + 2 = 3'),
        const LatexToken(type: LatexTokenType.text, content: '.'),
      ]);
    });

    test(r'parses single closed number equations like $100$', () {
      final tokens = LatexTokenizer.tokenize(r'$100$');

      expect(tokens, [
        const LatexToken(type: LatexTokenType.inlineMath, content: '100'),
      ]);
    });

    test(r'does not parse $ followed by space as math', () {
      final tokens = LatexTokenizer.tokenize(r'$ 100 $');

      expect(tokens.any((t) => t.isMath), isFalse);
    });
  });

  group('LatexTokenizer - Escaped Delimiters', () {
    test(r'does not treat escaped \$ as math delimiter', () {
      final tokens = LatexTokenizer.tokenize(r'Cost is \$100 exactly.');

      expect(tokens.any((t) => t.isMath), isFalse);
      expect(tokens.single.content, r'Cost is \$100 exactly.');
    });

    test(r'does not treat escaped \$x$ as equation', () {
      final tokens = LatexTokenizer.tokenize(r'Escaped: \$x$.');

      expect(tokens.any((t) => t.isMath), isFalse);
    });

    test(r'handles unescaped dollar preceded by escaped backslash (\\$x$)', () {
      final tokens = LatexTokenizer.tokenize(r'\\$x$');

      expect(tokens, [
        const LatexToken(type: LatexTokenType.text, content: r'\\'),
        const LatexToken(type: LatexTokenType.inlineMath, content: 'x'),
      ]);
    });

    test(r'does not treat escaped \\(x\\) as equation', () {
      final tokens = LatexTokenizer.tokenize(r'\\(x\\)');

      expect(tokens.any((t) => t.isMath), isFalse);
    });

    test(r'handles escaped dollar sign inside equation ($x = \$5$)', () {
      final tokens = LatexTokenizer.tokenize(r'$x = \$5$');

      expect(tokens, [
        const LatexToken(type: LatexTokenType.inlineMath, content: r'x = \$5'),
      ]);
    });
  });

  group('LatexTokenizer - Streaming and Incomplete Expressions', () {
    test('unclosed single dollar does not crash and remains text', () {
      final tokens = LatexTokenizer.tokenize(r'Answer: $E = mc^2');

      expect(tokens, [
        const LatexToken(
          type: LatexTokenType.text,
          content: r'Answer: $E = mc^2',
        ),
      ]);
    });

    test('unclosed block dollar does not crash and remains text', () {
      final tokens = LatexTokenizer.tokenize(r'Answer: $$\frac{1}{2}');

      expect(tokens, [
        const LatexToken(
          type: LatexTokenType.text,
          content: r'Answer: $$\frac{1}{2}',
        ),
      ]);
    });

    test(r'unclosed \( does not crash and remains text', () {
      final tokens = LatexTokenizer.tokenize(r'Formula: \(x^2');

      expect(tokens, [
        const LatexToken(
          type: LatexTokenType.text,
          content: r'Formula: \(x^2',
        ),
      ]);
    });

    test(r'unclosed \[ does not crash and remains text', () {
      final tokens = LatexTokenizer.tokenize(r'Formula: \[\frac{a}{b}');

      expect(tokens, [
        const LatexToken(
          type: LatexTokenType.text,
          content: r'Formula: \[\frac{a}{b}',
        ),
      ]);
    });

    test('unclosed fenced code block remains text during streaming', () {
      const streamChunk = '```dart\nfinal x = "\$y\$";';
      final tokens = LatexTokenizer.tokenize(streamChunk);

      expect(tokens.any((t) => t.isMath), isFalse);
      expect(tokens.single.content, streamChunk);
    });

    test('handles progressive streaming steps seamlessly', () {
      final chunks = [
        'The formula is ',
        r'The formula is $',
        r'The formula is $x',
        r'The formula is $x + ',
        r'The formula is $x + y',
        r'The formula is $x + y$',
        r'The formula is $x + y$, and next is $$',
        r'The formula is $x + y$, and next is $$\frac{1}{2}',
        r'The formula is $x + y$, and next is $$\frac{1}{2}$$',
      ];

      for (var i = 0; i < chunks.length; i++) {
        final tokens = LatexTokenizer.tokenize(chunks[i]);
        expect(tokens, isNotEmpty);

        if (i < 5) {
          // Before closing the inline equation, all should be text.
          expect(tokens.any((t) => t.isMath), isFalse);
        } else if (i >= 5 && i < 8) {
          // Inline equation is closed, block equation is incomplete.
          expect(tokens.where((t) => t.isMath), hasLength(1));
          expect(tokens[1].content, 'x + y');
        } else {
          // Both equations are completed.
          expect(tokens.where((t) => t.isMath), hasLength(2));
          expect(tokens[1].content, 'x + y');
          expect(tokens[3].content, r'\frac{1}{2}');
        }
      }
    });
  });

  group('LatexTokenizer - Multiple Equations & Multiline', () {
    test('parses multiple equations in the same paragraph', () {
      final tokens = LatexTokenizer.tokenize(r'Given $x = 1$, $y = 2$, and $z = 3$.');

      expect(tokens, [
        const LatexToken(type: LatexTokenType.text, content: 'Given '),
        const LatexToken(type: LatexTokenType.inlineMath, content: 'x = 1'),
        const LatexToken(type: LatexTokenType.text, content: ', '),
        const LatexToken(type: LatexTokenType.inlineMath, content: 'y = 2'),
        const LatexToken(type: LatexTokenType.text, content: ', and '),
        const LatexToken(type: LatexTokenType.inlineMath, content: 'z = 3'),
        const LatexToken(type: LatexTokenType.text, content: '.'),
      ]);
    });

    test('parses mixed delimiter types in the same text', () {
      final tokens = LatexTokenizer.tokenize(
        r'Inline $a$, then \(b\), then block $$c$$ and \[d\].',
      );

      final mathTokens = tokens.where((t) => t.isMath).toList();
      expect(mathTokens, hasLength(4));
      expect(mathTokens[0].type, LatexTokenType.inlineMath);
      expect(mathTokens[0].content, 'a');
      expect(mathTokens[1].type, LatexTokenType.inlineMath);
      expect(mathTokens[1].content, 'b');
      expect(mathTokens[2].type, LatexTokenType.blockMath);
      expect(mathTokens[2].content, 'c');
      expect(mathTokens[3].type, LatexTokenType.blockMath);
      expect(mathTokens[3].content, 'd');
    });

    test(r'parses multiline block math with $$', () {
      const input = '''
\$\$
\\int_0^1 x^2\\,dx = \\frac{1}{3}
\$\$
''';

      final tokens = LatexTokenizer.tokenize(input);

      expect(tokens.where((t) => t.type == LatexTokenType.blockMath), hasLength(1));
      expect(
        tokens.firstWhere((t) => t.type == LatexTokenType.blockMath).content.trim(),
        r'\int_0^1 x^2\,dx = \frac{1}{3}',
      );
    });

    test(r'parses multiline block math with \[...\]', () {
      const input = '''
\\[
\\begin{aligned}
x &= 1 \\\\
y &= 2
\\end{aligned}
\\]
''';

      final tokens = LatexTokenizer.tokenize(input);

      expect(tokens.where((t) => t.type == LatexTokenType.blockMath), hasLength(1));
      expect(
        tokens.firstWhere((t) => t.type == LatexTokenType.blockMath).content.trim(),
        contains(r'x &= 1'),
      );
    });

    test('inline math does not span across newlines', () {
      const input = 'This is \$x\n+ y\$ invalid.';
      final tokens = LatexTokenizer.tokenize(input);

      expect(tokens.any((t) => t.isMath), isFalse);
    });
  });

  group('LatexTokenizer - Edge Cases and Models', () {
    test('handles empty input gracefully', () {
      expect(LatexTokenizer.tokenize(''), isEmpty);
    });

    test('handles empty equation delimiters as text', () {
      expect(LatexTokenizer.tokenize(r'$$$$').any((t) => t.isMath), isFalse);
      expect(LatexTokenizer.tokenize(r'\(\)').any((t) => t.isMath), isFalse);
      expect(LatexTokenizer.tokenize(r'\[\]').any((t) => t.isMath), isFalse);
    });

    test('handles whitespace-only equation delimiters as text', () {
      expect(LatexTokenizer.tokenize(r'$$   $$').any((t) => t.isMath), isFalse);
    });

    test('LatexToken value equality and hashCode work correctly', () {
      const token1 = LatexToken(type: LatexTokenType.inlineMath, content: 'x');
      const token2 = LatexToken(type: LatexTokenType.inlineMath, content: 'x');
      const token3 = LatexToken(type: LatexTokenType.blockMath, content: 'x');

      expect(token1, equals(token2));
      expect(token1.hashCode, equals(token2.hashCode));
      expect(token1, isNot(equals(token3)));
      expect(token1.isMath, isTrue);
      expect(token1.toString(), contains('inlineMath'));
    });
  });
}
