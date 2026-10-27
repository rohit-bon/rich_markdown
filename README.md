# Rich Markdown

A Flutter package for rendering **Markdown, LaTeX equations, and HTML content** in a single reusable widget. Designed for AI chat applications, streaming responses, educational apps, documentation viewers, and content-rich mobile applications.

## ✨ Features

- 📝 **Markdown Rendering** — Headings, paragraphs, bold, italic, strikethrough, lists, blockquotes, links, and GitHub Flavored Markdown.
- 🧮 **LaTeX Support** — Render inline and block mathematical expressions using `flutter_math_fork`.
- 🌐 **HTML Rendering** — Display HTML content with custom LaTeX tags.
- 💬 **AI Chat Ready** — Designed to support Markdown and math in AI-generated responses.
- ⚡ **Streaming-Friendly** — Supports progressively updated content as responses arrive.
- 🔗 **Link Callbacks** — Handle link taps with your own navigation logic.
- 🎨 **Custom Styling** — Customize text size, color, font family, and layout.
- 🧩 **Simple API** — One widget for multiple content formats.

## 📦 Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  rich_markdown: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start

Import the package:

```dart
import 'package:flutter/material.dart';
import 'package:rich_markdown/rich_markdown.dart';
```

Render Markdown content:

```dart
const content = r'''
# Hello, Rich Markdown!

This is **bold text** and *italic text*.

Inline equation: \(E = mc^2\)

Block equation:

$$
\int_0^1 x^2\,dx = \frac{1}{3}
$$
''';

RichMarkdownView(
  data: content,
  type: ContentType.markdown,
  textStyle: const TextStyle(
    fontSize: 16,
    height: 1.5,
  ),
)
```

## 📸 Screenshots

### 1. Markdown Rendering

<img
  src="https://raw.githubusercontent.com/rohit-bon/rich_markdown_assets/main/images/MarkdownRendering.png"
  alt="Markdown rendering screenshot"
  height="500"
/>

Displays Markdown formatting, headings, lists, links, and blockquotes.

### 2. Inline LaTeX

<img
  src="https://raw.githubusercontent.com/rohit-bon/rich_markdown_assets/main/images/InlineLatex.png"
  alt="Inline LaTeX screenshot"
  height="500"
/>

Render mathematical expressions directly within paragraphs.

### 3. Block LaTeX

<img
  src="https://raw.githubusercontent.com/rohit-bon/rich_markdown_assets/main/images/BlockLatex.png"
  alt="Block LaTeX screenshot"
  height="500"
/>

Display equations such as integrals, fractions, summations, and quadratic formulas.

### 4. HTML Rendering

<img
  src="https://raw.githubusercontent.com/rohit-bon/rich_markdown_assets/main/images/HtmlRendering.png"
  alt="HTML rendering screenshot"
  height="500"
/>

Render HTML elements, including paragraphs, lists, emphasis, links, and supported custom math tags.

### 5. Code and LaTeX Handling

<img
  src="https://raw.githubusercontent.com/rohit-bon/rich_markdown_assets/main/images/CodeLatex.png"
  alt="Code protection screenshot"
  height="500"
/>

Test code blocks and inline code containing LaTeX-like expressions.

### 6. Currency and Symbols

<img
  src="https://raw.githubusercontent.com/rohit-bon/rich_markdown_assets/main/images/CurrencySymbols.png"
  alt="Currency and symbols screenshot"
  height="500"
/>

Test currency values, escaped dollar signs, and inline mathematical expressions.

### 7. Incomplete Equations

<img
  src="https://raw.githubusercontent.com/rohit-bon/rich_markdown_assets/main/images/IncompleteEquations.png"
  alt="Incomplete equation screenshot"
  height="500"
/>

Test how unfinished equations are handled while content is being generated.

## 🎬 AI Streaming Demo

Watch Rich Markdown render progressively updated AI-style responses containing Markdown and LaTeX.

