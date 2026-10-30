import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import 'latex_processor.dart';
import 'markdown_processor.dart';

enum ContentType { markdown, latex, html }

/// A Flutter widget that renders Markdown, LaTeX, and HTML content with robust
/// math parsing, streaming resilience, and customizable styling.
class RichMarkdownView extends StatelessWidget {
  const RichMarkdownView({
    super.key,
    required this.data,
    this.type = ContentType.markdown,
    this.textStyle,
    this.onLinkTap,
    this.shrinkWrap = true,
    this.mathErrorBuilder,
  });

  /// The raw content string to render.
  final String data;

  /// The format of the content ([ContentType.markdown], [ContentType.latex], or [ContentType.html]).
  final ContentType type;

  /// Default text style applied to rendered text.
  final TextStyle? textStyle;

  /// Optional callback invoked when a hyperlink is tapped.
  final void Function(String? url)? onLinkTap;

  /// Whether the HTML view should shrink-wrap its contents.
  final bool shrinkWrap;

  /// Optional custom builder for displaying LaTeX syntax or parsing errors.
  /// If omitted, a red text fallback is shown.
  final Widget Function(BuildContext context, String error, String tex)?
      mathErrorBuilder;

  @override
  Widget build(BuildContext context) {
    final htmlData = switch (type) {
      ContentType.markdown => MarkdownProcessor.process(data),
      ContentType.html => MarkdownProcessor.processHtml(data),
      ContentType.latex =>
        '<texblock>${LatexProcessor.encode(data.trim())}</texblock>',
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
          builder: (extensionContext) => _buildMath(
            context,
            extensionContext.innerHtml,
            block: false,
          ),
        ),
        TagExtension(
          tagsToExtend: {'texblock'},
          builder: (extensionContext) => _buildMath(
            context,
            extensionContext.innerHtml,
            block: true,
          ),
        ),
      ],
    );
  }

  Widget _buildMath(BuildContext context, String encoded, {required bool block}) {
    final tex = LatexProcessor.decode(encoded);

    try {
      return Math.tex(
        tex,
        mathStyle: block ? MathStyle.display : MathStyle.text,
        textStyle: textStyle,
        onErrorFallback: (error) {
          if (mathErrorBuilder != null) {
            return mathErrorBuilder!(context, error.message, tex);
          }
          return Text(
            tex,
            style:
                textStyle?.copyWith(color: Colors.red) ??
                const TextStyle(color: Colors.red),
          );
        },
      );
    } catch (e) {
      if (mathErrorBuilder != null) {
        return mathErrorBuilder!(context, e.toString(), tex);
      }
      return Text(
        tex,
        style:
            textStyle?.copyWith(color: Colors.red) ??
            const TextStyle(color: Colors.red),
      );
    }
  }
}
