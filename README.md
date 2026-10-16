# rich_markdown

A reusable Flutter widget for rendering Markdown, LaTeX equations, and HTML in one place.

## Features

- Render Markdown content with GitHub-flavored extensions.
- Render inline and block LaTeX equations.
- Render HTML and common HTML/CSS styling.
- Customize text styles and link callbacks.
- Use a single widget API across Flutter applications.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  rich_markdown: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Markdown

```dart
import 'package:rich_markdown/rich_markdown.dart';

RichMarkdownView(
  data: '''
# Hello Flutter

This is **bold** text.

Inline math: \\(E = mc^2\\)

$$
\\frac{a}{b}
$$
''',
  type: ContentType.markdown,
)
```

## LaTeX

```dart
RichMarkdownView(
  data: r'\int_0^1 x^2\,dx = \frac{1}{3}',
  type: ContentType.latex,
)
```

## HTML

```dart
RichMarkdownView(
  data: '<h2>Hello</h2><p>HTML content</p>',
  type: ContentType.html,
)
```

## Customize text

```dart
RichMarkdownView(
  data: '# Custom text',
  textStyle: const TextStyle(
    fontSize: 18,
    height: 1.5,
  ),
)
```

## Link handling

```dart
RichMarkdownView(
  data: '[Flutter](https://flutter.dev)',
  onLinkTap: (url) {
    debugPrint('Tapped: $url');
  },
)
```

## Development

Run tests:

```bash
flutter test
```

Run static analysis:

```bash
flutter analyze
```

## Limitations

- LaTeX support depends on the capabilities of the underlying math renderer.
- Inline HTML and complex Markdown combinations require regression testing.
- HTML rendering is not a complete browser engine.
- Sanitize untrusted HTML and validate URLs before allowing navigation.

## License

MIT