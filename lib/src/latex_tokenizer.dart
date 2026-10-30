import 'models/latex_token.dart';

export 'models/latex_token.dart';

/// A robust tokenizer that parses text containing inline and block LaTeX expressions
/// while preserving Markdown fenced code blocks, inline code, HTML code tags,
/// currency values, and escaped delimiters.
class LatexTokenizer {
  LatexTokenizer._();

  /// Tokenizes [source] into a list of [LatexToken]s.
  ///
  /// This method is streaming-safe: incomplete expressions remain as text tokens
  /// without throwing exceptions.
  static List<LatexToken> tokenize(String source) {
    if (source.isEmpty) {
      return const [];
    }

    final tokens = <LatexToken>[];
    final text = StringBuffer();

    void flushText() {
      if (text.isNotEmpty) {
        tokens.add(
          LatexToken(type: LatexTokenType.text, content: text.toString()),
        );
        text.clear();
      }
    }

    var i = 0;

    while (i < source.length) {
      // 1. Preserve fenced Markdown code blocks (``` or ~~~).
      final fenceEnd = _fencedCodeEnd(source, i);
      if (fenceEnd != null) {
        text.write(source.substring(i, fenceEnd));
        i = fenceEnd;
        continue;
      }

      // 2. Preserve inline Markdown code spans (`...`).
      final codeEnd = _inlineCodeEnd(source, i);
      if (codeEnd != null) {
        text.write(source.substring(i, codeEnd));
        i = codeEnd;
        continue;
      }

      // 3. Preserve HTML code blocks (<pre>...</pre> and <code>...</code>).
      final htmlCodeEnd = _htmlCodeEnd(source, i);
      if (htmlCodeEnd != null) {
        text.write(source.substring(i, htmlCodeEnd));
        i = htmlCodeEnd;
        continue;
      }

      // 4. Handle escaped delimiters (e.g. \$).
      if (source[i] == r'\' && i + 1 < source.length) {
        final nextChar = source[i + 1];
        if (nextChar == r'$') {
          // Check if this backslash is itself escaped.
          if (!_isEscaped(source, i)) {
            // Literal escaped dollar sign: \$
            text.write(r'\$');
            i += 2;
            continue;
          }
        }
      }

      // 5. Look for LaTeX equations ($...$, $$...$$, \(...\), \[...\]).
      final match = _findMath(source, i);

      if (match == null) {
        text.write(source[i]);
        i++;
        continue;
      }

      flushText();

      tokens.add(
        LatexToken(
          type: match.block
              ? LatexTokenType.blockMath
              : LatexTokenType.inlineMath,
          content: source.substring(match.contentStart, match.contentEnd),
        ),
      );

      i = match.end;
    }

    flushText();
    return List.unmodifiable(tokens);
  }

  static _MathMatch? _findMath(String source, int start) {
    String? opening;
    String? closing;
    var block = false;

    if (source.startsWith(r'$$', start)) {
      if (_isEscaped(source, start)) return null;
      opening = r'$$';
      closing = r'$$';
      block = true;
    } else if (source.startsWith(r'\[', start)) {
      if (_isEscaped(source, start)) return null;
      opening = r'\[';
      closing = r'\]';
      block = true;
    } else if (source.startsWith(r'\(', start)) {
      if (_isEscaped(source, start)) return null;
      opening = r'\(';
      closing = r'\)';
    } else if (source[start] == r'$') {
      if (_isEscaped(source, start)) return null;
      // Opening $ must not be preceded by a digit (e.g. 100$).
      if (start > 0 && _isDigit(source[start - 1])) {
        return null;
      }
      opening = r'$';
      closing = r'$';
    }

    if (opening == null || closing == null) {
      return null;
    }

    final contentStart = start + opening.length;

    if (contentStart >= source.length) {
      return null;
    }

    // Single $ inline formulas must not start with whitespace.
    if (opening == r'$' && _isWhitespace(source[contentStart])) {
      return null;
    }

    var cursor = contentStart;

    while (cursor < source.length) {
      // Inline math cannot cross newlines.
      if (!block && source[cursor] == '\n') {
        return null;
      }

      if (source.startsWith(closing, cursor) && !_isEscaped(source, cursor)) {
        // Equation cannot be empty (e.g. $$$$ or \(\) or \[\]).
        if (cursor == contentStart) {
          return null;
        }

        final rawContent = source.substring(contentStart, cursor);

        // Content cannot be purely whitespace.
        if (rawContent.trim().isEmpty) {
          return null;
        }

        // Single $ inline formulas must not end with whitespace.
        if (opening == r'$' && _isWhitespace(source[cursor - 1])) {
          return null;
        }

        // Closing $ cannot be followed by a digit (prevents $10-$20 or $100 to $200).
        if (opening == r'$' &&
            cursor + 1 < source.length &&
            _isDigit(source[cursor + 1])) {
          return null;
        }

        // Avoid treating currency followed by English prose as math.
        // e.g. "$100 and more text$"
        if (opening == r'$' && _isDigit(source[contentStart])) {
          if (_looksLikeCurrencyProse(rawContent)) {
            return null;
          }
        }

        return _MathMatch(
          contentStart: contentStart,
          contentEnd: cursor,
          end: cursor + closing.length,
          block: block,
        );
      }

      cursor++;
    }

    // Incomplete equations remain ordinary text (streaming-safe).
    return null;
  }

