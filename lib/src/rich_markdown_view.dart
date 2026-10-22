import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;

import 'latex_processor.dart';
import 'latex_tokenizer.dart';

enum ContentType { markdown, latex, html }

class RichMarkdownView extends StatelessWidget {
  const RichMarkdownView({
    super.key,
    required this.data,
    this.type = ContentType.markdown,
    this.textStyle,
    this.onLinkTap,
    this.shrinkWrap = true,
  });

  final String data;
  final ContentType type;
  final TextStyle? textStyle;
  final void Function(String? url)? onLinkTap;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final htmlData = switch (type) {
      ContentType.markdown => _markdownToHtml(data),
      ContentType.html => _htmlWithMath(data),
      ContentType.latex =>
        '<texblock>${LatexProcessor.encode(data)}</texblock>',
    };

    return Html(
      data: htmlData,
      shrinkWrap: shrinkWrap,
      onLinkTap: (url, attributes, element) {
        onLinkTap?.call(url);
      },
      style: {
        'body': Style(
          margin: Margins.zero,
          fontSize: FontSize(textStyle?.fontSize ?? 16),
          color: textStyle?.color,
          fontFamily: textStyle?.fontFamily,
        ),
        'p': Style(lineHeight: const LineHeight(1.5)),
        'pre': Style(
          padding: HtmlPaddings.all(12),
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest,
          whiteSpace: WhiteSpace.pre,
        ),
      },
      extensions: [
        TagExtension(
          tagsToExtend: {'tex'},
          builder: (extensionContext) =>
              _buildMath(extensionContext.innerHtml, block: false),
        ),
        TagExtension(
          tagsToExtend: {'texblock'},
          builder: (extensionContext) =>
              _buildMath(extensionContext.innerHtml, block: true),
        ),
      ],
    );
  }

  String _markdownToHtml(String source) {
    final protectedSource = _protectMath(source);

    final converted = md.markdownToHtml(
      protectedSource.content,
      extensionSet: md.ExtensionSet.gitHubWeb,
    );

    return _restoreMath(converted, protectedSource.mathTags);
  }

  String _htmlWithMath(String source) {
    final protectedSource = _protectMath(source);
    return _restoreMath(protectedSource.content, protectedSource.mathTags);
  }

  _ProtectedMath _protectMath(String source) {
    final tokens = LatexTokenizer.tokenize(source);
    final output = StringBuffer();
    final mathTags = <String, String>{};

    var index = 0;

    for (final token in tokens) {
      if (!token.isMath) {
        output.write(token.content);
        continue;
      }

      final placeholder = 'RICHMATHPLACEHOLDER${index}END';
      final tag = token.type == LatexTokenType.blockMath ? 'texblock' : 'tex';

      mathTags[placeholder] =
          '<$tag>${LatexProcessor.encode(token.content)}</$tag>';

      output.write(placeholder);
      index++;
    }

    return _ProtectedMath(output.toString(), mathTags);
  }

  String _restoreMath(String html, Map<String, String> mathTags) {
    var result = html;

    for (final entry in mathTags.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }

    return result;
  }

  Widget _buildMath(String encoded, {required bool block}) {
    try {
      final tex = LatexProcessor.decode(encoded.trim());

      return Math.tex(
        tex,
        mathStyle: block ? MathStyle.display : MathStyle.text,
        textStyle: textStyle,
        onErrorFallback: (error) {
          return Text(
            tex,
            style:
                textStyle?.copyWith(color: Colors.red) ??
                const TextStyle(color: Colors.red),
          );
        },
      );
    } catch (_) {
      return Text(
        encoded,
        style:
            textStyle?.copyWith(color: Colors.red) ??
            const TextStyle(color: Colors.red),
      );
    }
  }
}

class _ProtectedMath {
  const _ProtectedMath(this.content, this.mathTags);

  final String content;
  final Map<String, String> mathTags;
}
