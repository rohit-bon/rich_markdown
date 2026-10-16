import 'package:flutter_test/flutter_test.dart';
import 'package:rich_markdown/src/latex_processor.dart';

void main() {
  group('LatexProcessor', () {
    test('encodes and decodes a formula', () {
      const formula = r'\frac{a}{b}';

      final encoded = LatexProcessor.encode(formula);

      expect(LatexProcessor.decode(encoded), formula);
    });

    test('converts inline LaTeX', () {
      final result = LatexProcessor.process(r'Energy is \(E = mc^2\)');

      expect(result, contains('<tex>'));
      expect(result, contains('</tex>'));
    });

    test('converts block LaTeX', () {
      final result = LatexProcessor.process(r'$$\frac{1}{2}$$');

      expect(result, contains('<texblock>'));
    });

    test('leaves ordinary text unchanged', () {
      const input = 'Hello Flutter';

      expect(LatexProcessor.process(input), input);
    });
  });
}
