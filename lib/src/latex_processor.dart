
import 'dart:convert';

class LatexProcessor {
  LatexProcessor._();

  static String encode(String value) {
    return base64Url.encode(utf8.encode(value));
  }

  static String decode(String value) {
    return utf8.decode(base64Url.decode(value));
  }

  static String process(String input) {
    var result = input;

    // Block equations: $$ ... $$
    result = result.replaceAllMapped(
      RegExp(r'\$\$(.+?)\$\$', dotAll: true),
      (match) => _tag(match.group(1)!, block: true),
    );

    // Block equations: \[ ... \]
    result = result.replaceAllMapped(
      RegExp(r'\\\[(.+?)\\\]', dotAll: true),
      (match) => _tag(match.group(1)!, block: true),
    );

    // Inline equations: \( ... \)
    result = result.replaceAllMapped(
      RegExp(r'\\\((.+?)\\\)', dotAll: true),
      (match) => _tag(match.group(1)!, block: false),
    );

    // Inline equations: $ ... $
    result = result.replaceAllMapped(
      RegExp(r'(?<!\$)\$([^$\n]+)\$(?!\$)'),
      (match) => _tag(match.group(1)!, block: false),
    );

    return result;
  }

  static String _tag(String tex, {required bool block}) {
    final encoded = encode(tex.trim());
    final tag = block ? 'texblock' : 'tex';

    return '<$tag>$encoded</$tag>';
  }
}