  static bool _looksLikeCurrencyProse(String content) {
    // If it starts with digits and contains spaces without any math operators,
    // it's likely currency followed by regular prose.
    final hasMathOperators = RegExp(r'[+\-*\/=^_\\<>]').hasMatch(content);
    if (!hasMathOperators && content.contains(' ')) {
      return true;
    }
    return false;
  }

  static int? _fencedCodeEnd(String source, int start) {
    final lineStart = start == 0 ? 0 : source.lastIndexOf('\n', start - 1) + 1;

    if (source.substring(lineStart, start).trim().isNotEmpty) {
      return null;
    }

    final lineEnd = source.indexOf('\n', start);
    final endOfLine = lineEnd == -1 ? source.length : lineEnd;

    final line = source.substring(start, endOfLine);
    final indentMatch = RegExp(r'^ {0,3}').firstMatch(line);
    final indent = indentMatch?.end ?? 0;
    final rest = line.substring(indent);

    if (!rest.startsWith('```') && !rest.startsWith('~~~')) {
      return null;
    }

    final marker = rest[0];
    var count = 0;

    while (count < rest.length && rest[count] == marker) {
      count++;
    }

    if (count < 3) return null;

    final closingPattern = RegExp(
      '^ {0,3}${RegExp.escape(marker)}{$count,}[ \\t]*\$',
      multiLine: true,
    );

    final searchStart = endOfLine < source.length ? endOfLine + 1 : endOfLine;

    final remainingSource = source.substring(searchStart);
    final closing = closingPattern.firstMatch(remainingSource);

    if (closing == null) {
      // Unclosed code block consumes until end of source (streaming safe).
      return source.length;
    }

    return searchStart + closing.end;
  }

  static int? _inlineCodeEnd(String source, int start) {
    if (source[start] != '`') return null;

    var runLength = 1;

    while (start + runLength < source.length &&
        source[start + runLength] == '`') {
      runLength++;
    }

    final marker = '`' * runLength;
    final end = source.indexOf(marker, start + runLength);

    if (end == -1) return null;

    return end + runLength;
  }

  static int? _htmlCodeEnd(String source, int start) {
    if (source[start] != '<') return null;

    final lower = source.substring(start).toLowerCase();
    String? closingTag;

    if (lower.startsWith('<pre>') || lower.startsWith('<pre ')) {
      closingTag = '</pre>';
    } else if (lower.startsWith('<code>') || lower.startsWith('<code ')) {
      closingTag = '</code>';
    }

    if (closingTag == null) return null;

    final closingIndex = lower.indexOf(closingTag);
    if (closingIndex == -1) {
      return source.length;
    }

    return start + closingIndex + closingTag.length;
  }

  static bool _isEscaped(String source, int index) {
    var count = 0;
    var i = index - 1;

    while (i >= 0 && source[i] == r'\') {
      count++;
      i--;
    }

    return count.isOdd;
  }

  static bool _isWhitespace(String value) => value.trim().isEmpty;

  static bool _isDigit(String value) =>
      value.codeUnitAt(0) >= 48 && value.codeUnitAt(0) <= 57;
}

class _MathMatch {
  const _MathMatch({
    required this.contentStart,
    required this.contentEnd,
    required this.end,
    required this.block,
  });

  final int contentStart;
  final int contentEnd;
  final int end;
  final bool block;
}