<img
  src="https://raw.githubusercontent.com/rohit-bon/rich_markdown_assets/main/gifs/AiStreaming.gif"
  alt="Rich Markdown streaming demo"
  height="500"
/>

The animation demonstrates simulated streaming in the example application. Actual streaming behavior depends on how your application supplies updated content and how incomplete Markdown and LaTeX expressions are handled.

## 🛠️ Usage

### Markdown

```dart
RichMarkdownView(
  data: '# Welcome\n\nThis is **Markdown**.',
  type: ContentType.markdown,
)
```

### LaTeX

Use raw strings to preserve LaTeX backslashes:

```dart
RichMarkdownView(
  data: r'\int_0^\infty e^{-x}\,dx = 1',
  type: ContentType.latex,
)
```

The `latex` content type renders the supplied expression in display math mode.

### HTML

```dart
RichMarkdownView(
  data: '''
    <h2>Hello</h2>
    <p>This is <strong>HTML</strong>.</p>
  ''',
  type: ContentType.html,
)
```

### HTML with LaTeX

The package supports custom `tex` and `texblock` tags containing Base64-encoded LaTeX.

```dart
RichMarkdownView(
  data: '''
    <p>Inline math: <tex>Uj1hXjI=</tex></p>
  ''',
  type: ContentType.html,
)
```

The encoded example represents `R=a^2`.

### Custom Styling

```dart
RichMarkdownView(
  data: '# Custom Content\n\nStyled text.',
  type: ContentType.markdown,
  textStyle: const TextStyle(
    fontSize: 18,
    height: 1.6,
    color: Colors.black87,
  ),
  shrinkWrap: true,
)
```

### Handle Link Taps

```dart
RichMarkdownView(
  data: '[Visit Flutter](https://flutter.dev)',
  onLinkTap: (url) {
    debugPrint('Tapped link: $url');
    // Add your navigation or URL-launching logic here.
  },
)
```

## 📚 API Reference

### `RichMarkdownView`

| Parameter | Type | Default | Description |
|---|---|---|---|
| `data` | `String` | Required | Content to render |
| `type` | `ContentType` | `ContentType.markdown` | Content format |
| `textStyle` | `TextStyle?` | `null` | Text styling |
| `onLinkTap` | `void Function(String? url)?` | `null` | Link tap callback |
| `shrinkWrap` | `bool` | `true` | Controls HTML content shrink wrapping |

### `ContentType`

| Value | Description |
|---|---|
| `ContentType.markdown` | Renders Markdown and supported LaTeX expressions |
| `ContentType.latex` | Renders the input as a block LaTeX expression |
| `ContentType.html` | Renders HTML with supported custom math tags |

## 🧪 Example App

Explore the example application to try different content types and test mathematical expressions.

```bash
git clone https://github.com/rohit-bon/rich_markdown.git
cd rich_markdown/example
flutter pub get
flutter run
```

Replace `YOUR_USERNAME` with your GitHub username.

## 🧰 Built With

- [Flutter](https://flutter.dev/)
- [markdown](https://pub.dev/packages/markdown)
- [flutter_html](https://pub.dev/packages/flutter_html)
- [flutter_math_fork](https://pub.dev/packages/flutter_math_fork)

## 🗺️ Roadmap

- [ ] More comprehensive Markdown and LaTeX parsing tests
- [ ] Improved handling of incomplete equations during streaming
- [ ] Additional HTML and Markdown customization
- [ ] Performance improvements for frequently updated AI responses
- [ ] More examples and documentation

## 🤝 Contributing

Contributions, bug reports, and feature requests are welcome.

1. Fork the repository.
2. Create a feature branch.
3. Implement your changes and add tests.
4. Submit a pull request.

## 📄 License

This project is distributed under the MIT License. See the [LICENSE](LICENSE) file for details.

## ⭐ Support

If you find Rich Markdown useful, consider giving the project a star on GitHub and sharing feedback through issues or pull requests.
