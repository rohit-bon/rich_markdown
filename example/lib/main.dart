import 'dart:async';
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
      title: 'Rich Markdown Demo',
      debugShowCheckedModeBanner: false,
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
  Timer? _streamTimer;
  int _streamIndex = 0;
  String _streamedContent = '';

  final markdownExamples = <String, String>{
    'Basic Markdown': r'''
# Rich Markdown

This is **bold**, *italic*, and ~~strikethrough~~.

You can also use `inline code`.

## Lists

- Markdown support
- Mathematical formulas
- HTML rendering

1. First step
2. Second step
3. Third step

> Markdown supports blockquotes too.

[Visit Flutter](https://flutter.dev)
''',
    'Inline LaTeX': r'''
# Inline Equations

Einstein's equation is \(E = mc^2\).

The Pythagorean theorem is \(a^2 + b^2 = c^2\).

A fraction: \(\frac{a+b}{c}\).

Greek letters: \(\alpha + \beta = \gamma\).
''',
    'Block LaTeX': r'''
# Block Equations

Definite integral:

$$
\int_0^1 x^2\,dx = \frac{1}{3}
$$

Quadratic formula:

$$
x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
$$

Summation:

$$
\sum_{i=1}^{n} i = \frac{n(n+1)}{2}
$$
''',
    'Code Protection': r'''
# Code and LaTeX

Normal equation: \(x^2 + y^2 = z^2\).

Inline code should stay literal: `\(x^2\)`.

The equation inside this code block should not render as math:

```dart
final equation = r'$E = mc^2$';
final formula = r'\(x^2 + y^2\)';
print(equation);
```

Only equations outside code should render.
''',
    'Currency and Symbols': r'''
# Currency Test

The product costs $100 and shipping costs $20.

A math expression: $x + y = z$.

Escaped dollar sign: \$50.

This checks whether currency amounts are incorrectly parsed as equations.
''',
    'Incomplete Equation': r'''
# Streaming Parser Test

An unfinished equation: \(x^2 +

The tokenizer should leave an incomplete equation as text until its closing delimiter arrives.
''',
  };

  final htmlContent = r'''
<h2>HTML Content</h2>
<p>This is <strong>bold HTML</strong> and <em>italic HTML</em>.</p>

<p>Inline math: <tex>Uj1hXjI=</tex></p>

<h3>HTML List</h3>
<ul>
  <li>First item</li>
  <li>Second item</li>
  <li>Third item</li>
</ul>

<blockquote>
  <p>This is an HTML blockquote.</p>
</blockquote>

<p><a href="https://flutter.dev">Visit Flutter</a></p>
''';

  final latexContent = r'''
\int_0^\infty e^{-x}\,dx = 1

\frac{-b \pm \sqrt{b^2 - 4ac}}{2a}

\sum_{i=1}^{n} i = \frac{n(n+1)}{2}
''';

  String selectedExample = 'Basic Markdown';

  @override
  void dispose() {
    _streamTimer?.cancel();
    super.dispose();
  }

  void _startStreamingDemo() {
    _streamTimer?.cancel();

    const response = r'''
# AI Response

Here is the equation of Einstein:

\(E = mc^2\)

And here is a block equation:

$$
\frac{a+b}{c} = d
$$

This response is being added gradually to simulate an AI chat.
''';

    setState(() {
      selectedType = ContentType.markdown;
      _streamedContent = '';
      _streamIndex = 0;
    });

    _streamTimer = Timer.periodic(const Duration(milliseconds: 35), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_streamIndex >= response.length) {
        timer.cancel();
        return;
      }

      final nextIndex = (_streamIndex + 3).clamp(0, response.length);

      setState(() {
        _streamedContent = response.substring(0, nextIndex);
        _streamIndex = nextIndex;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isStreaming = _streamedContent.isNotEmpty;

    final content = switch (selectedType) {
      ContentType.markdown =>
        isStreaming ? _streamedContent : markdownExamples[selectedExample]!,
      ContentType.html => htmlContent,
      ContentType.latex => latexContent,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rich Markdown Playground'),
        actions: [
          IconButton(
            tooltip: 'Replay streaming demo',
            onPressed: _startStreamingDemo,
            icon: const Icon(Icons.play_arrow),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Content type', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<ContentType>(
            segments: const [
              ButtonSegment(
                value: ContentType.markdown,
                label: Text('Markdown'),
                icon: Icon(Icons.notes),
              ),
              ButtonSegment(
                value: ContentType.latex,
                label: Text('LaTeX'),
                icon: Icon(Icons.functions),
              ),
              ButtonSegment(
                value: ContentType.html,
                label: Text('HTML'),
                icon: Icon(Icons.code),
              ),
            ],
            selected: {selectedType},
            onSelectionChanged: (selection) {
              setState(() {
                selectedType = selection.first;
                _streamedContent = '';
                _streamTimer?.cancel();
              });
            },
          ),
          if (selectedType == ContentType.markdown) ...[
            const SizedBox(height: 20),
            Text(
              'Test example',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedExample,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: markdownExamples.keys.map((example) {
                return DropdownMenuItem(value: example, child: Text(example));
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedExample = value;
                  _streamedContent = '';
                  _streamTimer?.cancel();
                });
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _startStreamingDemo,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Test AI streaming'),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Rendered output',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: RichMarkdownView(
                data: content,
                type: selectedType,
                textStyle: const TextStyle(fontSize: 16, height: 1.5),
                onLinkTap: (url) {
                  debugPrint('Tapped link: $url');
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Current input', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SelectableText(
            content,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ],
      ),
    );
  }
}
