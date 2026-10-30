import 'package:markdown/markdown.dart' as md;

import 'latex_processor.dart';
import 'latex_tokenizer.dart';

/// Processor that converts Markdown or HTML to HTML while preserving LaTeX expressions.
class MarkdownProcessor {
  MarkdownProcessor._();

  /// Converts [markdown] to HTML while safely preserving all inline and block LaTeX equations.
  ///
  /// Mathematical expressions are shielded from Markdown parsing (preventing underscores,
  /// asterisks, and delimiters from being misinterpreted as Markdown formatting) and then
  /// restored as `<tex>` and `<texblock>` custom HTML tags with Base64-encoded LaTeX content.
  static String process(
    String markdown, {
    md.ExtensionSet? extensionSet,
  }) {
    if (markdown.isEmpty) return '';

    final protected = _protectMath(markdown);

    final converted = md.markdownToHtml(
      protected.content,
      extensionSet: extensionSet ?? md.ExtensionSet.gitHubWeb,
    );

    return _restoreMath(converted, protected.mathTags);
  }

  /// Processes raw [html] content, recognizing and converting any inline or block
  /// LaTeX expressions into `<tex>` and `<texblock>` tags while leaving existing
  /// HTML structure, `<pre>`, and `<code>` blocks intact.
  static String processHtml(String html) {
    if (html.isEmpty) return '';
    return LatexProcessor.process(html);
  }

  static _ProtectedMath _protectMath(String source) {
    final tokens = LatexTokenizer.tokenize(source);
    final output = StringBuffer();
    final mathTags = <String, String>{};

    final salt = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    var index = 0;

    for (final token in tokens) {
      if (!token.isMath) {
        output.write(token.content);
        continue;
      }

      final placeholder = 'RMATH${salt}P${index}END';
      final tag = token.type == LatexTokenType.blockMath ? 'texblock' : 'tex';

      mathTags[placeholder] =
          '<$tag>${LatexProcessor.encode(token.content.trim())}</$tag>';

      output.write(placeholder);
      index++;
    }

    return _ProtectedMath(output.toString(), mathTags);
  }

  static String _restoreMath(String html, Map<String, String> mathTags) {
    if (mathTags.isEmpty) return html;

    var result = html;
    for (final entry in mathTags.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }

    return result;
  }
}

class _ProtectedMath {
  const _ProtectedMath(this.content, this.mathTags);

  final String content;
  final Map<String, String> mathTags;
}
