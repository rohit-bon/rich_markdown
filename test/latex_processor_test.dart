import 'package:flutter_test/flutter_test.dart';
import 'package:rich_markdown/rich_markdown.dart';

void main() {
  group('LatexProcessor - Encoding and Decoding', () {
    test('encodes and decodes standard LaTeX formula', () {
      const formula = r'\frac{a}{b}';
      final encoded = LatexProcessor.encode(formula);
      expect(LatexProcessor.decode(encoded), formula);
    });

    test('encodes and decodes complex LaTeX with special symbols and Unicode', () {
      const formula = r'\sum_{i=1}^n \sqrt{\alpha_i + \beta_i} \approx \pi \cdot \infty';
      final encoded = LatexProcessor.encode(formula);
      expect(LatexProcessor.decode(encoded), formula);
    });

    test('decodes standard base64 strings with padding safely', () {
      // Base64 for "x^2" is "eF4y"
      expect(LatexProcessor.decode('eF4y'), 'x^2');
    });

    test('decodes malformed strings gracefully without throwing', () {
      const invalid = '!!!not-a-valid-base64!!!';
      expect(LatexProcessor.decode(invalid), invalid);
    });
  });

  group('LatexProcessor - Processing', () {
    test(r'converts inline LaTeX delimiters $...$ to <tex>', () {
      final result = LatexProcessor.process(r'Energy is $E = mc^2$.');
      expect(result, contains('<tex>'));
      expect(result, contains('</tex>'));
      expect(result, contains(LatexProcessor.encode('E = mc^2')));
    });

    test(r'converts inline LaTeX delimiters \(...\) to <tex>', () {
      final result = LatexProcessor.process(r'Formula \(x = 1\) is true.');
      expect(result, contains('<tex>'));
      expect(result, contains('</tex>'));
      expect(result, contains(LatexProcessor.encode('x = 1')));
    });

    test(r'converts block LaTeX delimiters $$...$$ to <texblock>', () {
      final result = LatexProcessor.process(r'$$\frac{1}{2}$$');
      expect(result, contains('<texblock>'));
      expect(result, contains('</texblock>'));
      expect(result, contains(LatexProcessor.encode(r'\frac{1}{2}')));
    });

    test(r'converts block LaTeX delimiters \[...\] to <texblock>', () {
      final result = LatexProcessor.process(r'\[\int_0^\infty f(x)\,dx\]');
      expect(result, contains('<texblock>'));
      expect(result, contains('</texblock>'));
      expect(result, contains(LatexProcessor.encode(r'\int_0^\infty f(x)\,dx')));
    });

    test('leaves ordinary text unchanged', () {
      const input = 'Hello Flutter and Dart!';
      expect(LatexProcessor.process(input), input);
    });

    test('preserves code blocks without processing math tags inside', () {
      const input = '```dart\nfinal x = r"\$y\$";\n```';
      expect(LatexProcessor.process(input), input);
    });

    test(r'preserves currency amounts like $100 without converting to tex tags', () {
      const input = r'The item costs $100.';
      expect(LatexProcessor.process(input), input);
    });

    test('preserves escaped dollar signs without converting to tex tags', () {
      const input = r'Price is \$50.';
      expect(LatexProcessor.process(input), input);
    });
  });
}
