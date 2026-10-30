import 'dart:convert';

import 'latex_tokenizer.dart';

/// Utility class for encoding, decoding, and processing LaTeX expressions into HTML tags.
class LatexProcessor {
  LatexProcessor._();

  /// Encodes a LaTeX [value] into a Base64-URL string.
  static String encode(String value) {
    return base64Url.encode(utf8.encode(value));
  }

  /// Decodes a Base64 string back into a LaTeX formula.
  ///
  /// Falls back gracefully to standard base64 or returns [value] if decoding fails.
  static String decode(String value) {
    final trimmed = value.trim();
    try {
      return utf8.decode(base64Url.decode(trimmed));
    } catch (_) {
      try {
        return utf8.decode(base64.decode(base64.normalize(trimmed)));
      } catch (_) {
        return value;
      }
    }
  }

  /// Processes [input] text by converting recognized LaTeX expressions into
  /// `<tex>` (inline) and `<texblock>` (display) HTML tags containing Base64-encoded LaTeX.
  ///
  /// Preserves fenced code blocks, inline code spans, currency amounts, and escaped delimiters.
  static String process(String input) {
    final tokens = LatexTokenizer.tokenize(input);
    final output = StringBuffer();

    for (final token in tokens) {
      switch (token.type) {
        case LatexTokenType.text:
          output.write(token.content);
        case LatexTokenType.inlineMath:
          output.write(_tag(token.content, block: false));
        case LatexTokenType.blockMath:
          output.write(_tag(token.content, block: true));
      }
    }

    return output.toString();
  }

  static String _tag(String tex, {required bool block}) {
    final encoded = encode(tex.trim());
    final tag = block ? 'texblock' : 'tex';
    return '<$tag>$encoded</$tag>';
  }
}
