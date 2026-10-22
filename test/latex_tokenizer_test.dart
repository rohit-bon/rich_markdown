import 'package:flutter_test/flutter_test.dart';
import 'package:rich_markdown/src/latex_tokenizer.dart';

void main() {
  group('LatexTokenizer', () {
    test('recognizes inline math', () {
      final tokens = LatexTokenizer.tokenize(r'Energy is $E = mc^2$.');

      expect(
        tokens.any(
          (t) => t.type == LatexTokenType.inlineMath && t.content == 'E = mc^2',
        ),
        isTrue,
      );
    });

    test('recognizes block math', () {
      final tokens = LatexTokenizer.tokenize(r'$$\frac{a}{b}$$');

      expect(tokens.single.type, LatexTokenType.blockMath);
      expect(tokens.single.content, r'\frac{a}{b}');
    });

    test('does not parse math inside fenced code', () {
      const input = '''
        ```dart
        final equation = r'\$x\$';
        ```
        ''';

      final tokens = LatexTokenizer.tokenize(input);

      expect(tokens, hasLength(1));
      expect(tokens.single.type, LatexTokenType.text);
      expect(tokens.single.content, input);
    });

    test('does not parse math inside inline code', () {
      final tokens = LatexTokenizer.tokenize(r'Use `$x$` in your example.');

      expect(tokens.any((t) => t.isMath), isFalse);
    });

    test('does not parse an unfinished equation', () {
      final tokens = LatexTokenizer.tokenize(r'Answer: $E = mc^2');

      expect(tokens, hasLength(1));
      expect(tokens.single.type, LatexTokenType.text);
    });

    test('preserves currency values', () {
      final tokens = LatexTokenizer.tokenize(r'The price is $100.');

      expect(tokens, hasLength(1));
      expect(tokens.single.content, r'The price is $100.');
    });

    test('recognizes parenthesized math', () {
      final tokens = LatexTokenizer.tokenize(r'Energy is \(E = mc^2\).');

      expect(
        tokens.any(
          (t) => t.type == LatexTokenType.inlineMath && t.content == 'E = mc^2',
        ),
        isTrue,
      );
    });

    test('recognizes bracketed block math', () {
      final tokens = LatexTokenizer.tokenize(r'\[\frac{a}{b}\]');

      expect(tokens.single.type, LatexTokenType.blockMath);
    });
  });
}
