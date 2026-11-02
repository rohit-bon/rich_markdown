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
      title: 'Rich Markdown 1.1.0 Playground',
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
  bool _useCustomErrorBuilder = false;
  bool _showTokenInspector = false;

  final markdownExamples = <String, String>{
    'All Delimiters': r'''
# Supported LaTeX Delimiters

Rich Markdown supports all four standard LaTeX delimiter formats:

### 1. Single Dollar Inline: `$x^2$`
The mass-energy relation is $E = mc^2$, where $c$ is the speed of light.

### 2. Double Dollar Block: `$$x^2$$`
$$
\int_0^\infty e^{-x^2}\,dx = \frac{\sqrt{\pi}}{2}
$$

### 3. Parenthesized Inline: `\(x^2\)`
The Pythagorean identity is \(a^2 + b^2 = c^2\).

### 4. Bracketed Block: `\[x^2\]`
\[
x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
\]
''',
    'Code Protection': r'''
# Code Protection Edge Cases

LaTeX equations inside code blocks must remain literal code:

### Fenced code with backticks
```dart
// Math inside this code block remains code:
final formula = r'$E = mc^2$';
final block = '$$\\frac{a}{b}$$';
print(formula);
```

### Fenced code with tildes
~~~python
# Tilde fence block:
equation = "$x^2 + y^2 = z^2$"
~~~

### Inline code spans
Compare inline code `$$E = mc^2$$` with real math: $$E = mc^2$$.

Inline code with backticks `` `$x$` `` stays literal.
''',
    'Currency & Numbers': r'''
# Currency & Number Safety

Common currency formats must not accidentally become equations:

- Product price: **$100**
- Discounted price: **$50.00**
- Estimated range: **$10-$20**
- Items list: **$10, $20, and $30**
- Sentence test: I bought a shirt for $25 and shoes for $75.

### Coexisting with equations in the same paragraph:
The budget is $250, while the profit function is $P(x) = 15x - 50$.

Math containing numbers: $1 + 2 = 3$ and $10^2 = 100$.
''',
    'Escaped Delimiters': r'''
# Escaped Delimiters

Backslash-escaped delimiters must remain literal text:

- Escaped dollar: \$100 is not math.
- Escaped formula opening: \$x^2$ is not an equation.
- Unescaped dollar with escaped backslash: \\$x$ becomes \ and equation $x$.
- Escaped parentheses: \\(x\\) remains text.

Inside real equations, escaped dollars work:
$x = \$5$
''',
    'Multiple & Multiline': r'''
# Multiple & Multiline Equations

### Multiple equations in one paragraph:
Let $x = 1$, $y = 2$, and $z = 3$. Then $x + y = z$.

### Multiline block with `$$`:
$$
\begin{aligned}
f(x) &= (x + 1)(x - 1) \\
     &= x^2 - 1
\end{aligned}
$$

### Multiline block with `\[`:
\[
\sum_{k=1}^{n} k^2 = \frac{n(n+1)(2n+1)}{6}
\]
''',
    'Malformed LaTeX & Fallback': r'''
# Error Handling and Fallbacks

Malformed LaTeX expressions fail gracefully instead of crashing the app:

Broken fraction:
$\frac{broken$

Unknown macro:
$\unknownMacro{xyz}$

Toggle the **"Use Custom Error Fallback"** switch below to see custom error styling!
''',
    'Basic Markdown': r'''
# Rich Markdown Features

This is **bold text**, *italic text*, and ~~strikethrough~~.

## GFM Features

| Feature | Supported | Notes |
|---|---|---|
| Markdown | Yes | GitHub Flavored |
| LaTeX | Yes | 4 delimiter formats |
| Streaming | Yes | Progressive safe |

- [x] LaTeX Tokenizer
- [x] Code block isolation
- [x] Streaming resilience
- [ ] Upcoming features

> Rich Markdown simplifies combining Markdown and LaTeX for AI applications.

[Visit Flutter Documentation](https://flutter.dev)
''',
  };

  final htmlContent = r'''
<h2>HTML Content Rendering</h2>
<p>This is <strong>bold HTML</strong> and <em>italic HTML</em>.</p>

<p>Inline math via raw delimiters: $x^2 + y^2 = r^2$</p>

<p>Inline math via Base64 tag: <tex>Uj1hXjI=</tex></p>

<h3>Block Math inside HTML:</h3>
\[
\oint_C \mathbf{B} \cdot d\mathbf{l} = \mu_0 I_{\text{enc}}
\]

<pre><code>// Code tags preserve LaTeX:
$E = mc^2$
</code></pre>
''';

  final latexContent = r'''
\int_0^\infty e^{-x}\,dx = 1

x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}

\begin{pmatrix}
a & b \\
c & d
\end{pmatrix}
''';

  String selectedExample = 'All Delimiters';

  @override
  void dispose() {
    _streamTimer?.cancel();
    super.dispose();
  }

  void _startStreamingDemo() {
    _streamTimer?.cancel();

    const response = r'''
# AI Assistant Response

Here is the derivation you requested:

1. In Newtonian physics:
   $F = ma$

2. In relativistic mechanics, the energy-mass relationship is:
   $E = mc^2$

3. The integral equation for total energy:
   $$
   \int_0^1 x^2\,dx = \frac{1}{3}
   $$

4. The cost of running this calculation is only $0.05 per thousand tokens.

5. Here is the code snippet used:
   ```python
   # Equation inside code remains code:
   formula = "$E = mc^2$"
   print(formula)
   ```

All expressions stream smoothly!
''';

    setState(() {
      selectedType = ContentType.markdown;
      _streamedContent = '';
      _streamIndex = 0;
    });

    _streamTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_streamIndex >= response.length) {
        timer.cancel();
        return;
      }

      final nextIndex = (_streamIndex + 4).clamp(0, response.length);

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

    final tokens = LatexTokenizer.tokenize(content);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rich Markdown Playground'),
        actions: [
          IconButton(
            tooltip: 'Run AI streaming demo',
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
              'Select example scenario',
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
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _startStreamingDemo,
                    icon: const Icon(Icons.stream),
                    label: const Text('Simulate AI Streaming'),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Use Custom Error Fallback'),
            subtitle: const Text('Custom mathErrorBuilder for invalid LaTeX'),
            value: _useCustomErrorBuilder,
            onChanged: (val) {
              setState(() {
                _useCustomErrorBuilder = val;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Inspect Tokens (LatexTokenizer)'),
            subtitle: Text(
              'Extracted ${tokens.length} token(s) from current content',
            ),
            value: _showTokenInspector,
            onChanged: (val) {
              setState(() {
                _showTokenInspector = val;
              });
            },
          ),
          if (_showTokenInspector) ...[
            const SizedBox(height: 8),
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tokenized Output (${tokens.length} tokens):',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tokens.map((t) {
                        final color = switch (t.type) {
                          LatexTokenType.text => Colors.grey.shade300,
                          LatexTokenType.inlineMath =>
                            Colors.lightBlue.shade100,
                          LatexTokenType.blockMath =>
                            Colors.deepPurple.shade100,
                        };
                        final label = switch (t.type) {
                          LatexTokenType.text => 'text',
                          LatexTokenType.inlineMath => 'inlineMath',
                          LatexTokenType.blockMath => 'blockMath',
                        };
                        final preview = t.content.replaceAll('\n', r'\n');
                        final truncated = preview.length > 20
                            ? '${preview.substring(0, 20)}...'
                            : preview;
                        return Chip(
                          backgroundColor: color,
                          label: Text(
                            '$label: "$truncated"',
                            style: const TextStyle(fontSize: 11),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
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
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Tapped link: $url')));
                },
                mathErrorBuilder: _useCustomErrorBuilder
                    ? (context, error, tex) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'LaTeX Error: $tex',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Raw input', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              content,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
