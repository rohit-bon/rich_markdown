import 'package:flutter_test/flutter_test.dart';
import 'package:rich_markdown/rich_markdown.dart';

void main() {
  group('Performance Benchmark', () {
    test('tokenizes 1,000 paragraphs containing Markdown and LaTeX rapidly', () {
      final buffer = StringBuffer();
      for (var i = 0; i < 1000; i++) {
        buffer.writeln(
          'Paragraph $i with inline math \$x_{$i} = \\alpha + \\beta\$ and currency \$100. '
          'Here is a code block: `final y = "\$z\$";` and block equation:\n'
          '\$\$\n\\int_0^1 x^$i\\,dx = \\frac{1}{${i + 1}}\n\$\$\n',
        );
      }
      final input = buffer.toString();

      final stopwatch = Stopwatch()..start();
      final tokens = LatexTokenizer.tokenize(input);
      stopwatch.stop();

      expect(tokens, isNotEmpty);
      expect(stopwatch.elapsedMilliseconds, lessThan(1000),
          reason: 'Tokenization of 1,000 mixed paragraphs took ${stopwatch.elapsedMilliseconds}ms');
    });

    test('MarkdownProcessor processes 100 mixed Markdown documents rapidly', () {
      const document = r'''
# Analysis of $f(x)$

We consider the function $f(x) = \sum_{i=1}^n x^i$.

```python
# Code block with dollar signs
price = "$100"
```

The estimated total cost is $250.00 while equation is:

$$
\lim_{x \to \infty} \frac{1}{x} = 0
$$

And inline reference \(a^2 + b^2 = c^2\).
''';

      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < 100; i++) {
        final html = MarkdownProcessor.process(document);
        expect(html, contains('<tex>'));
        expect(html, contains('<texblock>'));
      }
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(2000),
          reason: 'Processing 100 documents took ${stopwatch.elapsedMilliseconds}ms');
    });
  });
}

