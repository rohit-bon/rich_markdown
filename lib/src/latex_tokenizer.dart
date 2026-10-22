enum LatexTokenType { text, inlineMath, blockMath }

class LatexToken {
  const LatexToken({required this.type, required this.content});

  final LatexTokenType type;
  final String content;

  bool get isMath => type != LatexTokenType.text;
}

class LatexTokenizer {
  LatexTokenizer._();

  static List<LatexToken> tokenize(String source) {
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
      // Preserve fenced Markdown code blocks.
      final fenceEnd = _fencedCodeEnd(source, i);
      if (fenceEnd != null) {
        text.write(source.substring(i, fenceEnd));
        i = fenceEnd;
        continue;
      }

      // Preserve inline Markdown code spans.
      final codeEnd = _inlineCodeEnd(source, i);
      if (codeEnd != null) {
        text.write(source.substring(i, codeEnd));
        i = codeEnd;
        continue;
      }

      // Don't interpret escaped delimiters as math.
      if (source[i] == '\\' && i + 1 < source.length && source[i + 1] == r'$') {
        text.write(source.substring(i, i + 2));
        i += 2;
        continue;
      }

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
      opening = r'$$';
      closing = r'$$';
      block = true;
    } else if (source.startsWith(r'\[', start)) {
      opening = r'\[';
      closing = r'\]';
      block = true;
    } else if (source.startsWith(r'\(', start)) {
      opening = r'\(';
      closing = r'\)';
    } else if (source[start] == r'$') {
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

    // Inline formulas should not start with whitespace.
    if (!block && _isWhitespace(source[contentStart])) {
      return null;
    }

    // Avoid treating common currency values such as $100 as math.
    if (opening == r'$' && _isDigit(source[contentStart])) {
      return null;
    }

    var cursor = contentStart;

    while (cursor < source.length) {
      if (!block && source[cursor] == '\n') {
        return null;
      }

      if (source.startsWith(closing, cursor) && !_isEscaped(source, cursor)) {
        if (cursor == contentStart) {
          return null;
        }

        if (!block && _isWhitespace(source[cursor - 1])) {
          return null;
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

    // Incomplete equations remain ordinary text during streaming.
    return null;
  }

  static int? _fencedCodeEnd(String source, int start) {
    final lineStart = start == 0 ? 0 : source.lastIndexOf('\n', start - 1) + 1;

    if (source.substring(lineStart, start).trim().isNotEmpty) {
      return null;
    }

    final lineEnd = source.indexOf('\n', start);
    final endOfLine = lineEnd == -1 ? source.length : lineEnd;

    final line = source.substring(start, endOfLine);
    final indent = RegExp(r'^ {0,3}').firstMatch(line)!.end;
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

  static bool _isEscaped(String source, int index) {
    var count = 0;
    var i = index - 1;

    while (i >= 0 && source[i] == '\\') {
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
