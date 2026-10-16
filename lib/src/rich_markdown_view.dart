import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;

import 'latex_processor.dart';

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
    final processed = LatexProcessor.process(data);

    final htmlData = switch (type) {
      ContentType.markdown => md.markdownToHtml(
        processed,
        extensionSet: md.ExtensionSet.gitHubWeb,
      ),
      ContentType.html => processed,
      ContentType.latex =>
        '<texblock>'
            '${LatexProcessor.encode(data)}'
            '</texblock>',
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
          builder: (extensionContext) {
            return _buildMath(extensionContext.innerHtml, block: false);
          },
        ),
        TagExtension(
          tagsToExtend: {'texblock'},
          builder: (extensionContext) {
            return _buildMath(extensionContext.innerHtml, block: true);
          },
        ),
      ],
    );
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
            'Invalid LaTeX: ${error.message}',
            style: const TextStyle(color: Colors.red),
          );
        },
      );
    } catch (error) {
      return Text(
        'Unable to render equation: $error',
        style: const TextStyle(color: Colors.red),
      );
    }
  }
}
