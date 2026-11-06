enum LatexTokenType {
  text,
  inlineMath,
  blockMath,
}

/// Represents a parsed token within a text containing potential LaTeX expressions.
class LatexToken {
  const LatexToken({
    required this.type,
    required this.content,
  });

  /// The type of this token (text, inline math, or block math).
  final LatexTokenType type;

  /// The raw content string of this token.
  /// For math tokens, this contains the formula without delimiters.
  final String content;

  /// Whether this token is an inline or block math expression.
  bool get isMath => type != LatexTokenType.text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatexToken &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          content == other.content;

  @override
  int get hashCode => Object.hash(type, content);

  @override
  String toString() => 'LatexToken(type: $type, content: $content)';
}

