import 'package:flutter/material.dart';
import 'package:rich_markdown/rich_markdown.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universal Content Demo',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const DemoScreen(),
    );
  }
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  ContentType selectedType = ContentType.markdown;

  final markdownContent = r'''
# Universal Content

This is **bold**, *italic*, and ~~strikethrough~~.

## LaTeX

Inline equation: \(E = mc^2\)

Block equation:

$$
\int_0^1 x^2\,dx = \frac{1}{3}
$$

## Lists

- Markdown support
- Mathematical formulas
- Reusable Flutter widget

> A blockquote example.

[Open Flutter](https://flutter.dev)
''';

  final htmlContent = r'''
<h2>HTML content</h2>
<p>This is <strong>bold HTML</strong> and
<em>italic HTML</em>.</p>

<ul>
  <li>First item</li>
  <li>Second item</li>
</ul>

<p>Inline math: <tex>Uj1hXjI=</tex></p>
''';

  final latexContent = r'\int_0^\infty e^{-x}\,dx = 1';

  @override
  Widget build(BuildContext context) {
    final content = switch (selectedType) {
      ContentType.markdown => markdownContent,
      ContentType.html => htmlContent,
      ContentType.latex => latexContent,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Universal Content')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SegmentedButton<ContentType>(
            segments: const [
              ButtonSegment(
                value: ContentType.markdown,
                label: Text('Markdown'),
              ),
              ButtonSegment(value: ContentType.latex, label: Text('LaTeX')),
              ButtonSegment(value: ContentType.html, label: Text('HTML')),
            ],
            selected: {selectedType},
            onSelectionChanged: (selection) {
              setState(() {
                selectedType = selection.first;
              });
            },
          ),
          const SizedBox(height: 24),
          RichMarkdownView(
            data: content,
            type: selectedType,
            textStyle: const TextStyle(fontSize: 16, height: 1.5),
            onLinkTap: (url) {
              debugPrint('Tapped link: $url');
            },
          ),
        ],
      ),
    );
  }
}
