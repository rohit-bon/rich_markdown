import 'package:flutter_test/flutter_test.dart';
import 'package:rich_markdown/rich_markdown.dart';

void main() {
  group('MarkdownProcessor - Math Preservation', () {
    test('preserves inline math without mangling underscores as italics', () {
      final html = MarkdownProcessor.process(r'Values: $a_1 + b_2 = c_3$.');

      expect(html, contains('<tex>'));
      expect(html, contains('</tex>'));
      expect(html, isNot(contains('<em>')));
      expect(html, contains(LatexProcessor.encode('a_1 + b_2 = c_3')));
    });

    test('preserves inline math without mangling asterisks as bold or italics', () {
      final html = MarkdownProcessor.process(r'Product: $a * b * c$.');

      expect(html, contains('<tex>'));
      expect(html, contains('</tex>'));
      expect(html, isNot(contains('<em>')));
      expect(html, isNot(contains('<strong>')));
      expect(html, contains(LatexProcessor.encode('a * b * c')));
    });

    test(r'preserves block math with $$...$$ in markdown', () {
      final html = MarkdownProcessor.process(r'$$\frac{a}{b}$$');

      expect(html, contains('<texblock>'));
      expect(html, contains('</texblock>'));
      expect(html, contains(LatexProcessor.encode(r'\frac{a}{b}')));
    });

    test(r'preserves parenthesized and bracketed LaTeX in markdown', () {
      const input = r'Inline \(x^2\) and block \[\int x\,dx\].';
      final html = MarkdownProcessor.process(input);

      expect(html, contains('<tex>'));
      expect(html, contains('<texblock>'));
      expect(html, contains(LatexProcessor.encode('x^2')));
      expect(html, contains(LatexProcessor.encode(r'\int x\,dx')));
    });

    test('renders markdown elements (headings, lists, blockquotes) with embedded math', () {
      const markdown = r'''
# Heading with $E = mc^2$

> Quote with $\alpha + \beta$

- Item 1: $\frac{1}{2}$
- Item 2: text
''';

      final html = MarkdownProcessor.process(markdown);

      expect(html, contains('Heading with <tex>'));
      expect(html, contains('<blockquote>'));
      expect(html, contains('<p>Quote with <tex>'));
      expect(html, contains('<ul>'));
      expect(html, contains('<li>Item 1: <tex>'));
    });
  });

  group('MarkdownProcessor - Code and Escaping', () {
    test('preserves fenced code blocks with math-like text without converting to tex tags', () {
      const markdown = r'''
```python
def calc():
    return "$x^2$"
```
''';

      final html = MarkdownProcessor.process(markdown);

      expect(html, contains('<pre><code'));
      expect(html, contains(r'$x^2$'));
      expect(html, isNot(contains('<tex>')));
    });

    test('preserves inline code with math-like text without converting to tex tags', () {
      final html = MarkdownProcessor.process(r'Use `$x$` in your program.');

      expect(html, contains(r'<code>$x$</code>'));
      expect(html, isNot(contains('<tex>')));
    });

    test(r'preserves currency amounts like $100 as literal text', () {
      final html = MarkdownProcessor.process(r'The price is $100 and tax is $10.');

      expect(html, isNot(contains('<tex>')));
      expect(html, contains(r'$100'));
      expect(html, contains(r'$10'));
    });

    test('preserves escaped dollar signs as literal currency', () {
      final html = MarkdownProcessor.process(r'Cost is \$50.');

      expect(html, isNot(contains('<tex>')));
      expect(html, contains('50'));
    });
  });

  group('MarkdownProcessor - Streaming and Incomplete Input', () {
    test('unclosed math expressions do not crash and remain plain text in HTML', () {
      final html = MarkdownProcessor.process(r'Calculation: $x + y');

      expect(html, isNot(contains('<tex>')));
      expect(html, contains(r'$x + y'));
    });

    test('unclosed block math during streaming remains plain text', () {
      final html = MarkdownProcessor.process(r'Block: $$\frac{1}{2}');

      expect(html, isNot(contains('<texblock>')));
      expect(html, contains(r'$$\frac{1}{2}'));
    });

    test('handles empty string gracefully', () {
      expect(MarkdownProcessor.process(''), '');
    });
  });

  group('MarkdownProcessor - HTML Content Processing', () {
    test('processHtml converts inline and block math within HTML', () {
      const htmlInput = r'<p>Formula $x = 1$ and $$\frac{a}{b}$$</p>';
      final processed = MarkdownProcessor.processHtml(htmlInput);

      expect(processed, contains('<tex>'));
      expect(processed, contains('<texblock>'));
      expect(processed, contains(LatexProcessor.encode('x = 1')));
      expect(processed, contains(LatexProcessor.encode(r'\frac{a}{b}')));
    });

    test('processHtml preserves <pre> and <code> blocks in HTML', () {
      const htmlInput = r'<pre>$x = 1$</pre><p>$y = 2$</p>';
      final processed = MarkdownProcessor.processHtml(htmlInput);

      expect(processed, contains(r'<pre>$x = 1$</pre>'));
      expect(processed, contains('<p><tex>'));
    });

    test('processHtml handles empty string', () {
      expect(MarkdownProcessor.processHtml(''), '');
    });
  });
}
